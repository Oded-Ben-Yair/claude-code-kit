# Azure Compliance -- Project Registry

Master reference of all projects in scope for Azure compliance migration.

## Project Mapping Table

| # | Project | Brand | Path | Repo | Database |
|---|---------|-------|------|------|----------|
| 1 | Sentimark | Sentimark | ~/projects/sentimark/ | sentimark | polymarket_analyzer |
| 2 | QC Analyzer | Seekapa | ~/projects/qc-call-analyzer/ | qc-call-analyzer | qc_analyzer |
| 3 | CS Agents | Seekapa | ~/projects/axia-seekapa-cs-agents/ | axia-seekapa-cs-agents | axia_seekapa_chatbot |
| 4 | Training | Seekapa | ~/projects/seekapa-training-platform/ | seekapa-training-platform | seekapa_training |
| 5 | Compliance Exam | Seekapa | ~/projects/seekapa-compliance-exam/ | seekapa-compliance-exam | compliance_exam |
| 6 | Phone Spam Checker | Seekapa | ~/projects/phone-spam-checker/ | phone-spam-checker | phone_spam_checker |
| 7 | QC Telephony | Seekapa | ~/projects/qc-telephony-api/ | qc-telephony-api | qc_analyzer |
| 8 | Real-Time Monitor | Seekapa | ~/projects/real-time/ | real-time-monitor | -- |
| 9 | Automation Fabric | Sentimark | ~/projects/sentimark/automation-fabric/ | automation-fabric | automation_fabric |
| 10 | Sales Agents | Seekapa | ~/projects/sales-agents/ | sales-agents | -- |
| 11 | AEO | TBD | ~/projects/aeo/ | aeo | -- |
| 12 | Tech4All | TBD | ~/projects/tech4all/ | tech4all | -- |
| 13 | Client Evaluation | TBD | ~/projects/client-evaluation/ | client-evaluation | -- |
| 14 | LLM Conv Router | TBD | ~/projects/llm-conv-router/ | llm-conv-router | -- |
| 15 | Video Orchestra | TBD | ~/projects/video-orchestra/ | video-orchestra | -- |

---

## Resource Rename Mapping

| # | Project | Resource Type | Current Name | Target Name | Action Required |
|---|---------|---------------|-------------|-------------|-----------------|
| 1 | Sentimark | Function App | polymarket-analyzer | func-sentimark-prod | Recreate + migrate |
| 2 | Sentimark | App Service | sentimark-v2-frontend | app-sentimark-prod | Recreate + migrate |
| 3 | QC Analyzer | Function App | qc-call-analyzer-func | func-qc-analyzer-prod | Recreate + migrate |
| 4 | QC Analyzer | SWA | icy-coast-0265d5310 | swa-qc-analyzer-prod | Helpdesk ticket |
| 5 | CS Agents | Function App | TBD | func-cs-agents-dev | Apply from start |
| 6 | Training | Function App | sales-training-platform | func-training-prod | Recreate + migrate |
| 7 | Training | SWA | gray-field-011716a03 | swa-training-prod | Helpdesk ticket |
| 8 | Compliance Exam | Function App | seekapa-compliance-exam | func-compliance-exam-prod | Recreate + migrate |
| 9 | Compliance Exam | SWA | yellow-hill-0a3781903 | swa-compliance-exam-prod | Helpdesk ticket |
| 10 | Phone Spam Checker | Function App | func-phone-spam-checker-prod | COMPLIANT | None |
| 11 | Phone Spam Checker | SWA | swa-phone-spam-checker-prod | COMPLIANT | None |
| 12 | QC Telephony | Function App | qc-telephony-api | func-qc-telephony-prod | Recreate + migrate |
| 13 | Real-Time Monitor | App Service | app-realtime-monitor | app-realtime-monitor-prod | Recreate + migrate |
| 14 | Real-Time Monitor | SWA | brave-bay-048da2703 | swa-realtime-monitor-prod | Helpdesk ticket |
| 15 | Automation Fabric | Function App | func-marketing-newsletter | func-automation-fabric-prod | Recreate + migrate |
| 16 | Automation Fabric | SWA | swa-marketing-newsletter | swa-automation-fabric-prod | Recreate + migrate |

---

## Out of Scope

| Project | Reason |
|---------|--------|
| Hey Seven | GCP Cloud Run (not Azure) |
| Khaleeji Brand Video | Dead project (directory does not exist) |

---

## Compliance Status Summary

| Status | Count | Projects |
|--------|-------|----------|
| Compliant | 1 | Phone Spam Checker |
| Non-Compliant | 9 | Sentimark, QC Analyzer, CS Agents, Training, Compliance Exam, QC Telephony, Real-Time Monitor, Automation Fabric, Sales Agents |
| Audit Needed | 4 | AEO, Tech4All, Client Evaluation, LLM Conv Router |
| Out of Scope | 2 | Hey Seven, Khaleeji Brand Video |

---

## Naming Convention Reference

### Pattern Rules

| Resource Type | Pattern | Regex |
|---------------|---------|-------|
| Function App | `func-<project>-<env>` | `^func-[a-z0-9-]+-(?:prod\|dev\|staging)$` |
| App Service | `app-<project>-<env>` | `^app-[a-z0-9-]+-(?:prod\|dev\|staging)$` |
| Static Web App | `swa-<project>-<env>` | `^swa-[a-z0-9-]+-(?:prod\|dev\|staging)$` |

### Required Tags

| Tag | Required | Valid Values |
|-----|----------|-------------|
| Brand | Yes | Sentimark, Seekapa, TBD |
| Project | Yes | Must match project name from registry |
| Environment | Yes | prod, dev, staging |

### Shared Resources (Do NOT Rename)

| Resource | Type | Used By |
|----------|------|---------|
| ASP-AZAIPROJECTS | App Service Plan | All Function Apps and App Services |
| stsentimarkv2 | Storage Account | All Function Apps |
| kv-seekapa-apps | Key Vault | All projects |
| sentimarkregistry | Container Registry | All container-based projects |
| postgres-seekapatraining-prod | PostgreSQL Server | All database-backed projects |

---

## Migration Priority

Recommended execution order (based on risk and dependencies):

| Priority | Project | Risk | Reason |
|----------|---------|------|--------|
| 1 | CS Agents | Low | Not yet deployed (apply naming from start) |
| 2 | Phone Spam Checker | None | Already compliant |
| 3 | Sales Agents | Low | Early stage, fewer dependencies |
| 4 | QC Telephony | Medium | Single Function App, limited pipeline |
| 5 | Real-Time Monitor | Medium | App Service + SWA, active users |
| 6 | Automation Fabric | Medium | Function App + SWA, automated workflows |
| 7 | Training | Medium | Function App + SWA, active users |
| 8 | Compliance Exam | Medium | Function App + SWA, production app |
| 9 | QC Analyzer | High | Function App + SWA, production app with external users |
| 10 | Sentimark | High | Function App + App Service, complex pipeline, most dependencies |

---

## Cross-Reference: Key Vault Secrets Per Project

| Project | Key Vault Secret Name | May Need Value Update |
|---------|----------------------|----------------------|
| Sentimark | Sentimark-DbConnectionString | No (DB unchanged) |
| QC Analyzer | QCAnalyzer-DbConnectionString | No (DB unchanged) |
| CS Agents | Chatbot-DbConnectionString | No (DB unchanged) |
| Training | TrainingPlatform-DbConnectionString | No (DB unchanged) |
| Compliance Exam | ComplianceExam-DbConnectionString | No (DB unchanged) |
| Phone Spam Checker | PhoneSpamChecker-DbConnectionString | No (DB unchanged) |

Note: Database connection strings do NOT change during resource renames. Only secrets containing resource URLs (e.g., Function App endpoints) need value updates.
