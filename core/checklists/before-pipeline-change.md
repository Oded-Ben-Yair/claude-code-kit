# Before Pipeline Change Checklist

Surface when: modifying multi-stage pipelines, transcription, audio/text processing, LLM output parsing.

## Understand the Pipeline

- [ ] Read existing pipeline code before modifying
- [ ] Map all stages: input → processing → output
- [ ] Identify format contracts between stages

## Format Contracts

- [ ] Single canonical format defined in ONE shared constant/module
- [ ] Never run AI cleanup AFTER formatting (AI destroys structured labels)
- [ ] Run cleanup on RAW text first, THEN apply formatting
- [ ] Post-format validation is READ-ONLY (warnings, never modify)

## Multi-Language Safety

- [ ] Check `language_code` and branch processing logic
- [ ] Arabic: split on `\n+`, include `؟`, lower thresholds
- [ ] Latin: split on `[.!?¿¡。،]`
- [ ] Test with real STT output from each supported language

## LLM Output Parsing

- [ ] Use permissive regex extraction, NOT exact string matching
- [ ] Add fallback parser
- [ ] Log raw LLM response (first 200 chars) for debugging
- [ ] Assert expected output count matches input count

## String Templating

- [ ] NEVER use `.format()` on strings with user-generated text
- [ ] Use `%%PLACEHOLDER%%` replacement pattern instead

## Post-Change Quality Gate (MANDATORY)

- [ ] Run a REAL input through the full pipeline
- [ ] Assert OUTPUT properties (segment count, speaker count, length ratio)
- [ ] Never claim "fixed" based on status=completed alone
- [ ] Never claim "fixed" based on unit tests alone

## References

- `rules/pipeline-safety.md`: All pipeline rules
