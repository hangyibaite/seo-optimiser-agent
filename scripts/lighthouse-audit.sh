#!/bin/bash
# lighthouse-audit.sh
# Usage: ./scripts/lighthouse-audit.sh [url]
# If no URL provided, reads from .lighthouse-url or package.json homepage.
# Runs desktop + mobile Lighthouse audits, saves JSON/HTML reports and a
# slim markdown summary for Claude Code to consume without blowing up tokens.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/lighthouse-reports"

# ── Resolve URL ──────────────────────────────────────────────────────────────
URL="$1"

if [ -z "$URL" ]; then
  if [ -f "$PROJECT_ROOT/.lighthouse-url" ]; then
    URL=$(head -1 "$PROJECT_ROOT/.lighthouse-url" | tr -d '[:space:]')
  elif [ -f "$PROJECT_ROOT/package.json" ]; then
    URL=$(node -e "try{console.log(require('$PROJECT_ROOT/package.json').homepage||'')}catch(e){}" 2>/dev/null | tr -d '[:space:]')
  elif [ -f "$PROJECT_ROOT/CNAME" ]; then
    URL="https://$(head -1 "$PROJECT_ROOT/CNAME" | tr -d '[:space:]')"
  fi
fi

if [ -z "$URL" ]; then
  echo "ERROR: No URL provided and none found in .lighthouse-url, package.json homepage, or CNAME."
  echo "Usage: ./scripts/lighthouse-audit.sh https://yoursite.com"
  exit 1
fi

CLEAN_URL=$(echo "$URL" | sed 's|https\?://||' | sed 's|/$||' | sed 's|/|-|g')
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# ── Ensure report directory exists ───────────────────────────────────────────
mkdir -p "$REPORT_DIR"

# ── Check .gitignore ────────────────────────────────────────────────────────
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  if ! grep -q 'lighthouse-reports' "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    echo "WARNING: lighthouse-reports/ is not in .gitignore — reports may get committed."
  fi
fi

# ── Resolve Lighthouse command ───────────────────────────────────────────────
if command -v lighthouse &> /dev/null; then
  LH_CMD="lighthouse"
elif command -v npx &> /dev/null; then
  LH_CMD="npx lighthouse"
else
  echo "ERROR: Neither lighthouse nor npx found. Install Node.js and run:"
  echo "  npm install -g lighthouse"
  exit 1
fi

LH_VERSION=$($LH_CMD --version 2>/dev/null || echo "unknown")
echo "Using Lighthouse $LH_VERSION"

# ── Run desktop audit ────────────────────────────────────────────────────────
DESKTOP_BASE="$REPORT_DIR/${TIMESTAMP}-${CLEAN_URL}-desktop"

echo ""
echo "Running desktop audit on: $URL"
echo "This takes ~30-60 seconds..."

$LH_CMD "$URL" \
  --output json,html \
  --output-path "$DESKTOP_BASE" \
  --preset desktop \
  --chrome-flags="--headless --no-sandbox --disable-gpu" \
  --quiet

DESKTOP_JSON="${DESKTOP_BASE}.report.json"
DESKTOP_HTML="${DESKTOP_BASE}.report.html"

if [ ! -f "$DESKTOP_JSON" ]; then
  echo "ERROR: Desktop audit did not produce JSON at: $DESKTOP_JSON"
  exit 1
fi

# ── Run mobile audit ─────────────────────────────────────────────────────────
MOBILE_BASE="$REPORT_DIR/${TIMESTAMP}-${CLEAN_URL}-mobile"

echo "Running mobile audit..."

$LH_CMD "$URL" \
  --output json,html \
  --output-path "$MOBILE_BASE" \
  --preset mobile \
  --chrome-flags="--headless --no-sandbox --disable-gpu" \
  --quiet

MOBILE_JSON="${MOBILE_BASE}.report.json"
MOBILE_HTML="${MOBILE_BASE}.report.html"

# ── Generate slim summary ────────────────────────────────────────────────────
SUMMARY_PATH="$REPORT_DIR/${TIMESTAMP}-${CLEAN_URL}.summary.md"

node -e "
const fs = require('fs');

function extractReport(path, label) {
  const r = JSON.parse(fs.readFileSync(path, 'utf8'));
  const scores = {};
  for (const [k, v] of Object.entries(r.categories)) {
    scores[k] = Math.round(v.score * 100);
  }

  const failed = [];
  for (const [id, audit] of Object.entries(r.audits)) {
    if (audit.score !== null && audit.score < 1 && audit.details) {
      const item = { id, title: audit.title, score: audit.score };
      if (audit.numericValue !== undefined) {
        item.value = audit.numericValue;
        item.unit = audit.numericUnit || 'ms';
      }
      if (audit.details && audit.details.overallSavingsMs) {
        item.savingsMs = Math.round(audit.details.overallSavingsMs);
      }
      if (audit.details && audit.details.overallSavingsBytes) {
        item.savingsKB = Math.round(audit.details.overallSavingsBytes / 1024);
      }
      failed.push(item);
    }
  }

  failed.sort((a, b) => (a.score || 0) - (b.score || 0));

  let out = '## ' + label + '\n\n';
  out += '| Category | Score |\n|---|---|\n';
  for (const [k, v] of Object.entries(scores)) {
    out += '| ' + k + ' | ' + v + ' |\n';
  }
  out += '\n### Failed Audits\n\n';
  if (failed.length === 0) {
    out += 'All audits passed.\n';
  } else {
    out += '| Audit | Score | Value | Savings |\n|---|---|---|---|\n';
    for (const f of failed.slice(0, 30)) {
      const val = f.value !== undefined ? Math.round(f.value) + (f.unit === 'millisecond' ? 'ms' : f.unit === 'byte' ? 'B' : '') : '-';
      const sav = [];
      if (f.savingsMs) sav.push(f.savingsMs + 'ms');
      if (f.savingsKB) sav.push(f.savingsKB + 'KB');
      out += '| ' + f.title + ' | ' + Math.round((f.score || 0) * 100) + ' | ' + val + ' | ' + (sav.join(', ') || '-') + ' |\n';
    }
  }
  return out;
}

let summary = '# Lighthouse Audit Summary\n\n';
summary += '- **URL:** $URL\n';
summary += '- **Timestamp:** $TIMESTAMP\n\n';
summary += extractReport('$DESKTOP_JSON', 'Desktop') + '\n';
summary += extractReport('$MOBILE_JSON', 'Mobile') + '\n';

fs.writeFileSync('$SUMMARY_PATH', summary);
" 2>/dev/null

# ── Create latest symlinks ───────────────────────────────────────────────────
ln -sf "$(basename "$SUMMARY_PATH")" "$REPORT_DIR/latest.summary.md"
ln -sf "$(basename "$DESKTOP_HTML")" "$REPORT_DIR/latest-desktop.report.html"
ln -sf "$(basename "$MOBILE_HTML")" "$REPORT_DIR/latest-mobile.report.html"

# ── Output summary to stdout ─────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
echo "  LIGHTHOUSE AUDIT COMPLETE"
echo "══════════════════════════════════════════"
echo "  URL: $URL"
echo "  Timestamp: $TIMESTAMP"
echo ""

# Quick scores from summary
PERF_D=$(node -e "const r=require('$DESKTOP_JSON'); console.log(Math.round(r.categories.performance.score*100))" 2>/dev/null || echo "n/a")
PERF_M=$(node -e "const r=require('$MOBILE_JSON'); console.log(Math.round(r.categories.performance.score*100))" 2>/dev/null || echo "n/a")
echo "  Desktop Performance: $PERF_D"
echo "  Mobile Performance:  $PERF_M"
echo ""
echo "  Reports:"
echo "  Summary:  $SUMMARY_PATH"
echo "  Desktop:  $DESKTOP_HTML"
echo "  Mobile:   $MOBILE_HTML"
echo "══════════════════════════════════════════"
echo ""

# ── Machine-readable output for Claude Code ──────────────────────────────────
echo "LIGHTHOUSE_SUMMARY=$SUMMARY_PATH"
echo "LIGHTHOUSE_JSON_DESKTOP=$DESKTOP_JSON"
echo "LIGHTHOUSE_JSON_MOBILE=$MOBILE_JSON"
