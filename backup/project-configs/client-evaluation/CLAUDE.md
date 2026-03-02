# Client Evaluation - Project Configuration

## Persona
You are a **Trading Analytics Engineer** specializing in retail trader performance analysis and AI-powered coaching systems.

---

## Project Overview

| Aspect | Detail |
|--------|--------|
| **Purpose** | AI-powered coaching reports for Axia/Seekapa traders |
| **Data Source** | personalassyst-be API |
| **AI Engine** | Azure OpenAI GPT-5.2 |
| **Hosting** | Azure Static Web Apps |

---

## Architecture

```
Client Portal → /api/evaluate → personalassyst API → GPT-5.2 → Visual Report
```

- **Backend**: Azure Functions (Python)
- **Frontend**: React + TypeScript + Tailwind + Recharts
- **State**: Stateless (no database)

---

## External APIs

### personalassyst API
- **Base URL**: `https://personalassyst-be-bhc7h6bkcrgnbhca.westeurope-01.azurewebsites.net`
- **Auth**: `X-API-Token` header
- **Key Location**: Azure Key Vault `kv-seekapa-apps` → `ClientEval-PersonalassystApiKey`

### Azure OpenAI
- **Model**: GPT-5.2
- **Endpoint**: Use existing Azure AI Foundry configuration
- **Key Location**: Azure Key Vault `kv-seekapa-apps`

---

## Constraints

### NEVER
- Store any trader PII in logs or database
- Cache sensitive trading data beyond request lifecycle
- Expose API keys in frontend code
- Push to GitHub (Azure DevOps only)

### ALWAYS
- Use Key Vault references for all secrets
- Validate customer_id format before API calls
- Return user-friendly error messages
- Support both English and Hebrew UI (detect from API response)

---

## File Structure

```
client-evaluation/
├── api/                    # Azure Functions (Python)
│   ├── evaluate/
│   ├── shared/
│   ├── host.json
│   └── requirements.txt
├── frontend/               # React SPA
│   ├── src/
│   │   ├── components/
│   │   ├── services/
│   │   └── types/
│   └── package.json
├── staticwebapp.config.json
└── CLAUDE.md
```

---

## Development Commands

```bash
# Backend (from /api)
func start                          # Run locally

# Frontend (from /frontend)
npm run dev                         # Start dev server
npm run build                       # Production build

# Deployment
az staticwebapp deploy              # Deploy to Azure
```

---

## Testing

- **API**: Test with sample customer_id from personalassyst
- **Frontend**: Mock API responses for component testing
- **E2E**: Use Playwright for full flow testing

---

## Branding

Use **Seekapa brand colors and typography**:
- Primary: Seekapa blue
- Success: Green (#22c55e)
- Warning: Amber (#f59e0b)
- Error: Red (#ef4444)

---

## AI Prompt Guidelines

When generating coaching insights:
1. Be encouraging but honest
2. Highlight 1-2 specific strengths
3. Identify 1-2 areas for improvement with actionable advice
4. Suggest one learning topic based on trading patterns
5. Keep language accessible (no jargon)
6. Respect the trader's experience level
