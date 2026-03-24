# Verification Standard (Evidence-First)

Every project in this portfolio follows the same evidence standard:
**a reviewer must be able to reproduce or validate outcomes quickly.**

## Minimum artifacts required (per spoke repo)

### 1) Runbook
- `runbook/deploy.md` — exact steps + commands used
- `runbook/validate.md` — how to confirm it works (tests/queries/checks)
- `runbook/cleanup.md` — teardown to avoid cost + restore environment

### 2) Security documentation
- `security/controls.md` — the controls implemented and why
- `security/threat-model.md` — risks, mitigations, assumptions

### 3) Verification evidence
- `verification/verification-log.md` — timestamped proof:
  - environment used (region, OS, versions)
  - commands executed
  - outputs captured (sanitized)
  - pass/fail notes and remediation

### 4) Automation
- `scripts/` — helper scripts that reduce manual steps and enforce consistency

## What counts as proof

- CLI outputs (sanitized)
- configuration diffs (before/after)
- screenshots (optional, not required)
- short “why this matters” notes for security choices

## Quality bar

- Steps are **idempotent when possible**
- Assumptions are stated
- Cleanup is explicit
- No secrets committed (ever)
'@ | Set-Content -Encoding utf8 .\docs\verification-standard.md
