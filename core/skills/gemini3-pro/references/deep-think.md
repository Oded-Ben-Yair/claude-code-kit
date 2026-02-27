# Gemini Deep Think & Reasoning Reference

## g3-deep-think (Deep Thinking)

Maximum reasoning depth. Returns the model's thinking process alongside the answer.

```
Parameters:
- prompt (required): Complex problem requiring deep reasoning
- include_thoughts: boolean (default: true) - show reasoning chain
- media_resolution: vision resolution for context
```

**When to use:** Math, multi-step logic, scientific analysis, architecture decisions, debugging.
Returns: answer + thinking process + thinking token count.

**Example:**
```
mcp__gemini__g3-deep-think
  prompt: "Prove that the sum of angles in any triangle equals 180 degrees"
  include_thoughts: true
```

---

## g3-think (Configurable Thinking)

Full control over thinking depth, supports both Gemini 3.1 levels and 2.5 budgets.

```
Parameters:
- prompt (required): The query text
- thinking_level: "minimal" | "low" | "medium" | "high" (Gemini 3)
- thinking_budget: integer (Gemini 2.5 only, -1=dynamic, 0=off)
- include_thoughts: boolean (default: false) - show reasoning chain
- media_resolution: vision resolution
```

**Example:**
```
mcp__gemini__g3-think
  prompt: "Compare React vs Vue for our dashboard project"
  thinking_level: "high"
  include_thoughts: true
```

---

## gemini-query (Legacy)

General purpose queries to Gemini 3. Use `g3-deep-think` or `g3-think` for reasoning tasks.

```
Parameters:
- prompt (required): The query text
- model: "pro" | "flash" (default: "pro")
- thinking_level: "low" | "high" (default: "high")
- temperature: number (ALWAYS use default 1.0)
```

**Example:**
```
mcp__gemini__gemini-query
  prompt: "Analyze this code architecture and suggest improvements"
  thinking_level: "high"
```

---

## gemini-brainstorm

Multi-round brainstorming with Claude collaboration.

```
Parameters:
- prompt (required): Problem statement
- claudeThoughts (required): Claude's initial analysis
- maxRounds: 1-5 (default: 3)
```

**Best Practices:**
- Always include Claude's initial thoughts for better synthesis
- Use for architecture decisions, strategy planning
- Works best with thinking_level="high"

---

## gemini-analyze-code

Deep code analysis with configurable focus.

```
Parameters:
- code (required): Code to analyze
- language: Programming language
- focus: "quality" | "security" | "performance" | "bugs" | "general"
```

**Example:**
```
mcp__gemini__gemini-analyze-code
  code: "<paste code here>"
  language: "typescript"
  focus: "security"
```

---

## gemini-analyze-text

Text analysis with multiple modes.

```
Parameters:
- text (required): Text to analyze
- type: "sentiment" | "summary" | "entities" | "key-points" | "general"
```

---

## gemini-summarize

Flexible summarization tool.

```
Parameters:
- content (required): Content to summarize
- length: "brief" | "moderate" | "detailed"
- format: "paragraph" | "bullet-points" | "outline"
```
