# Technical Review Guide

This guide explains how to independently verify each type of proof in this portfolio. Everything here is designed to be checked without taking anything on faith.

---

## How to Verify Python Repos (`it-automation-python`)

1. Clone the repo locally
2. Check `requirements.txt` or `pyproject.toml` for dependencies
3. Run `python3 <script>.py --help` to confirm the CLI interface works
4. Run the script against the documented test input and compare output to the sample in `/verification/`
5. Check for: input validation, error handling, clean output formatting
6. What counts as proof: the script runs, produces expected output, and handles edge cases without crashing

**What to look for:** Readable code, functions that do one thing, no hardcoded credentials, working CLI flags.

---

## How to Verify Bash/Linux Repos (`linux-hardening-pack`, hub scripts)

1. Read `/runbook/deploy.md` for the full step sequence
2. Check each command for: idempotency, variable quoting, error handling (`set -e`, `set -u`)
3. Run `bash -n <script>.sh` to syntax-check without executing
4. If you have a test VM, run the script and compare output to `/verification/verification-log.md`
5. Check `/runbook/cleanup.md` — teardown should be explicit, not assumed

**What to look for:** Commands that can be re-run safely, explicit assumptions stated, no `sudo` abuse, clear pass/fail output.

---

## How to Verify GitHub Actions (`devops-cicd-starter`, this hub)

1. Open `.github/workflows/` in the repo
2. Read the workflow YAML — jobs, steps, triggers, and conditions
3. Click the **Actions** tab in GitHub to see actual run history
4. Check: did the workflow pass on the last push? Are artifacts retained?
5. Look for: proper secret handling (secrets not hardcoded), job dependencies, meaningful step names

**What to look for:** Workflows that fail loudly on real errors, not just green builds that check nothing. Artifact uploads that produce reviewable output.

**In this hub specifically:** Three workflows run on every push — link check, markdown lint, and portfolio validator. The validator publishes a report artifact.

---

## How to Review AIOS (`aios`)

1. Read the top-level `README.md` for architecture context
2. Identify the agent entry point and tool registration pattern
3. Review how tools are defined and how the agent decides which to call
4. Check for: clear separation between agent logic and tool implementations, error handling in tool calls, logging or traceability
5. If there are integration tests, run them and check output

**What to look for:** System-level thinking — not just "it calls an LLM" but how the agent is structured, what it can do, and how failures are handled.

---

## What Sample Output Files Prove

Every verification log and sample output file in this portfolio serves a specific purpose:

| File type | What it proves |
|---|---|
| `verification/verification-log.md` | The steps were actually executed, not just written down |
| `sample-output/` files | The tool produces the documented output on real input |
| CI run artifacts | The pipeline runs in a real environment, not just locally |
| `reports/portfolio-validator-report.txt` | The hub's own validator ran and passed |

**How to check a verification log:**
- Look for timestamps (real execution has timestamps)
- Look for environment details (region, OS, version)
- Look for actual command output, not just expected output
- Look for any notes on failures or remediation — real runs have these

---

## General Verification Checklist

- [ ] Does the README explain what the project does and why?
- [ ] Are there runbook steps I can follow independently?
- [ ] Is there verification evidence (logs, output, CI history)?
- [ ] Is cleanup documented?
- [ ] Are secrets absent from the codebase? (`git log -p | grep -i secret` should return nothing)
- [ ] Does CI pass on the latest commit?

---

## Questions or Issues

If something in a repo is unclear, undocumented, or doesn't work as described, that's useful signal. The portfolio is designed to be evaluated critically, not just browsed.

GitHub: [github.com/CartierC](https://github.com/CartierC)
