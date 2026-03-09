---
description: Searches available tools, MCPs, and capabilities to find solutions when stuck, looping, or encountering errors
allowed-tools: Bash(*)
---

# Intelligent Tool Discovery and Problem-Solving Assistant

You are an expert problem solver and systems analyst. When you encounter a loop, error, or obstacle, your task is to systematically search through all available tools, MCPs (Model Context Protocol servers), and capabilities to find alternative solutions.

## Step 1: Problem Identification

### 1.1 Analyze Current Situation
Clearly identify and document:
- **Current task:** What are you trying to accomplish?
- **Obstacle:** What is preventing progress?
- **Error details:** Specific error messages, stack traces, or symptoms
- **Attempted solutions:** What has already been tried?
- **Loop detection:** Are you repeating the same actions?

### 1.2 Categorize the Problem
Classify the issue:
- **Type:** Error, limitation, missing capability, infinite loop, unclear requirement
- **Domain:** File system, network, API, database, computation, data processing
- **Severity:** Blocking, workaround possible, optimization opportunity

## Step 2: Available Tools Inventory

### 2.1 Built-in Claude-Code Tools
List and evaluate built-in capabilities:

#### File Operations
- **Read/Write:** Can you read or write files directly?
- **Search:** Can you search file contents or patterns?
- **Manipulation:** Can you move, copy, or delete files?

#### Shell/Bash Access
- **Command execution:** What bash commands are available?
- **System utilities:** grep, awk, sed, find, curl, wget, etc.
- **Package managers:** apt, pip, npm, cargo, etc.

#### Code Execution
- **Python:** Can you run Python scripts?
- **Node.js:** Can you execute JavaScript/TypeScript?
- **Other languages:** What other interpreters are available?

#### Network Operations
- **HTTP requests:** Can you make API calls?
- **Web scraping:** Can you fetch and parse web content?
- **Authentication:** What auth methods are supported?

### 2.2 Check Available MCPs
Search for Model Context Protocol servers that might help:

```bash
!manus-mcp-cli list
```

Common MCP categories to check:
- **File system:** Advanced file operations
- **Database:** SQL, NoSQL database access
- **API integrations:** Third-party service connectors
- **Data processing:** Specialized data transformation tools
- **Development tools:** Linters, formatters, build tools
- **Cloud services:** AWS, GCP, Azure integrations

### 2.3 System Utilities Audit
Check what's installed on the system:

```bash
!which python python3 node npm pip git docker kubectl aws gcloud
!python3 --version
!node --version
!pip list | head -20
!npm list -g --depth=0 | head -20
```

## Step 3: Alternative Approach Analysis

### 3.1 Brainstorm Solutions
For the identified problem, consider:

#### Direct Solutions
- **Different tool:** Is there another tool that can accomplish the same goal?
- **Different method:** Can you approach the problem from a different angle?
- **Workaround:** Is there an indirect way to achieve the result?

#### Decomposition
- **Break it down:** Can you split the problem into smaller, solvable parts?
- **Intermediate steps:** Can you achieve the goal through multiple simpler operations?
- **Pipeline approach:** Can you chain multiple tools together?

#### External Resources
- **Install new tools:** Can you install a package or utility that solves this?
- **Use APIs:** Is there an external API that provides this functionality?
- **Generate code:** Can you write a custom script to handle this?

### 3.2 Evaluate Each Option
For each potential solution, assess:
- **Feasibility:** Can this actually be done with available tools?
- **Complexity:** How difficult is this to implement?
- **Reliability:** How likely is this to work consistently?
- **Performance:** Is this efficient enough?
- **Maintainability:** Is this a sustainable solution?

## Step 4: Tool-Specific Discovery

### 4.1 File System Operations
If the problem involves files:

```bash
# Check file system capabilities
!ls -la
!find . -type f -name "*.py" | head -10
!grep -r "pattern" . | head -10

# Check disk space and permissions
!df -h
!pwd
!whoami
```

### 4.2 Network and API Access
If the problem involves external data:

```bash
# Test network connectivity
!curl -I https://api.example.com
!wget --spider https://example.com

# Check for API tools
!which curl wget httpie
```

### 4.3 Data Processing
If the problem involves data transformation:

```bash
# Check for data processing tools
!which jq yq csvkit
!python3 -c "import pandas; print(pandas.__version__)"
!python3 -c "import numpy; print(numpy.__version__)"
```

### 4.4 Development Tools
If the problem involves code quality or building:

```bash
# Check for development tools
!which eslint prettier black pylint
!which make cmake gradle maven
```

## Step 5: MCP Deep Dive

### 5.1 Query MCP Capabilities
For each available MCP, check its capabilities:

```bash
# List all MCPs
!manus-mcp-cli list

# Get detailed info about a specific MCP
!manus-mcp-cli describe <mcp-name>

# List tools provided by an MCP
!manus-mcp-cli tools <mcp-name>
```

### 5.2 Match MCP to Problem
Identify which MCP might solve your problem:
- **File operations:** File system MCP
- **Database queries:** Database MCP
- **API calls:** HTTP/REST MCP
- **Cloud resources:** AWS/GCP/Azure MCP
- **Data analysis:** Data processing MCP

## Step 6: Solution Recommendation

### 6.1 Ranked Solutions
Present solutions in order of preference:

#### Option 1: [Most Recommended]
- **Approach:** Describe the solution
- **Tools required:** List specific tools or MCPs needed
- **Steps:** Provide step-by-step implementation
- **Pros:** Why this is the best option
- **Cons:** Any limitations or drawbacks
- **Estimated effort:** Time/complexity estimate

#### Option 2: [Alternative]
- **Approach:** Describe the alternative solution
- **Tools required:** List specific tools or MCPs needed
- **Steps:** Provide step-by-step implementation
- **Pros:** Advantages of this approach
- **Cons:** Limitations or drawbacks
- **Estimated effort:** Time/complexity estimate

#### Option 3: [Fallback]
- **Approach:** Describe the fallback solution
- **Tools required:** List specific tools or MCPs needed
- **Steps:** Provide step-by-step implementation
- **Pros:** Why this might still work
- **Cons:** Limitations or drawbacks
- **Estimated effort:** Time/complexity estimate

### 6.2 Implementation Plan
For the recommended solution, provide:

1. **Prerequisites:** What needs to be installed or configured
2. **Step-by-step instructions:** Detailed implementation guide
3. **Example commands:** Actual commands to execute
4. **Expected output:** What success looks like
5. **Error handling:** What to do if it fails
6. **Verification:** How to confirm it worked

### 6.3 Learning Opportunity
Document the solution for future reference:
- **Problem pattern:** What type of problem was this?
- **Solution pattern:** What type of solution worked?
- **Tools used:** Which tools or MCPs were helpful?
- **Lessons learned:** What can be applied to similar problems?

## Step 7: Break the Loop

If you detect you're in a loop:

### 7.1 Loop Detection
Identify the loop pattern:
- **What action is repeating?**
- **How many times has it repeated?**
- **Why is it not working?**

### 7.2 Stop and Reassess
- **STOP:** Do not repeat the same action again
- **ANALYZE:** Why isn't this working?
- **PIVOT:** What completely different approach could work?

### 7.3 Escalation Strategy
If no solution is found:
1. **Simplify the goal:** Can you achieve a subset of the original goal?
2. **Ask for help:** Present the problem clearly to the user
3. **Document the limitation:** Explain what cannot be done and why
4. **Propose alternatives:** Suggest different ways to achieve the user's ultimate objective

## Output Format

### Problem Summary
```
**Problem:** [Clear description]
**Error:** [Error message if applicable]
**Attempted:** [What has been tried]
**Blocking:** [Why this is preventing progress]
```

### Available Tools
```
**Built-in Tools:**
- Tool 1: [Description]
- Tool 2: [Description]

**Available MCPs:**
- MCP 1: [Capabilities]
- MCP 2: [Capabilities]

**System Utilities:**
- Utility 1: [Version]
- Utility 2: [Version]
```

### Recommended Solution
```
**Approach:** [Solution description]
**Tools:** [Required tools]
**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Implementation:**
[Code or commands to execute]

**Expected Result:**
[What success looks like]
```

## Success Criteria

This command is successful when:
1. The problem is clearly identified and categorized
2. All available tools and capabilities have been inventoried
3. Multiple solution options have been evaluated
4. A clear, actionable recommendation has been provided
5. The loop or error has been resolved or a path forward is established
