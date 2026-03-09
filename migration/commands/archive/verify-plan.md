---
description: Ensures your work follows the plan by comparing code changes against specifications
argument-hint: [plan_file_path]
allowed-tools: Bash(git:*)
---

# Plan Adherence Verification System

You are a senior project manager and quality assurance expert. Your task is to verify that recent development work aligns with the project plan and specifications.

## Step 1: Load and Understand the Plan

### 1.1 Read the Plan File
- **Plan location:** @$1 (or @PLAN.md or @PROJECT_PLAN.md if no argument provided)
- **Ingest the plan:** Read and understand all goals, requirements, milestones, and acceptance criteria

### 1.2 Identify Plan Structure
Extract and categorize:
- **Goals:** High-level objectives
- **Requirements:** Specific functional and non-functional requirements
- **Tasks:** Individual action items
- **Acceptance criteria:** Definition of done for each requirement
- **Timeline:** Expected completion dates or milestones

## Step 2: Analyze Recent Work

### 2.1 Git History Analysis
Review recent commits to understand what work has been completed:

```bash
!git log --oneline --since="7 days ago"
!git diff HEAD~10..HEAD --stat
```

### 2.2 Code Changes Analysis
Examine the actual code changes:
- **Files modified:** Which files were changed and why
- **Features added:** New functionality implemented
- **Bugs fixed:** Issues resolved
- **Refactoring:** Code improvements made

### 2.3 Current Work-in-Progress
Check for uncommitted or staged changes:

```bash
!git status
!git diff --staged
```

## Step 3: Plan vs. Reality Comparison

### 3.1 Completed Items
Identify and list all plan items that have been successfully completed:
- Match commits and code changes to specific plan requirements
- Verify that acceptance criteria have been met
- Confirm that the implementation aligns with the plan's specifications

### 3.2 Deviations from Plan
Identify any work that deviates from the plan:
- **Unplanned features:** Functionality added that wasn't in the plan
- **Different approach:** Implementation that differs from the planned approach
- **Scope changes:** Work that goes beyond or falls short of the plan

### 3.3 Missing or Incomplete Items
Identify plan items that have not been addressed:
- **Not started:** Tasks that haven't been begun
- **Partially complete:** Tasks that are in progress but not finished
- **Blocked:** Tasks that cannot proceed due to dependencies

## Step 4: Quality and Compliance Check

### 4.1 Requirements Traceability
For each requirement in the plan:
- **Status:** Completed, In Progress, Not Started, Blocked
- **Evidence:** Specific commits, files, or code that fulfill the requirement
- **Gaps:** Any missing elements or incomplete implementation

### 4.2 Acceptance Criteria Validation
For completed items, verify that acceptance criteria are met:
- **Functional requirements:** Does the code do what it's supposed to do?
- **Non-functional requirements:** Performance, security, scalability considerations
- **Testing:** Are there tests that validate the implementation?

### 4.3 Architecture and Design Alignment
Verify that the implementation follows:
- **Architectural patterns** specified in the plan
- **Design principles** (SOLID, DRY, etc.)
- **Technology stack** decisions outlined in the plan

## Step 5: Generate Comprehensive Report

### 5.1 Executive Summary
Provide a high-level overview:
- **Overall alignment:** Percentage of plan completed
- **Status:** On track, Behind schedule, Ahead of schedule
- **Key achievements:** Major milestones reached
- **Critical issues:** Blockers or major deviations

### 5.2 Detailed Findings

#### Completed Items
| Requirement ID | Description | Status | Evidence | Notes |
|----------------|-------------|--------|----------|-------|
| REQ-001 | User authentication | Complete | commit abc123 | Fully implemented |

#### Deviations
| Item | Planned Approach | Actual Approach | Reason | Impact |
|------|------------------|-----------------|--------|--------|
| Login flow | OAuth2 | JWT + Session | Simpler implementation | Low - still meets requirements |

#### Missing Items
| Requirement ID | Description | Priority | Blocker | Recommendation |
|----------------|-------------|----------|---------|----------------|
| REQ-005 | Password reset | High | None | Should be next priority |

#### In Progress
| Requirement ID | Description | Progress | Expected Completion | Notes |
|----------------|-------------|----------|---------------------|-------|
| REQ-003 | User profile | 60% | 2 days | On track |

### 5.3 Risk Assessment
Identify risks related to plan adherence:
- **Schedule risks:** Items behind schedule
- **Technical risks:** Deviations that may cause issues later
- **Quality risks:** Incomplete testing or documentation

### 5.4 Recommendations

#### Immediate Actions
1. **High priority items** that need attention now
2. **Blockers** that need to be resolved
3. **Quick wins** that can be completed easily

#### Next Steps
1. **Prioritized task list** for the next sprint or session
2. **Dependencies** that need to be addressed
3. **Resources** that may be needed

#### Plan Updates
Suggest updates to the plan if needed:
- **Scope adjustments** based on learnings
- **Timeline revisions** if necessary
- **New requirements** that have emerged

## Step 6: Traceability Matrix

Generate a requirements traceability matrix:

| Requirement | Planned | Implemented | Tested | Documented | Status |
|-------------|---------|-------------|--------|------------|--------|
| REQ-001 | Yes | Yes | Yes | Yes | Complete |
| REQ-002 | Yes | Yes | No | Partial | Needs testing |
| REQ-003 | Yes | In Progress | No | No | In progress |

## Output Format

Present the report in a clear, actionable format:
- **Use tables** for structured data
- **Use emojis** for quick visual scanning (Yes No Partial In Progress)
- **Use color coding** if supported (green for complete, red for missing, yellow for in-progress)
- **Provide specific line numbers and file paths** for evidence
- **Include actionable recommendations** with clear next steps

## Success Criteria

This verification is successful when:
1. Every plan item has been accounted for
2. All deviations have been identified and explained
3. A clear path forward has been established
4. The report is actionable and easy to understand
