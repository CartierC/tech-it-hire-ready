# Screenshots

This directory holds visual evidence from portfolio projects — terminal output, CI runs, AWS console views, and tool results.

Screenshots are optional supporting proof. The primary evidence is always in `/verification/verification-log.md` within each repo.

---

## Naming Convention

```
<repo-name>_<what-it-shows>_<YYYY-MM-DD>.png
```

Examples:
- `aws-ec2-secure-deployment_ec2-running_2026-04-29.png`
- `devops-cicd-starter_ci-passing_2026-04-29.png`
- `linux-hardening-pack_firewall-rules_2026-04-29.png`

---

## What to Capture (by repo)

| Repo | Useful Screenshots |
|---|---|
| aws-ec2-secure-deployment | EC2 instance running in console, security group rules, IAM policy summary |
| it-automation-python | Terminal showing script running and output |
| networking-labs-cli | Terminal output from networking commands (dig, traceroute, subnet calc) |
| linux-hardening-pack | SSH config diff, UFW status output, before/after hardening |
| devops-cicd-starter | GitHub Actions run passing, artifact download page |
| aios | Agent output, tool-use trace, or architecture diagram |

---

## Sanitization Checklist

Before adding any screenshot:

- [ ] No AWS account IDs visible (or redacted)
- [ ] No IP addresses that reveal infrastructure (blur or redact)
- [ ] No API keys, tokens, or credentials visible
- [ ] No personal data visible
- [ ] File size under 1MB (compress if needed)

---

## Current Contents

*(Add screenshots here as repos are completed and deployed)*
