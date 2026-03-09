# Ultra-Plan Command

You are creating an implementation plan and must validate it against Claude Code's full capabilities before presenting it.

## Automatic Validation Protocol

Execute this validation workflow BEFORE presenting any plan:

### Step 1: Launch Parallel Validation Agents

Launch ALL 5 agents concurrently in a SINGLE message using multiple Task tool calls:

**Agent 1: Claude Code Docs Validator**
```
Task tool with prompt:
"Fetch the latest Claude Code documentation from docs.claude.com focusing on:
- Parallel agent patterns and orchestration
- Task tool subagent types (Explore, Plan, general-purpose, code-reviewer)
- Latest MCP integration best practices
- Git worktree workflows and branching strategies

Return: List of latest patterns and capabilities that are not commonly used but should be leveraged."
```

**Agent 2: MCP Tools Inventory**
```
Task tool with prompt:
"Inventory ALL available MCP tools by listing every mcp__* function available in this Claude Code instance.

Categorize by:
- mcp__filesystem__* (file operations: read, write, edit, directory ops, search)
- mcp__github__* (repository operations: repos, PRs, issues, commits, branches)
- mcp__perplexity__* (research: search, reason, deep_research)
- mcp__memory__* (knowledge graph: entities, relations, observations)
- mcp__sequential-thinking__* (chain-of-thought reasoning)

Return: Complete tool inventory with specific use cases for each tool."
```

**Agent 3: Skills Registry Checker**
```
Task tool with prompt:
"Check the skills registry at $HOME/.claude/skills/ and list all available skills.

Categorize by:
- superpowers:* (brainstorming, planning, debugging, testing, git-worktrees, etc.)
- document-skills:* (xlsx, docx, pptx, pdf manipulation)
- example-skills:* (algorithmic-art, canvas-design, webapp-testing, etc.)
- Custom skills (ai-content-generation, voice-agent-*, elevenlabs-*, etc.)

Return: Skills that are applicable to the current planning context with how they enhance the plan."
```

**Agent 4: Git Worktree Analyzer**
```
Task tool with prompt:
"Analyze the current git status and branch complexity to determine if git worktree should be used.

Check:
- Is this isolated feature work that could conflict with main tree?
- Current working tree state (clean, dirty, conflicts?)
- Branch complexity (multiple developers, long-lived feature?)
- Risk of conflicts with ongoing work

Return: Clear Yes/No recommendation for using superpowers:using-git-worktrees skill with detailed justification."
```

**Agent 5: Orchestration Pattern Identifier**
```
Task tool with prompt:
"Identify orchestration opportunities for this implementation plan.

Analyze:
- Can independent tasks run in parallel? (spawn multiple Task agents concurrently)
- Should we delegate to specialized agents? (code-reviewer for review, Explore for codebase analysis, Plan for sub-planning)
- Can we use manus MCP for complex multi-step autonomous tasks?
- Should we use sequential-thinking MCP for complex reasoning chains?
- Are there opportunities for validation in parallel with implementation?

Return: Specific orchestration pattern recommendations with examples of how to implement them."
```

### Step 2: Wait for All Agents to Complete

Do NOT proceed until all 5 agents have returned results. Process all results together.

### Step 3: Generate Capability Matrix

Create this matrix from agent results:

```markdown
## Capability Matrix

| Feature | Available | Used in Plan | Enhancement Opportunity |
|---------|-----------|--------------|-------------------------|
| Parallel Agents | ✅ | ✅/❌ | [From Agent 1 & 5] |
| MCP Filesystem | ✅ | ✅/❌ | [From Agent 2] |
| MCP GitHub | ✅ | ✅/❌ | [From Agent 2] |
| MCP Perplexity | ✅ | ✅/❌ | [From Agent 2] |
| MCP Memory | ✅ | ✅/❌ | [From Agent 2] |
| Sequential Thinking | ✅ | ✅/❌ | [From Agent 2 & 5] |
| Skills (list) | ✅ | ✅/❌ | [From Agent 3] |
| Git Worktree | ✅ | ✅/❌ | [From Agent 4] |
| Orchestration | ✅ | ✅/❌ | [From Agent 5] |
```

### Step 4: Enhance the Draft Plan

Take the original naive plan and enhance it with:

1. **Parallel Agent Steps**
   - Replace sequential exploration with parallel agent launches
   - Example: Instead of "Research codebase then analyze", use "Launch 3 agents concurrently: Agent 1 explores, Agent 2 analyzes patterns, Agent 3 checks docs"

2. **MCP Tool Integration**
   - Replace basic operations with MCP tools
   - Example: Instead of "Read files", use "mcp__filesystem__read_multiple_files for parallel reading"
   - Example: Instead of "Create PR", use "mcp__github__create_pull_request with full metadata"

3. **Skills Integration**
   - Add skill invocations where applicable
   - Example: If git worktree recommended, add "Use superpowers:using-git-worktrees skill to setup isolated workspace"
   - Example: For complex plans, add "Use superpowers:brainstorming before implementation"

4. **Git Worktree Setup**
   - If Agent 4 recommends worktree, add setup phase
   - Include superpowers:using-git-worktrees skill invocation

5. **Orchestration Patterns**
   - Implement parallel execution where identified
   - Add agent delegation steps
   - Use sequential-thinking for complex reasoning

### Step 5: Generate Validation Report

Include this report with the enhanced plan:

```markdown
## 🔍 Plan Validation Report

### Capabilities Leveraged:
- ✅ Latest Claude Code patterns (from docs.claude.com)
  - [List specific patterns from Agent 1]
- ✅ Parallel agents (X agents spawned concurrently)
  - [List parallel execution points]
- ✅ MCP tools (specific tools used)
  - [List from Agent 2: mcp__filesystem__*, mcp__github__*, etc.]
- ✅ Skills (applicable skills integrated)
  - [List from Agent 3 with how they're used]
- ✅ Git worktree ([Yes/No] - [Agent 4 justification])
- ✅ Orchestration (pattern: [Agent 5 recommendation])

### Opportunities Identified:
- **Parallel Execution**: [Describe concurrent tasks from Agent 5]
- **Skill Integration**: [List skills from Agent 3]
- **MCP Enhancements**: [List tools from Agent 2]
- **Agent Delegation**: [Specialized agents from Agent 5]
- **Sequential Thinking**: [Complex reasoning chains from Agent 5]

### Plan Enhancement Summary:
[2-3 sentences describing how this plan was enhanced beyond naive linear implementation]

### Validation Agent Results:

**Agent 1 (Claude Code Docs):**
[Latest patterns found]

**Agent 2 (MCP Tools):**
[Tools inventory summary]

**Agent 3 (Skills):**
[Applicable skills found]

**Agent 4 (Git Worktree):**
[Recommendation + rationale]

**Agent 5 (Orchestration):**
[Pattern recommendations]
```

### Step 6: Present Enhanced Plan

Present the enhanced plan WITH the validation report to the user.

Format:
```markdown
# Implementation Plan for [Task]

## 🔍 Plan Validation Report
[Full validation report from Step 5]

## Enhanced Implementation Plan

### Phase 1: [Enhanced with parallel agents, MCP tools, skills]
...

### Phase 2: [Enhanced with orchestration patterns]
...

### Phase 3: [Enhanced with git worktree if recommended]
...
```

## Critical Rules

1. **ALWAYS launch all 5 agents in parallel** (single message with 5 Task calls)
2. **NEVER skip validation** even for "simple" plans
3. **ALWAYS include validation report** in final plan presentation
4. **ALWAYS enhance the plan** with at least 3 identified opportunities
5. **NEVER present naive linear plans** without validation

## Success Criteria

Validation is successful when:
- ✅ All 5 agents completed
- ✅ Capability matrix generated
- ✅ At least 3 enhancements identified
- ✅ Validation report complete
- ✅ Plan leverages parallel execution
- ✅ Applicable skills referenced
- ✅ MCP tools integrated
- ✅ Enhanced plan presented

## Integration

This command integrates with:
- **Skill**: plan-ultra-validator at ~/.claude/skills/plan-ultra-validator/SKILL.md
- **Agent**: plan_validation_orchestrator at ~/.claude/agents/plan_validation_orchestrator.json
- **Protocol**: Ultra-Planning Protocol in ~/.claude/CLAUDE.md
- **Hook**: user-prompt-submit-hook (optional auto-trigger)

---

**Execute this validation workflow NOW before presenting any implementation plan.**
