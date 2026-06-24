# SEO Optimiser Agent

A multi-agent system for Claude Code that automatically audits, fixes, and verifies SEO issues on any web project. Push your code, and the agent handles the rest.

## What it does

After you deploy, the orchestrator agent:

1. Runs a Lighthouse audit (desktop + mobile)
2. Spawns a **fixer** subagent that reads the results, triages every failing audit, and applies code fixes directly to your source files
3. Deploys the fixes and spawns a **QC** subagent that re-runs Lighthouse independently, compares before/after scores, and verifies each fix is structurally correct in source code
4. On PASS — commits and pushes. On FAIL — feeds QC feedback back to the fixer and loops (max 3 attempts)

No manual triage. No copy-pasting Lighthouse reports. No guessing what to fix.

## What it covers

- **Performance** — LCP, INP, CLS, render-blocking resources, image optimisation, font loading
- **On-page SEO** — title tags, meta descriptions, heading hierarchy, canonical URLs, Open Graph
- **Technical SEO** — robots.txt, sitemaps, crawlability, HTTPS, redirects
- **Accessibility** — alt text, heading order, landmark elements, colour contrast
- **Structured data** — JSON-LD schemas (Article, FAQ, Breadcrumb, Course, Person)
- **Semantic HTML** — landmark elements, div-soup cleanup, `<head>` completeness

## Where to use it

Any web project with a deployed URL:

- Static HTML sites
- React / Create React App
- Next.js
- Astro
- Vite-based projects
- GitHub Pages, Vercel, Netlify, Cloudflare Pages

## Quick start

```bash
# Clone this repo
git clone https://github.com/hangyibaite/seo-optimiser-agent.git

# In your project root:
SEO_AGENT_DIR="/path/to/seo-optimiser-agent"

mkdir -p .claude/agents
cp "$SEO_AGENT_DIR"/agents/*.md .claude/agents/
cp "$SEO_AGENT_DIR"/agent-guardrails.md ./agent-guardrails.md
cp -r "$SEO_AGENT_DIR"/references ./references
cp -r "$SEO_AGENT_DIR"/scripts ./scripts
chmod +x scripts/lighthouse-audit.sh

echo "https://yoursite.com" > .lighthouse-url
grep -q 'lighthouse-reports' .gitignore 2>/dev/null || echo 'lighthouse-reports/' >> .gitignore
```

See [INSTALL.md](INSTALL.md) for detailed setup, URL configuration options, and troubleshooting.

## How it works

```
You push code
    │
    ▼
Orchestrator asks: "Run Lighthouse audit?"
    │
    ▼
Lighthouse runs (desktop + mobile)
    │
    ▼
Fixer subagent reads summary
  ├── Triages via pagespeed-audit.md
  ├── Reads relevant reference files
  ├── Greps before removing anything (safety check)
  └── Applies code fixes, returns fix report
    │
    ▼
Orchestrator commits, pushes, waits 60s
    │
    ▼
QC subagent (fresh context, no knowledge of fixes)
  ├── Re-runs Lighthouse independently
  ├── Compares before/after scores
  ├── Reads changed files, verifies structural correctness
  └── Returns verdict: PASS / PASS_WITH_WARNINGS / FAIL
    │
    ▼
PASS → done
FAIL → fixer gets QC feedback, loops (max 3)
```

## Architecture

| Agent | Role | Edits files? |
|---|---|---|
| `seo-agent` | Orchestrator — runs Lighthouse, spawns subagents, handles loop | No |
| `seo-fixer` | Applies code fixes based on Lighthouse results and reference specs | Yes |
| `seo-qc` | Independently verifies fixes by re-running Lighthouse and checking source | No |

Safety guardrails (`agent-guardrails.md`) are read by every agent before acting. The fixer must grep for references before removing any code and document its reasoning in the fix report.

## Requirements

- Node.js 18+
- Chrome or Chromium
- Claude Code

## License

MIT
