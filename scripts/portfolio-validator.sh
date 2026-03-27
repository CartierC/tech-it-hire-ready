#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
PLATFORM="$(uname -s)"
REPORT_FILE=""

print_usage() {
  cat <<'EOF'
Usage: ./scripts/portfolio-validator.sh [--report-file <path>]

Runs a local portfolio preflight check for:
  - core developer tooling
  - DNS and HTTPS reachability
  - expected repository structure

Options:
  --report-file <path>   Write the same report output to a file
  --help, -h             Show this help message

Exits with code 0 when all checks pass and 1 when any check fails.
EOF
}

emit() {
  printf '%s\n' "$1"

  if [[ -n "$REPORT_FILE" ]]; then
    printf '%s\n' "$1" >> "$REPORT_FILE"
  fi
}

emit_blank() {
  emit ""
}

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  emit "[PASS] $1"
}

record_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  emit "[FAIL] $1"
}

record_skip() {
  SKIP_COUNT=$((SKIP_COUNT + 1))
  emit "[SKIP] $1"
}

check_command() {
  local name="$1"
  local path

  if path="$(command -v "$name" 2>/dev/null)"; then
    record_pass "$name available at $path"
  else
    record_fail "$name not found"
  fi
}

check_brew() {
  if [[ "$PLATFORM" != "Darwin" ]]; then
    record_skip "brew check skipped on $PLATFORM"
    return
  fi

  check_command brew
}

check_dns() {
  local host="$1"

  if command -v dscacheutil >/dev/null 2>&1; then
    if dscacheutil -q host -a name "$host" | grep -q '^ip_address:'; then
      record_pass "DNS resolved $host"
    else
      record_fail "DNS could not resolve $host"
    fi
    return
  fi

  if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import socket; socket.gethostbyname('$host')" >/dev/null 2>&1; then
      record_pass "DNS resolved $host"
    else
      record_fail "DNS could not resolve $host"
    fi
    return
  fi

  if command -v host >/dev/null 2>&1; then
    if host "$host" >/dev/null 2>&1; then
      record_pass "DNS resolved $host"
    else
      record_fail "DNS could not resolve $host"
    fi
    return
  fi

  record_fail "No supported DNS lookup tool found for $host"
}

check_https() {
  local url="$1"

  if ! command -v curl >/dev/null 2>&1; then
    record_fail "curl required for HTTPS reachability check: $url"
    return
  fi

  if curl -I -sS --max-time 8 "$url" >/dev/null 2>&1; then
    record_pass "HTTPS reachable: $url"
  else
    record_fail "HTTPS unreachable: $url"
  fi
}

check_directory() {
  local relative_path="$1"
  local absolute_path="$REPO_ROOT/$relative_path"

  if [[ -d "$absolute_path" ]]; then
    record_pass "Directory present: $relative_path"
  else
    record_fail "Directory missing: $relative_path"
  fi
}

check_file() {
  local relative_path="$1"
  local absolute_path="$REPO_ROOT/$relative_path"

  if [[ -s "$absolute_path" ]]; then
    record_pass "File present and non-empty: $relative_path"
  elif [[ -f "$absolute_path" ]]; then
    record_fail "File present but empty: $relative_path"
  else
    record_fail "File missing: $relative_path"
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        print_usage
        exit 0
        ;;
      --report-file)
        if [[ $# -lt 2 ]]; then
          printf 'Error: --report-file requires a path\n' >&2
          exit 2
        fi
        REPORT_FILE="$2"
        shift 2
        ;;
      *)
        printf 'Error: unsupported argument: %s\n' "$1" >&2
        exit 2
        ;;
    esac
  done

  if [[ -n "$REPORT_FILE" ]]; then
    mkdir -p "$(dirname "$REPORT_FILE")"
    : > "$REPORT_FILE"
  fi

  emit "Portfolio Validation Report"
  emit "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  emit "Repository: $REPO_ROOT"
  emit "Platform: $PLATFORM"
  emit_blank
  emit "== Developer Tooling =="

  check_command git
  check_command python3
  check_brew
  check_command curl

  emit_blank
  emit "== Network and DNS =="

  check_dns github.com
  check_dns aws.amazon.com
  check_https https://github.com
  check_https https://aws.amazon.com

  emit_blank
  emit "== Repository Structure =="

  check_directory docs
  check_directory scripts
  check_directory templates
  check_directory .github
  check_directory .github/workflows

  check_file README.md
  check_file PROJECTS.md
  check_file docs/recruiter-30-second-scan.md
  check_file docs/verification-standard.md
  check_file templates/project-spec-template.md
  check_file scripts/verify-links.sh
  check_file scripts/portfolio-validator.sh
  check_file .github/workflows/link-check.yml
  check_file .github/workflows/markdown-lint.yml

  emit_blank
  emit "Summary: $PASS_COUNT passed, $FAIL_COUNT failed, $SKIP_COUNT skipped"

  if [[ "$FAIL_COUNT" -eq 0 ]]; then
    emit "Overall Result: PASS"
    exit 0
  fi

  emit "Overall Result: FAIL"
  exit 1
}

main "$@"
