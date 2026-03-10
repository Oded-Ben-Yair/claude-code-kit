# Hey Seven Interview Debrief — 2026-02-17

**Interviewer**: Brett (CTO) + Neta (R&D Site Manager)
**Candidate**: Oded Ben-Yair
**Outcome**: Oded believes he will get the offer

---

## Product Vision: SMS-Based AI Casino Host

### Core Concept
- Most Americans use SMS, not WhatsApp/Telegram
- Asking guests to download an app drastically reduces usage
- **MVP baseline**: System that works through SMS
- Casino sends the first message (outbound) to guests from existing phone number lists
- Goal: Get guests to visit the casino AND collect as much personal data as possible for personalized service

### First Interaction Flow
- Casino has lists of phone numbers (former players, hotel guests, online signups)
- CTA message to get them to come to the casino
- Simultaneously: achieve as much info as possible about the guest
- When guest arrives at the casino, they get the best customized service based on collected data

### Data Collection Strategy (Critical Feature)
- "Sub-agents" or equivalent concept whose goal is to extract guest data
- Two approaches:
  1. **Incentive-driven**: "Leave your email, get $50 for your first casino visit"
  2. **Contextual extraction**: If guest asks about restaurants → ask if they need kids menu, what ages, dietary restrictions, etc.
- Data types: ALL possible — profile (age, kids, food preferences), behavioral (what they ask about, frequency), family/companion info
- The more info we collect, the better hosting service we can provide
- Guest may have companions (spouse, kids, friends) — info about them also valuable

### Conversation Requirements
- **Stateful**: Agent MUST remember everything across sessions (kids, preferences, history)
- **100% human-like**: Guests should feel and think they're talking to a real person
  - This is critical for getting people to open up and share valuable info
  - If the agent suddenly doesn't remember they have kids → trust broken
- **Single thread**: One conversation per guest (not multiple parallel agents)
- **24/7 responses**: Won't initiate messages at night, but will reply immediately if guest texts
- **Escalation**: Must support handoff to human host when needed
- **Graceful opt-out**: When guest wants to stop, apologize gracefully, possibly offer incentive to explain why they declined

### AI Disclosure
- Start without disclosure
- Add if state regulations require it (legal team handles compliance)

### Languages
- English primary
- Spanish also needed
- Other US-relevant languages TBD (research needed)

---

## Per-Casino Architecture

### Isolation Model
- Each casino has its own database and full infrastructure
- Casinos would NOT share any info or database with other casinos
- Like duplicating the entire system per casino
- Cost-efficient approach preferred for MVP (single GCP project, namespaced)

### Scale
- Start with 1 casino at MVP launch
- Add another in a few weeks or months
- Deployment automation needed but not necessarily at day 1

---

## Content Management (Oded's Gap in Interview)

### The Problem
- Casinos need to add/change/remove info: restaurant menus, hours, events, rules, regulations
- Changes must take instant effect in the agent's knowledge
- Casino operators are NOT tech-savvy
- Need "stupid-simple" interface — system translates input to relevant format for the agent

### Examples Discussed
- "The steakhouse changed its hours"
- "We added a new show"
- Regulation updates
- Menu changes

### Oded's Gap
- Brett asked specifically how he would allow clients to manage content
- Oded didn't have a strong answer — THIS NEEDS A STRONG SOLUTION IN THE ARCHITECTURE

---

## Tech Stack (Confirmed)

| Component | Choice | Notes |
|-----------|--------|-------|
| Cloud | GCP | Confirmed |
| Agent Framework | LangGraph (latest, 1.0+) | Brett asked about hooks, pre-node validation |
| Observability/Evals | LangFuse | Brett said LangSmith is expensive. Open to best solution. |
| Embeddings/Vector | Vertex AI | Neta confirmed GCP; Brett cares deeply about embeddings |
| Multi-agent | langgraph-supervisor/swarm mentioned | Brett mentioned briefly, wants latest |
| Database | Firestore (assumed) | GCP-native, schemaless for flexible guest profiles |
| SMS | TBD (Twilio assumed) | Not discussed |
| Frontend (admin) | TBD | Non-technical users need simple content management |

### Brett's Technical Interests
- **LangGraph 1.0 hooks**: Pre-node validations, similar to middleware hooks
- **Embeddings**: Big concern — model choice, chunking strategy, retrieval quality, vector DB
- **Sub-agents**: Concept confirmed but architecture approach is open
- **Custom StateGraph**: Liked Oded's v1 approach

---

## Business Context

| Factor | Detail |
|--------|--------|
| Timeline | Weeks, not months. Clients waiting. |
| Team | Oded + Brett initially. Platform engineer joins later. |
| Starting point | Building from scratch |
| First casino | Not named |
| Building from | Scratch |

---

## Agent Personality

- Universal personality at MVP (not per-casino)
- Name TBD — research what works best for human-like feeling (casino name vs person name)
- Must feel 100% human to get guests to open up
- Creative yet compliant with casino regulations
- Mix of creativity and deterministic rules

---

## What Impressed Brett About v1
- Custom graph architecture
- Professional quality of the work
- The "stuck" demo bug was noted (4 causes diagnosed, v2 fix planned)

---

## Analytics (Not Discussed but Essential)
- Oded believes we must collect analytics to:
  - Improve the agent
  - Create better agents for next clients
- Not mentioned by Brett explicitly but strategic necessity

---

## Open Technical Questions for Research

1. LangGraph 1.0 hooks — what are they, how do they work?
2. langgraph-supervisor / langgraph-swarm — sub-agent orchestration
3. SMS platform comparison (Twilio vs alternatives)
4. SMS conversation design patterns (async, stateful)
5. Content management patterns for non-technical users
6. LangFuse vs LangSmith vs GCP-native observability
7. Vertex AI embeddings latest models + Vector Search
8. Guest progressive profiling data models
9. Per-casino deployment automation (Terraform/Pulumi)
10. SMS cost modeling at scale
11. AI disclosure laws by US state
12. Languages needed for US casino demographics
13. Best agent name/persona for human-like SMS
14. Human-like conversational AI patterns for data extraction
