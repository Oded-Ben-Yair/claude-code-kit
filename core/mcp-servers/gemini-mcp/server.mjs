#!/usr/bin/env node
/**
 * Gemini MCP Server v2.2 — Updated 2026-02-20 (Gemini 3.1 Pro)
 * Uses low-level Server API (proven pattern from azure-ai-foundry + grok MCPs)
 *
 * Models:
 * - gemini-3.1-pro-preview      — Flagship reasoning (upgraded from 3.0)
 * - gemini-3-flash-preview      — Fast model
 * - gemini-3-pro-image-preview  — Nano Banana Pro (image gen/edit)
 * - imagen-4.0-generate-001     — Imagen 4 (generateImages API)
 * - veo-3.1-generate-preview    — Veo 3.1 (generateVideos API, async polling)
 */
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { GoogleGenAI } from '@google/genai';
import { writeFile, mkdir } from 'node:fs/promises';
import { dirname } from 'node:path';

// ── Models ────────────────────────────────────────────────────────────
const MODELS = {
  reasoning: 'gemini-3.1-pro-preview',
  flash:     'gemini-3-flash-preview',
  image:     'gemini-3.1-flash-image-preview', // Nano Banana 2 — Pro quality, Flash speed
  imagen:    'imagen-4.0-generate-001',
  video:     'veo-3.1-generate-preview',
};

// ── Client ────────────────────────────────────────────────────────────
let ai;
function getAI() {
  if (!ai) {
    const key = process.env.GEMINI_API_KEY;
    if (!key) throw new Error('GEMINI_API_KEY not set');
    ai = new GoogleGenAI({ apiKey: key });
  }
  return ai;
}

// ── Helpers ───────────────────────────────────────────────────────────
function buildConfig(opts = {}) {
  const cfg = { temperature: 1.0 };
  if (opts.thinkingLevel) cfg.thinkingConfig = { thinkingLevel: opts.thinkingLevel };
  if (opts.mediaResolution) cfg.mediaResolution = `MEDIA_RESOLUTION_${opts.mediaResolution}`;
  if (opts.tools?.length) cfg.tools = opts.tools.map(t => ({ [t]: {} }));
  return cfg;
}

function extractParts(response) {
  let text = '', imageData, mimeType;
  for (const part of response.candidates?.[0]?.content?.parts || []) {
    if (part.text) text += part.text;
    if (part.inlineData) { imageData = part.inlineData.data; mimeType = part.inlineData.mimeType || 'image/png'; }
  }
  return { text, imageData, mimeType };
}

function ok(text) { return { content: [{ type: 'text', text }] }; }
function fail(e) { return { content: [{ type: 'text', text: `Error: ${e?.message || e}` }], isError: true }; }

async function saveBase64(b64, filePath) {
  await mkdir(dirname(filePath), { recursive: true });
  await writeFile(filePath, Buffer.from(b64, 'base64'));
  console.error(`[Gemini-MCP] Saved image to ${filePath}`);
}

async function imgOk(r, outputPath) {
  const textParts = [r.text || 'Done'];
  const c = [];
  if (r.imageData) {
    if (outputPath) {
      await saveBase64(r.imageData, outputPath);
      textParts.push(`Saved to: ${outputPath}`);
    }
    c.push({ type: 'text', text: textParts.join('\n') });
    c.push({ type: 'image', data: r.imageData, mimeType: r.mimeType || 'image/png' });
  } else {
    c.push({ type: 'text', text: textParts.join('\n') });
  }
  return { content: c };
}

// ── Tool Definitions (JSON Schema format) ─────────────────────────────
const TOOLS = [
  {
    name: 'gemini-query',
    description: 'General reasoning with Gemini 3 Pro or Flash. Use pro for deep reasoning, flash for speed.',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: { type: 'string', description: 'Prompt to send to Gemini' },
        thinking_level: { type: 'string', enum: ['low', 'high'], description: '"low" for fast, "high" for deep reasoning. Default: high' },
        model: { type: 'string', enum: ['pro', 'flash'], description: '"pro" = Gemini 3 Pro, "flash" = Gemini 3 Flash. Default: pro' },
        media_resolution: { type: 'string', enum: ['LOW', 'MEDIUM', 'HIGH', 'ULTRA_HIGH'], description: 'Vision resolution for image inputs' },
      },
      required: ['prompt'],
    },
  },
  {
    name: 'gemini-brainstorm',
    description: 'Collaborative brainstorming with Gemini 3 Pro (thinking=high)',
    inputSchema: {
      type: 'object',
      properties: {
        topic: { type: 'string', description: 'Problem or topic' },
        claude_thoughts: { type: 'string', description: "Claude's initial analysis to build upon" },
      },
      required: ['topic', 'claude_thoughts'],
    },
  },
  {
    name: 'gemini-analyze-text',
    description: 'Text analysis: sentiment, summary, entities, key-points, or general',
    inputSchema: {
      type: 'object',
      properties: {
        text: { type: 'string', description: 'Text to analyze' },
        analysis_type: { type: 'string', enum: ['sentiment', 'summary', 'entities', 'key-points', 'general'], description: 'Type of analysis. Default: general' },
      },
      required: ['text'],
    },
  },
  {
    name: 'gemini-analyze-image',
    description: 'Vision analysis of base64 encoded images using Gemini 3 Pro',
    inputSchema: {
      type: 'object',
      properties: {
        image_data: { type: 'string', description: 'Base64 encoded image' },
        prompt: { type: 'string', description: 'Analysis prompt. Default: Analyze this image in detail' },
        media_resolution: { type: 'string', enum: ['LOW', 'MEDIUM', 'HIGH', 'ULTRA_HIGH'], description: 'Resolution level' },
      },
      required: ['image_data'],
    },
  },
  {
    name: 'gemini-analyze-document',
    description: 'PDF/document analysis using Gemini 3 Pro',
    inputSchema: {
      type: 'object',
      properties: {
        document_data: { type: 'string', description: 'Base64 encoded document (PDF, image)' },
        mime_type: { type: 'string', description: 'MIME type. Default: application/pdf' },
        prompt: { type: 'string', description: 'Analysis prompt. Default: Analyze this document' },
      },
      required: ['document_data'],
    },
  },
  {
    name: 'gemini-generate-image',
    description: 'Generate images using Nano Banana Pro (Gemini 3 Pro Image) via generateContent with IMAGE modality',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: { type: 'string', description: 'Image generation prompt' },
        aspect_ratio: { type: 'string', enum: ['1:1', '2:3', '3:2', '3:4', '4:3', '4:5', '5:4', '9:16', '16:9', '21:9'], description: 'Output aspect ratio. Default: 16:9' },
        image_size: { type: 'string', enum: ['1K', '2K', '4K'], description: 'Resolution. Default: 2K' },
        grounded: { type: 'boolean', description: 'Use Google Search for real-time data. Default: false' },
        output_path: { type: 'string', description: 'Optional file path to save the generated image (e.g. /tmp/my-image.png)' },
      },
      required: ['prompt'],
    },
  },
  {
    name: 'gemini-edit-image',
    description: 'Edit existing image via Nano Banana Pro (Gemini 3 Pro Image)',
    inputSchema: {
      type: 'object',
      properties: {
        source_image: { type: 'string', description: 'Base64 source image' },
        edit_prompt: { type: 'string', description: 'Edit instruction' },
        aspect_ratio: { type: 'string', enum: ['1:1', '2:3', '3:2', '3:4', '4:3', '4:5', '5:4', '9:16', '16:9', '21:9'], description: 'Aspect ratio' },
        image_size: { type: 'string', enum: ['1K', '2K', '4K'], description: 'Resolution' },
      },
      required: ['source_image', 'edit_prompt'],
    },
  },
  {
    name: 'gemini-imagen4',
    description: 'Generate images with Imagen 4 (top image model). Uses separate generateImages API.',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: { type: 'string', description: 'Image generation prompt' },
        aspect_ratio: { type: 'string', enum: ['1:1', '3:4', '4:3', '9:16', '16:9'], description: 'Aspect ratio. Default: 16:9' },
        number_of_images: { type: 'number', description: 'Number of images 1-4. Default: 1' },
        output_path: { type: 'string', description: 'Optional file path to save the generated image (e.g. /tmp/my-image.png). For multiple images, appends -0, -1, etc.' },
      },
      required: ['prompt'],
    },
  },
  {
    name: 'gemini-veo',
    description: 'Generate video with Veo 3.1 (async polling, may take minutes)',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: { type: 'string', description: 'Video description prompt (max 1024 tokens)' },
        duration: { type: 'number', description: 'Duration: 4, 6, or 8 seconds. Default: 8' },
        aspect_ratio: { type: 'string', enum: ['16:9', '9:16'], description: 'Aspect ratio. Default: 16:9' },
        resolution: { type: 'string', enum: ['720p', '1080p'], description: 'Resolution. Default: 720p' },
      },
      required: ['prompt'],
    },
  },
  {
    name: 'gemini-image-prompt',
    description: 'Optimize prompts for AI image generation using Gemini 3 Flash',
    inputSchema: {
      type: 'object',
      properties: {
        description: { type: 'string', description: 'Image description' },
        style: { type: 'string', description: 'Artistic style' },
        mood: { type: 'string', description: 'Mood/atmosphere' },
      },
      required: ['description'],
    },
  },
  {
    name: 'gemini-url-context',
    description: 'Analyze URLs with Gemini url_context tool',
    inputSchema: {
      type: 'object',
      properties: {
        urls: { type: 'array', items: { type: 'string' }, description: 'URLs to analyze (max 20)' },
        prompt: { type: 'string', description: 'Analysis prompt' },
        thinking_level: { type: 'string', enum: ['low', 'high'], description: 'Thinking level. Default: high' },
      },
      required: ['urls', 'prompt'],
    },
  },
  {
    name: 'gemini-grounded-query',
    description: 'Query with Google Search grounding for real-time data',
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'Query with real-time web search grounding' },
        thinking_level: { type: 'string', enum: ['low', 'high'], description: 'Thinking level. Default: high' },
      },
      required: ['query'],
    },
  },
  {
    name: 'gemini-summarize',
    description: 'Flexible summarization using Gemini 3 Flash',
    inputSchema: {
      type: 'object',
      properties: {
        content: { type: 'string', description: 'Content to summarize' },
        length: { type: 'string', enum: ['brief', 'moderate', 'detailed'], description: 'Summary length. Default: moderate' },
        format: { type: 'string', enum: ['paragraph', 'bullet-points', 'outline'], description: 'Output format. Default: paragraph' },
      },
      required: ['content'],
    },
  },
  {
    name: 'gemini-analyze-code',
    description: 'Code analysis for quality, security, performance, or bugs',
    inputSchema: {
      type: 'object',
      properties: {
        code: { type: 'string', description: 'Code to analyze' },
        language: { type: 'string', description: 'Programming language' },
        focus: { type: 'string', enum: ['quality', 'security', 'performance', 'bugs', 'general'], description: 'Focus area. Default: general' },
      },
      required: ['code'],
    },
  },
  {
    name: 'gemini-generate-asset',
    description: 'Generate typed assets (icon, logo, banner, etc.) with presets via Nano Banana Pro',
    inputSchema: {
      type: 'object',
      properties: {
        asset_type: { type: 'string', enum: ['app-icon', 'logo', 'banner', 'social-post', 'product-photo', 'ui-mockup', 'data-viz', 'marketing'] },
        description: { type: 'string', description: 'Asset description' },
        style: { type: 'string', description: 'Visual style' },
        color_scheme: { type: 'string', description: 'Color scheme' },
        text_content: { type: 'string', description: 'Text to render in image' },
        output_path: { type: 'string', description: 'Optional file path to save the generated image' },
      },
      required: ['asset_type', 'description'],
    },
  },
  {
    name: 'gemini-list-models',
    description: 'List all available Gemini models and tools',
    inputSchema: { type: 'object', properties: {} },
  },
];

// ── Asset Presets ─────────────────────────────────────────────────────
const PRESETS = {
  'app-icon': { ar: '1:1', sz: '4K', s: 'app icon, centered, clean edges' },
  'logo':     { ar: '1:1', sz: '4K', s: 'logo, professional, scalable' },
  'banner':   { ar: '16:9', sz: '2K', s: 'marketing banner, bold' },
  'social-post': { ar: '1:1', sz: '2K', s: 'social media, bold colors' },
  'product-photo': { ar: '1:1', sz: '4K', s: 'product photo, studio lighting' },
  'ui-mockup': { ar: '16:9', sz: '2K', s: 'UI mockup, modern' },
  'data-viz': { ar: '16:9', sz: '2K', s: 'infographic, clean data viz' },
  'marketing': { ar: '16:9', sz: '2K', s: 'marketing visual, professional' },
};

// ── Tool Handlers ─────────────────────────────────────────────────────
const handlers = {
  'gemini-query': async (args) => {
    const m = args.model === 'flash' ? MODELS.flash : MODELS.reasoning;
    const r = await getAI().models.generateContent({
      model: m, contents: args.prompt,
      config: buildConfig({ thinkingLevel: args.thinking_level || 'high', mediaResolution: args.media_resolution }),
    });
    return ok(r.text || '');
  },

  'gemini-brainstorm': async (args) => {
    const prompt = `Collaborating with Claude on: ${args.topic}\n\nClaude's analysis:\n${args.claude_thoughts}\n\nProvide:\n1. Your perspective on Claude's analysis\n2. Additional ideas not covered\n3. Challenges and considerations\n4. Synthesis of best approaches\n5. Concrete next steps`;
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents: prompt,
      config: buildConfig({ thinkingLevel: 'high' }),
    });
    return ok(r.text || '');
  },

  'gemini-analyze-text': async (args) => {
    const type = args.analysis_type || 'general';
    const prompts = {
      sentiment: `Analyze sentiment (positive/negative/neutral, confidence, key indicators):\n\n${args.text}`,
      summary: `Concise summary:\n\n${args.text}`,
      entities: `Extract named entities (people, orgs, locations, dates):\n\n${args.text}`,
      'key-points': `Key points as bullet list:\n\n${args.text}`,
      general: `Comprehensive analysis (tone, themes, notable elements):\n\n${args.text}`,
    };
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents: prompts[type],
      config: buildConfig({ thinkingLevel: type === 'general' ? 'high' : 'low' }),
    });
    return ok(r.text || '');
  },

  'gemini-analyze-image': async (args) => {
    const contents = [{ role: 'user', parts: [
      { inlineData: { data: args.image_data, mimeType: 'image/png' } },
      { text: args.prompt || 'Analyze this image in detail' },
    ]}];
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents,
      config: buildConfig({ thinkingLevel: 'high', mediaResolution: args.media_resolution }),
    });
    return ok(r.text || '');
  },

  'gemini-analyze-document': async (args) => {
    const contents = [{ role: 'user', parts: [
      { inlineData: { data: args.document_data, mimeType: args.mime_type || 'application/pdf' } },
      { text: args.prompt || 'Analyze this document' },
    ]}];
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents,
      config: buildConfig({ thinkingLevel: 'high', mediaResolution: 'MEDIUM' }),
    });
    return ok(r.text || '');
  },

  'gemini-generate-image': async (args) => {
    const cfg = {
      responseModalities: ['TEXT', 'IMAGE'],
      temperature: 1.0,
      imageConfig: { aspectRatio: args.aspect_ratio || '16:9', imageSize: args.image_size || '2K' },
    };
    if (args.grounded) cfg.tools = [{ google_search: {} }];
    const r = await getAI().models.generateContent({ model: MODELS.image, contents: args.prompt, config: cfg });
    return imgOk(extractParts(r), args.output_path);
  },

  'gemini-edit-image': async (args) => {
    const cfg = { responseModalities: ['TEXT', 'IMAGE'], temperature: 1.0 };
    if (args.aspect_ratio || args.image_size) {
      cfg.imageConfig = {};
      if (args.aspect_ratio) cfg.imageConfig.aspectRatio = args.aspect_ratio;
      if (args.image_size) cfg.imageConfig.imageSize = args.image_size;
    }
    const contents = [{ role: 'user', parts: [
      { inlineData: { data: args.source_image, mimeType: 'image/png' } },
      { text: args.edit_prompt },
    ]}];
    const r = await getAI().models.generateContent({ model: MODELS.image, contents, config: cfg });
    return imgOk(extractParts(r));
  },

  'gemini-imagen4': async (args) => {
    const response = await getAI().models.generateImages({
      model: MODELS.imagen,
      prompt: args.prompt,
      config: { numberOfImages: args.number_of_images || 1, includeRaiReason: true, aspectRatio: args.aspect_ratio || '16:9' },
    });
    const images = response.generatedImages || [];
    if (images.length === 0) return ok('No images generated (may have been safety-filtered)');
    const savedPaths = [];
    const content = [];
    for (let i = 0; i < images.length; i++) {
      const img = images[i];
      if (img.image?.imageBytes) {
        if (args.output_path) {
          const ext = args.output_path.replace(/.*\./, '');
          const base = args.output_path.replace(/\.[^.]+$/, '');
          const savePath = images.length === 1 ? args.output_path : `${base}-${i}.${ext}`;
          await saveBase64(img.image.imageBytes, savePath);
          savedPaths.push(savePath);
        }
        content.push({ type: 'image', data: img.image.imageBytes, mimeType: 'image/png' });
      }
      if (img.raiFilteredReason) content.push({ type: 'text', text: `[Filtered: ${img.raiFilteredReason}]` });
    }
    const textParts = [`Generated ${images.length} image(s) via Imagen 4`];
    if (savedPaths.length) textParts.push(`Saved to: ${savedPaths.join(', ')}`);
    content.unshift({ type: 'text', text: textParts.join('\n') });
    return { content };
  },

  'gemini-veo': async (args) => {
    let operation = await getAI().models.generateVideos({
      model: MODELS.video,
      prompt: args.prompt,
      config: { personGeneration: 'allow_adult', aspectRatio: args.aspect_ratio || '16:9', numberOfVideos: 1 },
    });
    const maxWait = 360000;
    const start = Date.now();
    while (!operation.done && (Date.now() - start) < maxWait) {
      await new Promise(r => setTimeout(r, 10000));
      operation = await getAI().operations.getVideosOperation({ operation });
    }
    if (!operation.done) return ok('Video generation timed out (>6 min). Try again later.');
    const videos = operation.response?.generatedVideos || [];
    if (videos.length === 0) return ok('No videos generated (may have been safety-filtered)');
    const uri = videos[0]?.video?.uri;
    const dur = args.duration || 8;
    const res = args.resolution || '720p';
    return ok(`Video generated via Veo 3.1:\n- URI: ${uri}\n- Duration: ${dur}s\n- Resolution: ${res}\n- Aspect: ${args.aspect_ratio || '16:9'}\n\nDownload: ${uri}&key=<API_KEY>`);
  },

  'gemini-image-prompt': async (args) => {
    const prompt = `Create a detailed, optimized prompt for AI image generation:\n\nDescription: ${args.description}\n${args.style ? `Style: ${args.style}` : ''}\n${args.mood ? `Mood: ${args.mood}` : ''}\n\nProvide:\n1. Refined prompt (1 paragraph)\n2. Key visual elements\n3. Technical suggestions (lighting, composition)\n4. Style references`;
    const r = await getAI().models.generateContent({
      model: MODELS.flash, contents: prompt,
      config: buildConfig({ thinkingLevel: 'low' }),
    });
    return ok(r.text || '');
  },

  'gemini-url-context': async (args) => {
    const full = `${args.prompt}\n\nURLs:\n${args.urls.map((u, i) => `${i+1}. ${u}`).join('\n')}`;
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents: full,
      config: buildConfig({ thinkingLevel: args.thinking_level || 'high', tools: ['url_context'] }),
    });
    return ok(r.text || '');
  },

  'gemini-grounded-query': async (args) => {
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning, contents: args.query,
      config: buildConfig({ thinkingLevel: args.thinking_level || 'high', tools: ['google_search'] }),
    });
    return ok(r.text || '');
  },

  'gemini-summarize': async (args) => {
    const length = args.length || 'moderate';
    const format = args.format || 'paragraph';
    const lens = { brief: '2-3 sentences', moderate: '1-2 paragraphs', detailed: '3-4 paragraphs' };
    const fmts = { paragraph: 'prose', 'bullet-points': 'bullet points', outline: 'hierarchical outline' };
    const r = await getAI().models.generateContent({
      model: MODELS.flash, contents: `Summarize in ${lens[length]} using ${fmts[format]}:\n\n${args.content}`,
      config: buildConfig({ thinkingLevel: 'low' }),
    });
    return ok(r.text || '');
  },

  'gemini-analyze-code': async (args) => {
    const lang = args.language || '';
    const focus = args.focus || 'general';
    const r = await getAI().models.generateContent({
      model: MODELS.reasoning,
      contents: `Analyze this ${lang || 'code'} (focus: ${focus}):\n\n\`\`\`${lang}\n${args.code}\n\`\`\`\n\n1) Assessment 2) Issues 3) Recommendations 4) Score (1-10)`,
      config: buildConfig({ thinkingLevel: 'high' }),
    });
    return ok(r.text || '');
  },

  'gemini-generate-asset': async (args) => {
    const p = PRESETS[args.asset_type];
    let prompt = args.description;
    if (args.style) prompt += `, ${args.style} style`;
    if (args.color_scheme) prompt += `, colors: ${args.color_scheme}`;
    if (args.text_content) prompt += `. Include text: "${args.text_content}"`;
    prompt += `. ${p.s}`;
    const cfg = { responseModalities: ['TEXT', 'IMAGE'], temperature: 1.0, imageConfig: { aspectRatio: p.ar, imageSize: p.sz } };
    const r = await getAI().models.generateContent({ model: MODELS.image, contents: prompt, config: cfg });
    return imgOk(extractParts(r), args.output_path);
  },

  'gemini-list-models': async () => {
    return ok([
      'Gemini MCP v2.1 — Available Models (2026-02-10):',
      '',
      `Reasoning:  ${MODELS.reasoning}  (Gemini 3 Pro — flagship)`,
      `Fast:       ${MODELS.flash}  (Gemini 3 Flash — speed)`,
      `Image Gen:  ${MODELS.image}  (Nano Banana Pro — image gen/edit)`,
      `Imagen 4:   ${MODELS.imagen}  (top image model)`,
      `Video:      ${MODELS.video}  (Veo 3.1 — text/image to video)`,
      '',
      'Tools: gemini-query, gemini-brainstorm, gemini-analyze-text,',
      '       gemini-analyze-image, gemini-analyze-document,',
      '       gemini-generate-image, gemini-edit-image, gemini-imagen4,',
      '       gemini-veo, gemini-image-prompt, gemini-url-context,',
      '       gemini-grounded-query, gemini-summarize, gemini-analyze-code,',
      '       gemini-generate-asset, gemini-list-models',
    ].join('\n'));
  },
};

// ── Main ──────────────────────────────────────────────────────────────
async function main() {
  console.error('[Gemini-MCP] Starting v2.1...');

  const server = new Server(
    { name: 'gemini-mcp', version: '2.1.0' },
    { capabilities: { tools: {} } }
  );

  // List tools handler
  server.setRequestHandler(ListToolsRequestSchema, async () => {
    return { tools: TOOLS };
  });

  // Call tool handler
  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    const handler = handlers[name];
    if (!handler) {
      return { content: [{ type: 'text', text: `Unknown tool: ${name}` }], isError: true };
    }
    try {
      return await handler(args || {});
    } catch (e) {
      console.error(`[Gemini-MCP] Error in ${name}:`, e.message);
      return fail(e);
    }
  });

  // Connect transport
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error(`[Gemini-MCP] Server running — ${TOOLS.length} tools registered`);

  const shutdown = async () => { console.error('[Gemini-MCP] Bye'); await server.close(); process.exit(0); };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

main().catch(e => { console.error('[Gemini-MCP] Fatal:', e); process.exit(1); });
