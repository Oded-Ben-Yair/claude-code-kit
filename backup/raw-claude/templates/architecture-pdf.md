# {{PROJECT_NAME}} Architecture Document

**Version**: {{VERSION}}
**Last Updated**: {{DATE}}
**Status**: Draft | Review | Approved

---

## Executive Summary

{{ONE_PARAGRAPH_SUMMARY}}

---

## 1. System Overview

### 1.1 Purpose
{{WHAT_THE_SYSTEM_DOES}}

### 1.2 Key Stakeholders
| Role | Name/Team | Concerns |
|------|-----------|----------|
| {{ROLE}} | {{NAME}} | {{CONCERNS}} |

### 1.3 High-Level Architecture

```
┌─────────────────────────────────────────────┐
│                  FRONTEND                    │
│  {{FRONTEND_TECH}}                          │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│                   API                        │
│  {{API_TECH}}                               │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│                DATABASE                      │
│  {{DB_TECH}}                                │
└─────────────────────────────────────────────┘
```

---

## 2. Component Architecture

### 2.1 {{COMPONENT_1_NAME}}

**Purpose**: {{PURPOSE}}

**Technology Stack**:
- {{TECH_1}}
- {{TECH_2}}

**Key Files**:
```
src/
├── {{FILE_1}}  # {{DESCRIPTION}}
├── {{FILE_2}}  # {{DESCRIPTION}}
└── {{DIR}}/
    └── {{FILE_3}}
```

**Interfaces**:
| Interface | Type | Description |
|-----------|------|-------------|
| {{INTERFACE}} | REST/GraphQL/Event | {{DESCRIPTION}} |

### 2.2 {{COMPONENT_2_NAME}}

(Repeat structure for each major component)

---

## 3. Data Architecture

### 3.1 Database Schema

```sql
-- Key tables
{{SCHEMA_SQL}}
```

### 3.2 Data Flow

```
User Action → {{STEP_1}} → {{STEP_2}} → {{STEP_3}} → Response
```

### 3.3 External Data Sources
| Source | Type | Frequency | Purpose |
|--------|------|-----------|---------|
| {{SOURCE}} | API/DB/File | Real-time/Batch | {{PURPOSE}} |

---

## 4. Integration Architecture

### 4.1 External Services

| Service | Purpose | Auth Method | Rate Limits |
|---------|---------|-------------|-------------|
| {{SERVICE}} | {{PURPOSE}} | {{AUTH}} | {{LIMITS}} |

### 4.2 Internal Services

```
Service A ──REST──▶ Service B
    │
    └──Events──▶ Service C
```

---

## 5. Security Architecture

### 5.1 Authentication
- Method: {{AUTH_METHOD}}
- Provider: {{PROVIDER}}
- Token lifetime: {{LIFETIME}}

### 5.2 Authorization
- Model: RBAC/ABAC/Custom
- Roles: {{ROLES}}

### 5.3 Data Protection
- Encryption at rest: {{YES/NO}}
- Encryption in transit: {{YES/NO}}
- PII handling: {{APPROACH}}

---

## 6. Deployment Architecture

### 6.1 Infrastructure

| Component | Azure Resource | Configuration |
|-----------|----------------|---------------|
| Frontend | Static Web App | {{CONFIG}} |
| API | Functions/Container | {{CONFIG}} |
| Database | PostgreSQL Flexible | {{CONFIG}} |

### 6.2 CI/CD Pipeline

```
Push → Build → Test → Deploy (Staging) → Manual Approval → Deploy (Prod)
```

### 6.3 Environments

| Environment | URL | Purpose |
|-------------|-----|---------|
| Development | localhost:{{PORT}} | Local dev |
| Staging | {{STAGING_URL}} | Testing |
| Production | {{PROD_URL}} | Live |

---

## 7. Monitoring & Observability

### 7.1 Logging
- Platform: Application Insights / {{OTHER}}
- Log levels: Error, Warn, Info, Debug
- Retention: {{DAYS}} days

### 7.2 Metrics
| Metric | Threshold | Alert |
|--------|-----------|-------|
| Response time | > 2s | Yes |
| Error rate | > 1% | Yes |

### 7.3 Health Checks
- Endpoint: `/health`
- Frequency: Every {{N}} seconds

---

## 8. Decisions Log

| Date | Decision | Rationale | Status |
|------|----------|-----------|--------|
| {{DATE}} | {{DECISION}} | {{WHY}} | Implemented |

---

## 9. Future Considerations

### Planned Enhancements
1. {{ENHANCEMENT_1}}
2. {{ENHANCEMENT_2}}

### Technical Debt
1. {{DEBT_1}} - Priority: {{HIGH/MED/LOW}}
2. {{DEBT_2}} - Priority: {{HIGH/MED/LOW}}

---

## Appendix

### A. Glossary
| Term | Definition |
|------|------------|
| {{TERM}} | {{DEFINITION}} |

### B. References
- {{REFERENCE_1}}
- {{REFERENCE_2}}

---

*Generated with Claude Code Architecture Template v1.0*
