# Azure Functions Production Rules

On-demand: Load when working with Azure Functions, Durable Functions, activity triggers, consumption plan.

## Durable Functions Data Flow

**NEVER** use @property in dataclasses crossing Azure Durable Functions boundaries.
JSON.dumps() drops @property methods. Compute values BEFORE handoff.

```python
# BAD: @property lost in serialization
@dataclass
class Item:
    value: float
    @property
    def display(self): return f"{self.value:.2f}%"  # LOST!

# GOOD: Pre-computed field
@dataclass
class Item:
    value: float
    display: str  # Computed at creation time
```

## Azure Consumption Plan Awareness (MANDATORY)

- Old code persists **12+ hours** after deploy (warm instances don't recycle immediately)
- Activity timeout: **10 minutes** per execution (Durable Functions extend this)
- `gcloud run function list` returns 0 for consumption plan apps — use health endpoint instead
- Kudu zipdeploy 504 = server still building, NOT a clean failure — wait and retry
- After deploy: verify with **real data**, not just health endpoints or function count

Origin: Sentimark Feb 2026 — 53% predictions from old code 13h after deploy. QC Analyzer — 10min timeout killed 45min call processing.

## Activity Timeout Safety (MANDATORY)

When chaining operations inside a single Azure Consumption Plan activity (10-min limit):

1. **Estimate total operation time** before starting: download + process + upload + API call
2. **Add duration guard** for input-proportional operations: `if duration_seconds < threshold`
3. **Route oversized inputs** to alternative path (text-based, chunked, split activities)
4. **Scale token/size limits with input**: `min(ceiling, max(floor, input_size * factor))`
5. **Never chain download + upload + API call** for files > 20MB in a single activity

Origin: V7.0 Feb 2026 — 41MB audio download + Gemini upload + generation exceeded 10-min timeout for 45-min calls.

## Durable Functions Activity Audit (MANDATORY after bulk file operations)

When deleting, moving, or refactoring files in an Azure Durable Functions project:

1. **Extract ALL `context.call_activity("name")` calls** from surviving orchestrator files
2. **Extract ALL `@app.activity_trigger` function names** from function_app.py
3. **Assert: called_activities ⊆ registered_activities** — every orchestrator call has a matching registration
4. **Pipeline success is NOT sufficient** — activity resolution happens at RUNTIME, not deploy time
5. **Run `test_activity_registration.py`** (or equivalent) before pushing

```bash
# Quick manual check:
grep -oP 'call_activity\("([^"]+)"' orchestrators/*.py | sort -u > /tmp/called.txt
grep -oP 'def (\w+_activity)\(' function_app.py | sort -u > /tmp/registered.txt
comm -23 /tmp/called.txt /tmp/registered.txt  # Must be empty
```

Origin: Feb 9 2026 refactor deleted 68K lines + 163 files. Pipeline passed. Email orchestrator crashed daily for 2 days because 2 activity registrations were deleted but their `call_activity()` calls survived in the orchestrator.

## Jinja2 StrictUndefined Crashes on {% if %} Guards

`StrictUndefined` throws `UndefinedError` even inside `{% if var %}` guards when `var` is completely absent from the template context dict. The guard does not protect — it IS the crash point.

- Use `LoggingUndefined` (`make_logging_undefined`) for production templates
- Add explicit `None` defaults for all optional template variables in the context dict
- Test templates with minimal context (not full context) to catch missing vars

Origin: Automation Fabric Feb 2026 — email HTML generation failed silently, returning html_size=0 for all languages.

## Size Validation Gates Must Track Template Growth

When templates grow (adding sections, enrichment, assets), update `MAX_HTML_BYTES` or equivalent size gates. Add monitoring: if size is within 10% of the maximum, log a warning for proactive threshold adjustment.

Origin: Automation Fabric Feb 2026 — V10 template grew to 124KB, silently rejected by 115KB size gate. All 4 language emails blocked.
