#!/bin/bash

set -u

echo "Starting markdown link verification..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/link-report.csv"

echo "File,URL,Status,Code" > "$OUTPUT_FILE"

found_links=0
failed_links=0

while IFS= read -r -d '' file; do
  echo "Scanning: $file"

  urls=$(grep -Eo 'https?://[^[:space:])">]+' "$file" | sort -u || true)

  if [[ -z "$urls" ]]; then
    continue
  fi

  while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    found_links=$((found_links + 1))

    status_code=$(curl -L -o /dev/null -s -w "%{http_code}" --max-time 10 "$url")

    if [[ "$status_code" =~ ^2[0-9][0-9]$|^3[0-9][0-9]$ ]]; then
      echo "OK   $url ($status_code)"
      printf '"%s","%s","OK","%s"\n' "${file#$REPO_ROOT/}" "$url" "$status_code" >> "$OUTPUT_FILE"
    else
      echo "FAIL $url ($status_code)"
      printf '"%s","%s","FAIL","%s"\n' "${file#$REPO_ROOT/}" "$url" "$status_code" >> "$OUTPUT_FILE"
      failed_links=$((failed_links + 1))
    fi
  done <<< "$urls"

done < <(find "$REPO_ROOT" -type f \( -name "*.md" -o -name "*.markdown" \) -print0)

echo ""
echo "Verification complete."
echo "Total links checked: $found_links"
echo "Failed links: $failed_links"
echo "Report saved to: $OUTPUT_FILE"

if [[ "$failed_links" -gt 0 ]]; then
  exit 1
else
  exit 0
fi