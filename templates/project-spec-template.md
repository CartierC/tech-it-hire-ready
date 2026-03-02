@'
# Project Spec Template

## Project Name
**<repo-name>**

## Objective
What will be built and what “done” means.

## Scope
### In scope
- <item>
### Out of scope
- <item>

## Architecture
- Services/components:
  - <service> — <purpose>
- Diagram (optional): link or embed

## Security & Compliance Notes
- IAM / access model:
- Network controls:
- Hardening:
- Logging/monitoring:
- Data handling:

## Implementation Plan
1) <step>
2) <step>
3) <step>

## Verification Plan (must be reproducible)
- Validation commands:
  - `<command>`
- Expected outputs:
  - `<expected>`

## Rollback / Cleanup
- Cleanup steps:
- Cost controls:

## Risks & Mitigations
- Risk:
- Mitigation:

## Deliverables Checklist
- [ ] `README.md` updated
- [ ] `runbook/deploy.md`
- [ ] `runbook/validate.md`
- [ ] `runbook/cleanup.md`
- [ ] `security/controls.md`
- [ ] `security/threat-model.md`
- [ ] `verification/verification-log.md`
- [ ] `scripts/` present and documented
'@ | Set-Content -Encoding utf8 .\templates\project-spec-template.md