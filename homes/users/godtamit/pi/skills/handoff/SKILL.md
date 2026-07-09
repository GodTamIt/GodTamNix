---
name: handoff
description: Shared return-payload contract for all subagents; defines the HANDOFF block format and budget rules
---

# HANDOFF contract

End every run by emitting exactly one HANDOFF block and nothing after it. Markdown,
not JSON: the consumer is the parent LLM, and code snippets must not be string-escaped.
Fixed field order so the parent can scan positionally.

```markdown
## HANDOFF

**task:** <restatement of the dispatched task, one line>
**status:** complete | partial | blocked
**confidence:** high | medium | low — <one clause why, only if not high>

### Result

<role-specific body — see your own Result spec>

### Evidence

<paths:line-ranges | urls | test ids — bare references, no excerpts unless your
Result spec calls for them>

### Gaps

<what was omitted, unresolved, or truncated; "none" if clean>
```

## Budget rules (apply to the HANDOFF only, not internal work)

- Default budget: ~800 tokens. If the dispatch contains `depth: deep`: up to ~2000.
- Compress by omission, not truncation: drop whole low-priority findings and name
  them in Gaps. Never clip a finding, code sketch, or failure entry mid-item — a
  complete subset beats a clipped superset.
- No tool transcripts, no raw logs, no filler prose inside the HANDOFF.
