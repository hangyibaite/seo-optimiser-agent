# Install SEO Optimiser Agent

Drop this agent into any web project. It runs Lighthouse after deploys, fixes SEO issues autonomously, and QC-checks its own work.

## Prerequisites

- **Node.js 18+** — Lighthouse runs via `npx lighthouse`
- **Chrome or Chromium** — Lighthouse needs a browser engine. Most systems have this already. Headless Chrome is used automatically.
- **Claude Code** — the agents run inside Claude Code's agent system

**Windows:** `scripts/lighthouse-audit.sh` requires bash. Use Git Bash or WSL.

## Setup

All commands assume you're in your **target project root** (the site you want to audit), and `SEO_AGENT_DIR` points to where you cloned this repo.

```bash
# Set this to wherever you cloned seo-optimiser-agent
SEO_AGENT_DIR="/path/to/seo-optimiser-agent"
```

### 1. Copy agent files

```bash
mkdir -p .claude/agents
cp "$SEO_AGENT_DIR"/agents/*.md .claude/agents/
```

This installs three agents:
- **seo-agent** — the orchestrator. This is the only agent you invoke directly.
- **seo-fixer** — subagent spawned by the orchestrator to apply code fixes. You never run this yourself.
- **seo-qc** — subagent spawned by the orchestrator to verify fixes. You never run this yourself.

### 2. Copy guardrails, references, and scripts

```bash
cp "$SEO_AGENT_DIR"/agent-guardrails.md ./agent-guardrails.md
cp -r "$SEO_AGENT_DIR"/references ./references
cp -r "$SEO_AGENT_DIR"/scripts ./scripts
chmod +x scripts/lighthouse-audit.sh
```

### 3. Configure your deployed URL

The agent needs to know where your site is deployed. Pick one:

```bash
# Option A: Create a .lighthouse-url file (works for any project)
echo "https://yoursite.com" > .lighthouse-url

# Option B: If you have package.json, set the homepage field
# npm pkg set homepage="https://yoursite.com"

# Option C: If you use GitHub Pages with a custom domain, CNAME already works
# The script auto-detects CNAME files
```

If none of these exist, the agent will ask you for the URL on first run and create `.lighthouse-url` automatically.

### 4. Add lighthouse-reports to .gitignore

```bash
# Create .gitignore if it doesn't exist, or append if it does
grep -q 'lighthouse-reports' .gitignore 2>/dev/null || echo 'lighthouse-reports/' >> .gitignore
```

### 5. Verify

```bash
./scripts/lighthouse-audit.sh https://yoursite.com
```

This should produce:
- `lighthouse-reports/*.report.json` — full Lighthouse JSON (desktop + mobile)
- `lighthouse-reports/*.report.html` — viewable HTML reports
- `lighthouse-reports/*.summary.md` — slim markdown summary the agents read
- `lighthouse-reports/latest.summary.md` — symlink to the most recent summary

If it fails:
- `command not found: lighthouse` → Node.js not installed or not in PATH
- `Chrome not found` → install Chrome/Chromium
- `ERROR: No URL provided` → Step 3 wasn't completed

## What you get

After setup, the SEO agent activates when you push code:

1. **You push** → agent asks to run Lighthouse
2. **Lighthouse runs** → desktop + mobile audit, produces summary
3. **Fixer runs** → reads summary, triages with pagespeed-audit.md, applies code fixes
4. **QC runs** → re-runs Lighthouse independently, verifies fixes in source code
5. **On PASS** → agent commits and pushes
6. **On FAIL** → agent feeds QC feedback to fixer, loops (max 3 times)

## File structure after install

```
your-project/
  .claude/agents/
    seo-agent.md        ← orchestrator (invoke this one)
    seo-fixer.md        ← subagent: applies fixes (spawned by orchestrator)
    seo-qc.md           ← subagent: verifies fixes (spawned by orchestrator)
  agent-guardrails.md   ← safety rules all agents read first
  references/
    pagespeed-audit.md  ← triage table (maps audits → fixes)
    core-web-vitals.md  ← LCP, INP, CLS specs
    on-page-seo.md      ← title, meta, headings, OG tags
    semantic-html.md    ← landmarks, heading hierarchy
    structured-data.md  ← JSON-LD schemas
    technical-seo.md    ← robots.txt, sitemaps, canonicals
    qc-checklist.md     ← verification checklist for QC
  scripts/
    lighthouse-audit.sh
    extract-summary.js
  lighthouse-reports/   ← created on first run, gitignored
  .lighthouse-url       ← your deployed URL
```
