---
name: azure-compliance
description: |
  Audit, plan, execute, and validate Azure resource compliance against sysadmin guidelines.
  Use this skill for:
  - Auditing project compliance (naming, tags, region, shared resources)
  - Generating rename plans with impact analysis and rollback procedures
  - Executing approved rename plans with per-operation human gates
  - Validating post-migration compliance
  - Generating portfolio-wide compliance reports

  Keywords: compliance, audit, naming convention, azure rename, migration, tags
argument-hint: "[audit|rename|execute|validate|report] [project-name|all]"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Azure Compliance Skill

## Architecture

```
/azure-compliance (this skill) -- ORCHESTRATOR
  |-- audit [project|all]    -> spawns azure-compliance agent per project
  |-- rename [project]       -> generates rename plan, HUMAN GATE
  |-- execute [project]      -> runs approved plan, per-op human approval
  |-- validate [project|all] -> live verification post-migration
  +-- report                 -> portfolio compliance dashboard
```

## Sub-Commands

### `/azure-compliance audit [project-name|all]`

Audits one or all projects against compliance rules.

1. Read `~/.claude/configs/azure-compliance-rules.json` for rules and project list
2. Read `~/.claude/skills/azure-compliance/references/project-registry.md` for resource mapping
3. For `all`: spawn one azure-compliance agent per project (max 4 parallel via Task tool)
4. For specific project: spawn single azure-compliance agent
5. Agent runs `audit` command:
   - Inventory resources via `az resource list -g Az-ai`
   - Check naming convention compliance via regex
   - Check required tags (Brand, Project, Environment)
   - Check region compliance (swedencentral)
   - Scan code for resource name references
6. Results saved to `~/.claude/compliance-state.json`
7. Display summary table:

```
| Project          | Naming | Tags | Region | Overall |
|------------------|--------|------|--------|---------|
| Sentimark        | FAIL   | FAIL | PASS   | FAIL    |
| Phone Spam       | PASS   | PASS | PASS   | PASS    |
```

### `/azure-compliance rename [project-name]`

Generates a rename plan for a non-compliant project.

1. Load audit results from `~/.claude/compliance-state.json` (must run audit first)
2. If no audit results exist, abort with: "Run `/azure-compliance audit <project>` first"
3. Spawn azure-compliance agent to generate rename plan
4. Agent reads `~/.claude/skills/azure-compliance/references/rename-safety.md` for per-resource procedures
5. Agent fills rename-plan template with:
   - Impact analysis: pipeline refs, code refs, Key Vault secrets, DNS entries
   - Step-by-step Azure CLI commands (create new, migrate settings, verify)
   - Rollback procedures per operation
   - Risk assessment (Low/Medium/High per resource)
   - Estimated downtime per resource
6. **HUMAN GATE**: Present complete plan for approval
   - Do NOT proceed without explicit "approved" from user
   - User may request modifications to the plan
7. On approval: update `~/.claude/compliance-state.json` with `plan_status: "approved"`

### `/azure-compliance execute [project-name]`

**DESTRUCTIVE OPERATION -- Multiple human gates required.**

1. Load APPROVED plan from `~/.claude/compliance-state.json`
2. Verify `plan_status == "approved"` -- reject if not approved
3. Spawn azure-compliance agent to execute the plan
4. Agent executes each rename operation ONE AT A TIME:
   a. Display operation details (current name -> target name, CLI commands)
   b. Wait for explicit "proceed" approval from user
   c. Create new resource via Azure CLI
   d. Migrate app settings from old to new
   e. Deploy code to new resource
   f. Verify health endpoint responds on new resource
   g. Log result to `~/.claude/compliance-state.json`
   h. If any step fails: STOP, preserve old resource, report failure
5. After all resources created and verified:
   - Update `azure-pipelines.yml` to reference new resource names
   - Update code references (connection strings, URLs, resource names)
   - Update Key Vault secrets if values contain old resource names
6. Run validation checklist on all new resources
7. Set 7-day grace period: old resources remain active as rollback targets
8. **Max 1 project per session** -- prevents cascading failures

### `/azure-compliance validate [project-name|all]`

Validates live compliance state of resources.

1. For `all`: check every project in the registry
2. For specific project: check that project only
3. Spawn azure-compliance agent per project
4. Agent runs validation checks:
   - Resource exists with correct name: `az resource show`
   - Required tags present: `az resource show --query tags`
   - Health endpoint responds: `curl -s https://<resource>.azurewebsites.net/api/health`
   - Pipeline YAML references correct resource names
   - Code references match live resource names
5. Update `~/.claude/compliance-state.json` with validation results
6. Display results table with PASS/FAIL per check

### `/azure-compliance report`

Generates a portfolio-wide compliance dashboard.

1. Load `~/.claude/compliance-state.json`
2. Aggregate results across all projects from `~/.claude/skills/azure-compliance/references/project-registry.md`
3. Generate summary:
   - Total resources: X
   - Compliant: Y (Z%)
   - Non-compliant: W
   - In-progress migrations: V
   - Grace period (pending decommission): U
4. Per-project breakdown with last audit date
5. Display as formatted table

---

## State Management

State persists in `~/.claude/compliance-state.json`:

- Schema: `~/.claude/schemas/compliance-state.json`
- State file is created on first audit run
- Can be re-initialized by deleting the file and re-running audit
- Each project has its own section tracking:
  - `audit_results`: per-rule pass/fail with details
  - `plan_status`: none / draft / approved / executing / completed
  - `execution_progress`: per-resource operation status
  - `validation_results`: per-check pass/fail
  - `grace_period_end`: ISO date for decommission eligibility

---

## Integration with Existing Skills

| Scenario | Reference |
|----------|-----------|
| Azure CLI operations | `~/.claude/skills/azure-unified/` |
| Deployment safety | `~/.claude/rules/azure-deploy.md` |
| Database safety | `~/.claude/rules/db-safety.md` |
| Pipeline changes | `~/.claude/checklists/before-deploy.md` |
| Resource-type procedures | `~/.claude/skills/azure-compliance/references/rename-safety.md` |
| Project registry | `~/.claude/skills/azure-compliance/references/project-registry.md` |

---

## Configuration

| Item | Path |
|------|------|
| Compliance rules | `~/.claude/configs/azure-compliance-rules.json` |
| Templates | `~/.claude/templates/compliance/` |
| Agent definition | `~/.claude/agents/azure-compliance.md` |
| Reference docs | `~/.claude/skills/azure-compliance/references/` |
| Persistent state | `~/.claude/compliance-state.json` |

---

## Prerequisites

- Azure CLI authenticated: `az account show`
- Subscription set: `az account set --subscription "U-BTech - CSP (Z-Online)"`
- Access to resource group: `az group show -n AZAI_group`
- Key Vault access: `az keyvault secret list --vault-name kv-seekapa-apps`
