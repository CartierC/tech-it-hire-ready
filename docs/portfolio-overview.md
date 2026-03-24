## Portfolio Overview

This repository is the **master hub** for my cloud/infra/security portfolio.

## How this portfolio is structured

- **Hub (this repo)**: recruiter-first navigation + standards + templates
- **Spoke repos**: each project is isolated, documented, reproducible, and verifiable

## What to look for (recruiter guidance)

- **Runbooks**: step-by-step deployment and validation
- **Security controls**: least privilege, hardening, and threat-model thinking
- **Verification evidence**: commands executed, outputs captured, logs attached
- **Cleanup steps**: cost control and safe teardown

## Project Registry (high-level)

> Each spoke repo contains:
> - `runbook/` (deploy, validate, cleanup)
> - `security/` (controls + threat model)
> - `verification/` (verification log w/ evidence)
> - `scripts/` (automation helpers)

### Active Spoke Repositories

- **aws-ec2-secure-deployment** — Secure EC2 + VPC baseline, IAM least privilege, validation scripts
- **linux-hardening-pack** — Linux hardening scripts + baseline configs + validation checklist
- **it-automation-python** — automation utilities and operational scripts
- **networking-labs-cli** — subnetting/VPC/networking CLI labs
- **devops-cicd-starter** — CI/CD starter patterns, linting, policy checks

## Evidence Standard

See: `docs/verification-standard.md`

## Templates

- `templates/project-spec-template.md`
- `templates/verification-log-template.md`
'@ | Set-Content -Encoding utf8 .\docs\portfolio-overview.md
