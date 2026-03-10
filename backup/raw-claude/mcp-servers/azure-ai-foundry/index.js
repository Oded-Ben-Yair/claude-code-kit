#!/usr/bin/env node

/**
 * Azure AI Foundry MCP Server
 * Provides access to Azure OpenAI models (GPT-5.x, Codex Max)
 *
 * IMPORTANT: GPT-5+ models do not support temperature parameter.
 * This server automatically omits temperature for GPT-5+ models.
 *
 * NOTE: Grok models are now available via dedicated grok MCP server.
 */

import { writeFile, mkdir } from "node:fs/promises";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const AZURE_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT || "https://brn-azai.cognitiveservices.azure.com/";
const AZURE_API_KEY = process.env.AZURE_OPENAI_KEY;
const API_VERSION = process.env.AZURE_OPENAI_API_VERSION || "2025-01-01-preview";

// Available models in your Azure AI Foundry
// apiType: "chat" = /chat/completions, "responses" = /openai/v1/responses
// Based on actual Azure deployment capabilities from: az cognitiveservices account deployment show
const MODELS = {
  // Chat Completions API models (chatCompletion: true)
  "gpt-5.2": { description: "GPT 5.2 - Latest general purpose model", apiType: "chat", supportsTemperature: false },
  "gpt-5.2-chat2": { description: "GPT 5.2 Chat2 - Latest chat-optimized model", apiType: "chat", supportsTemperature: false },
  "gpt-5.1": { description: "GPT 5.1 - Previous generation model", apiType: "chat", supportsTemperature: false },
  "gpt-5": { description: "GPT 5 - General purpose model", apiType: "chat", supportsTemperature: false },
  "gpt-5-chat": { description: "GPT 5 Chat - Chat-optimized, good for conversations", apiType: "chat", supportsTemperature: false },

  // Responses API models (use /openai/v1/responses endpoint)
  "gpt-5-pro": { description: "GPT 5 Pro - Advanced reasoning and research", apiType: "responses", supportsTemperature: false },
  "gpt-5.1-codex-max": { description: "GPT 5.1 Codex Max - Legacy code model (deprecated)", apiType: "responses", supportsTemperature: false, deprecated: true },
  "gpt-5.2-codex": { description: "GPT 5.2 Codex - Previous code model (deprecated, use gpt-5.3-codex)", apiType: "responses", supportsTemperature: false, deprecated: true },

  // Responses API models with code specialization
  "gpt-5.3-codex": { description: "ChatGPT 5.3 Codex - Latest code generation and review", apiType: "responses", supportsTemperature: false },

  // DeepSeek models (Chat Completions API with extended reasoning)
  "DeepSeek-V3.2-Speciale": {
    description: "DeepSeek V3.2 Speciale - 685B MoE, gold-medal reasoning (IMO/IOI 2025), rivals Gemini-3.0-Pro. Best for complex math, algorithms, deep research. 2-5x tokens, no tool-use.",
    apiType: "chat",
    supportsTemperature: true,
    contextWindow: "128k",
    costTier: "medium",
    specialization: "reasoning"
  },
  "DeepSeek-V3.2": {
    description: "DeepSeek V3.2 - GPT-5 level reasoning, balanced efficiency. Supports tool-use and thinking mode.",
    apiType: "chat",
    supportsTemperature: true,
    contextWindow: "128k",
    costTier: "low"
  },

  // Image generation model
  "gpt-image-1.5": {
    description: "GPT Image 1.5 - Latest image generation model with superior text rendering",
    apiType: "image",
    supportsTemperature: false
  },
};

/**
 * Check if a model supports temperature parameter
 */
function modelSupportsTemperature(modelName) {
  const model = MODELS[modelName];
  if (model && model.supportsTemperature !== undefined) {
    return model.supportsTemperature;
  }
  // Default: GPT-5+ models don't support temperature
  return !modelName.startsWith('gpt-5');
}

/**
 * Get the API type for a model (chat, responses)
 */
function getModelApiType(modelName) {
  const model = MODELS[modelName];
  return model?.apiType || "chat"; // Default to chat
}

/**
 * Call Azure model using Chat Completions API
 */
async function callAzureChatModel(deploymentName, messages, options = {}) {
  const url = `${AZURE_ENDPOINT}openai/deployments/${deploymentName}/chat/completions?api-version=${API_VERSION}`;

  const body = {
    messages: messages,
    max_completion_tokens: options.max_tokens || 4096,
  };

  // Only add temperature for models that support it
  if (modelSupportsTemperature(deploymentName) && options.temperature !== undefined) {
    body.temperature = options.temperature;
  }

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "api-key": AZURE_API_KEY,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Azure Chat API error: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data.choices[0].message.content;
}

/**
 * Call Azure model using Responses API (for GPT-5 Pro, Codex models)
 * See: https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/responses
 * Endpoint formats:
 *   - v1 API: /openai/v1/responses?api-version=preview
 *   - Legacy: /openai/responses?api-version=2025-04-01-preview
 */
async function callAzureResponsesModel(deploymentName, messages, options = {}) {
  // Responses API uses /openai/v1/responses with model in body
  // Used for: gpt-5-pro, gpt-5.3-codex, and legacy gpt-5.2-codex/gpt-5.1-codex-max
  const url = `${AZURE_ENDPOINT}openai/v1/responses?api-version=preview`;
  const useDeploymentStyle = false;  // Always use v1 style for remaining Responses API models

  // Debug logging
  console.error(`[DEBUG] Responses API call to ${deploymentName}: url=${url}`);

  // Convert messages to input format for Responses API
  const inputMessages = messages.map(msg => ({
    role: msg.role,
    content: msg.content
  }));

  const body = {
    input: inputMessages,
    max_output_tokens: options.max_tokens || 4096,
  };

  // Only include model in body for v1 API style (not deployment-style)
  if (!useDeploymentStyle) {
    body.model = deploymentName;
  }

  // Add reasoning for codex models (supports reasoning_effort)
  if (deploymentName === "gpt-5.3-codex" || deploymentName === "gpt-5.2-codex" || deploymentName === "gpt-5.1-codex-max") {
    body.reasoning = { effort: "high" };
  }

  console.error(`[DEBUG] Request body:`, JSON.stringify(body));

  let response;
  try {
    response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "api-key": AZURE_API_KEY,
      },
      body: JSON.stringify(body),
    });
  } catch (fetchError) {
    console.error(`[DEBUG] Fetch failed for ${url}:`, fetchError.message);
    throw new Error(`Network error calling Responses API: ${fetchError.message}`);
  }

  if (!response.ok) {
    const error = await response.text();
    console.error(`[DEBUG] Responses API error: ${response.status} - ${error}`);
    throw new Error(`Azure Responses API error: ${response.status} - ${error}`);
  }

  const data = await response.json();

  // Responses API returns output_text at top level, or nested in output array
  if (data.output_text) {
    return data.output_text;
  }

  // Extract text from output array (find the message type, not reasoning)
  if (data.output && Array.isArray(data.output)) {
    for (const item of data.output) {
      if (item.type === "message" && item.content) {
        for (const content of item.content) {
          if (content.type === "output_text" && content.text) {
            return content.text;
          }
        }
      }
    }
  }

  // Fallback: return stringified data
  return JSON.stringify(data);
}

/**
 * Call Azure OpenAI Images API (for gpt-image-1.5)
 * Returns array of { file_path, index } for saved PNG files.
 */
async function callAzureImageModel(prompt, options = {}) {
  const IMAGE_API_VERSION = "2025-04-01-preview";
  const url = `${AZURE_ENDPOINT}openai/deployments/gpt-image-1.5/images/generations?api-version=${IMAGE_API_VERSION}`;

  const body = {
    prompt: prompt,
    n: options.n || 1,
    size: options.size || "1024x1024",
    quality: options.quality || "high",
    output_format: "png",
  };

  console.error(`[DEBUG] Image API call: url=${url}, size=${body.size}, n=${body.n}, quality=${body.quality}`);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "api-key": AZURE_API_KEY,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const error = await response.text();
    console.error(`[DEBUG] Image API error: ${response.status} - ${error}`);
    throw new Error(`Azure Image API error: ${response.status} - ${error}`);
  }

  const data = await response.json();

  // Save images to /tmp/
  const timestamp = Date.now();
  const results = [];

  for (let i = 0; i < data.data.length; i++) {
    const imgData = data.data[i];
    const b64 = imgData.b64_json || imgData.b64 || imgData.base64;
    if (!b64) {
      console.error(`[DEBUG] Image ${i}: no base64 data found. Keys: ${Object.keys(imgData).join(", ")}`);
      continue;
    }
    const buffer = Buffer.from(b64, "base64");
    const filePath = `/tmp/azure-image-${timestamp}-${i}.png`;
    await writeFile(filePath, buffer);
    results.push({ file_path: filePath, index: i });
    console.error(`[DEBUG] Saved image to ${filePath} (${buffer.length} bytes)`);
  }

  return results;
}

/**
 * Smart router: calls the appropriate API based on model type
 */
async function callAzureModel(deploymentName, messages, options = {}) {
  const apiType = getModelApiType(deploymentName);

  if (apiType === "responses") {
    return callAzureResponsesModel(deploymentName, messages, options);
  } else {
    return callAzureChatModel(deploymentName, messages, options);
  }
}

const server = new Server(
  { name: "azure-ai-foundry", version: "2.0.0" },
  { capabilities: { tools: {} } }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "azure_chat",
        description: "Chat with Azure AI models (GPT-5.2, GPT-5.2 Chat2, GPT-5.1, GPT-5, GPT-5 Pro, GPT-5.3 Codex, DeepSeek V3.2 Speciale). Note: GPT-5+ models ignore temperature. Use grok MCP for Grok models.",
        inputSchema: {
          type: "object",
          properties: {
            model: {
              type: "string",
              description: "Model to use: gpt-5.2, gpt-5.1, gpt-5, gpt-5-chat, gpt-5-pro, gpt-5.3-codex, DeepSeek-V3.2-Speciale, DeepSeek-V3.2",
              enum: Object.keys(MODELS).filter(k => MODELS[k].apiType !== "image"),
            },
            prompt: {
              type: "string",
              description: "The prompt/question to send to the model",
            },
            system_prompt: {
              type: "string",
              description: "Optional system prompt to set context",
            },
            temperature: {
              type: "number",
              description: "Temperature (0-2). Only applies to non-GPT-5 models.",
            },
          },
          required: ["model", "prompt"],
        },
      },
      {
        name: "azure_code_review",
        description: "Review code using GPT-5.2 Codex for security, performance, quality, or bugs. Enhanced over Codex Max.",
        inputSchema: {
          type: "object",
          properties: {
            code: {
              type: "string",
              description: "The code to review",
            },
            language: {
              type: "string",
              description: "Programming language",
            },
            focus: {
              type: "string",
              description: "Focus area: security, performance, quality, bugs, or general",
              enum: ["security", "performance", "quality", "bugs", "general"],
            },
          },
          required: ["code"],
        },
      },
      {
        name: "azure_brainstorm",
        description: "Brainstorm ideas using GPT-5 Pro with advanced reasoning",
        inputSchema: {
          type: "object",
          properties: {
            topic: {
              type: "string",
              description: "Topic or problem to brainstorm about",
            },
            context: {
              type: "string",
              description: "Additional context or constraints",
            },
          },
          required: ["topic"],
        },
      },
      {
        name: "azure_research",
        description: "Deep research using GPT-5 Pro. Returns comprehensive analysis with sources and confidence levels.",
        inputSchema: {
          type: "object",
          properties: {
            topic: {
              type: "string",
              description: "Topic to research",
            },
            depth: {
              type: "string",
              description: "Research depth: quick (1-2 paragraphs), moderate (detailed analysis), comprehensive (full report)",
              enum: ["quick", "moderate", "comprehensive"],
            },
            output_format: {
              type: "string",
              description: "Output format: prose, bullet-points, structured",
              enum: ["prose", "bullet-points", "structured"],
            },
          },
          required: ["topic"],
        },
      },
      {
        name: "azure_reason",
        description: "Complex reasoning using GPT-5.2. For Grok reasoning, use grok_reason from grok MCP.",
        inputSchema: {
          type: "object",
          properties: {
            problem: {
              type: "string",
              description: "The problem requiring step-by-step reasoning",
            },
          },
          required: ["problem"],
        },
      },
      {
        name: "azure_deepseek_reason",
        description: "Complex reasoning using DeepSeek-V3.2-Speciale. Gold-medal performance (IMO/IOI 2025), rivals Gemini-3.0-Pro. Best for: math proofs, algorithm design, theoretical analysis, multi-step reasoning. Uses 2-5x more tokens.",
        inputSchema: {
          type: "object",
          properties: {
            problem: {
              type: "string",
              description: "The complex problem requiring deep reasoning (math, algorithms, theoretical analysis)",
            },
            thinking_budget: {
              type: "string",
              description: "How much thinking to allow: standard (balanced), extended (more thorough), maximum (no limits)",
              enum: ["standard", "extended", "maximum"],
            },
          },
          required: ["problem"],
        },
      },
      {
        name: "azure_generate_image",
        description: "Generate images using GPT-image-1.5 on Azure. Superior text rendering, structured output, enterprise quality. Returns file paths to saved PNGs.",
        inputSchema: {
          type: "object",
          properties: {
            prompt: {
              type: "string",
              description: "Image generation prompt describing what to create",
            },
            n: {
              type: "number",
              description: "Number of images to generate (1-4). Default: 1",
            },
            size: {
              type: "string",
              description: "Image size: 1024x1024 (square), 1536x1024 (landscape), 1024x1536 (portrait). Default: 1024x1024",
              enum: ["1024x1024", "1536x1024", "1024x1536"],
            },
            quality: {
              type: "string",
              description: "Image quality: low, medium, high. Default: high",
              enum: ["low", "medium", "high"],
            },
          },
          required: ["prompt"],
        },
      },
      {
        name: "list_models",
        description: "List all available Azure AI Foundry models with their capabilities",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "azure_chat": {
        const messages = [];
        if (args.system_prompt) {
          messages.push({ role: "system", content: args.system_prompt });
        }
        messages.push({ role: "user", content: args.prompt });

        const result = await callAzureModel(args.model, messages, {
          temperature: args.temperature,
        });

        return {
          content: [{ type: "text", text: `[${args.model}]\n\n${result}` }],
        };
      }

      case "azure_code_review": {
        const systemPrompt = `You are an expert code reviewer. Analyze the provided code and give detailed feedback focusing on ${args.focus || "general"} aspects. Be specific and actionable.`;
        const userPrompt = `Review this ${args.language || "code"}:\n\n\`\`\`\n${args.code}\n\`\`\``;

        const result = await callAzureModel("gpt-5.3-codex", [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ]);

        return {
          content: [{ type: "text", text: `[GPT-5.3 Codex Code Review]\n\n${result}` }],
        };
      }

      case "azure_brainstorm": {
        const systemPrompt = "You are a creative strategist and problem solver. Generate diverse, innovative ideas. Think outside the box while remaining practical.";
        const userPrompt = args.context
          ? `Topic: ${args.topic}\n\nContext: ${args.context}\n\nProvide 5-7 creative ideas or approaches.`
          : `Topic: ${args.topic}\n\nProvide 5-7 creative ideas or approaches.`;

        // GPT-5-Pro doesn't support temperature
        const result = await callAzureModel("gpt-5-pro", [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ]);

        return {
          content: [{ type: "text", text: `[GPT-5 Pro Brainstorm]\n\n${result}` }],
        };
      }

      case "azure_research": {
        const depth = args.depth || "moderate";
        const format = args.output_format || "structured";

        const depthInstructions = {
          quick: "Provide a concise 1-2 paragraph summary of key findings.",
          moderate: "Provide a detailed analysis covering main aspects, pros/cons, and implications.",
          comprehensive: "Provide a full research report with: Executive Summary, Key Findings, Detailed Analysis, Implications, Recommendations, and Confidence Assessment."
        };

        const formatInstructions = {
          prose: "Write in flowing prose paragraphs.",
          "bullet-points": "Use bullet points for easy scanning.",
          structured: "Use headers, sections, and structured formatting."
        };

        const systemPrompt = `You are an expert research analyst. Provide thorough, well-reasoned analysis based on your knowledge. Always:
1. State confidence levels (High/Medium/Low) for key claims
2. Acknowledge limitations or areas of uncertainty
3. Distinguish between established facts and inferences
${formatInstructions[format]}`;

        const userPrompt = `Research Topic: ${args.topic}\n\n${depthInstructions[depth]}`;

        // GPT-5-Pro doesn't support temperature
        const result = await callAzureModel("gpt-5-pro", [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ]);

        return {
          content: [{ type: "text", text: `[GPT-5 Pro Research - ${depth}]\n\n${result}` }],
        };
      }

      case "azure_reason": {
        const systemPrompt = "You are an expert at step-by-step logical reasoning. Break down complex problems systematically. Show your work.";

        const result = await callAzureModel("gpt-5.2", [
          { role: "system", content: systemPrompt },
          { role: "user", content: args.problem },
        ]);

        return {
          content: [{ type: "text", text: `[GPT-5.2 Reasoning]\n\n${result}` }],
        };
      }

      case "azure_deepseek_reason": {
        const thinkingBudget = args.thinking_budget || "extended";
        const maxTokens = thinkingBudget === "maximum" ? 32768 : (thinkingBudget === "extended" ? 16384 : 8192);

        const systemPrompt = `You are DeepSeek-V3.2-Speciale, a world-class reasoning model with gold-medal performance in IMO and IOI 2025.

Your approach:
1. Break down the problem into its fundamental components
2. Identify the core mathematical/logical structures
3. Apply rigorous step-by-step reasoning
4. Verify each step before proceeding
5. Provide a complete, well-justified solution

Think deeply and show all your reasoning. Quality and correctness are more important than brevity.`;

        const userPrompt = `Problem requiring deep reasoning:\n\n${args.problem}\n\nProvide a thorough, step-by-step solution with full justification.`;

        const result = await callAzureModel("DeepSeek-V3.2-Speciale", [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ], { max_tokens: maxTokens, temperature: 0.7 });

        return {
          content: [{ type: "text", text: `[DeepSeek-V3.2-Speciale | Thinking: ${thinkingBudget}]\n\n${result}` }],
        };
      }

      case "azure_generate_image": {
        const results = await callAzureImageModel(args.prompt, {
          n: args.n,
          size: args.size,
          quality: args.quality,
        });

        const fileList = results.map(r => `  ${r.file_path}`).join("\n");
        const summary = `[GPT-image-1.5] Generated ${results.length} image(s):\n${fileList}\n\nSize: ${args.size || "1024x1024"} | Quality: ${args.quality || "high"}`;

        return {
          content: [{ type: "text", text: summary }],
        };
      }

      case "list_models": {
        const modelList = Object.entries(MODELS)
          .map(([name, info]) => `• ${name}: ${info.description} [API: ${info.apiType}] ${info.supportsTemperature ? '(temp: yes)' : '(temp: no)'}`)
          .join("\n");

        return {
          content: [{ type: "text", text: `Available Azure AI Foundry Models:\n\n${modelList}\n\nNote: 'chat' = /chat/completions API, 'responses' = /responses API (GPT-5 Pro, Codex models)` }],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [{ type: "text", text: `Error: ${error.message}` }],
      isError: true,
    };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
