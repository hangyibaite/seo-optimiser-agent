# Agent Guardrails

All agents in this system must read and follow these rules before doing anything else.

---

## Protected Files — Do Not Touch

These files are agent infrastructure. Never modify, delete, or overwrite them:

- `.claude/agents/*.md` — agent definitions
- `references/*.md` — SEO reference files
- `agent-guardrails.md` — this file
- `scripts/lighthouse-audit.sh`, `scripts/extract-summary.js` — audit tooling
- `lighthouse-reports/` — generated reports (read from, never write to or delete)
- `.lighthouse-url`, `CNAME` — URL configuration

## Safe Edit Scope

The fixer may only edit files in the project's source and build directories:

- `src/`, `public/`, `pages/`, `app/`, `static/` — source code and assets
- Root-level HTML, CSS, JS files (e.g., `index.html`, `styles.css`)
- Config files: `package.json`, `next.config.js`, `vite.config.js`, `robots.txt`, `sitemap.xml`
- `@font-face` declarations in stylesheets

The QC agent edits nothing. The orchestrator only creates commits and `.lighthouse-url`.

## Before Removing or Replacing Any Code

Never delete or remove existing code unless you have verified it is safe. This is the required process — no exceptions:

1. **State** what you're removing and which audit requires it
2. **Grep** the project for references: `grep -r "<identifier>" --include="*.html" --include="*.js" --include="*.css" --include="*.tsx" --include="*.jsx" --include="*.ts" .`
3. **Decide:**
   - No references found outside the element itself → safe to remove. Proceed.
   - References exist → do NOT remove. Flag in "Not Fixed (requires user action)" with the reference locations.
4. **Document** your reasoning in the fix report under each fix (see fix report format in seo-fixer.md)

This applies to:
- `<script>` tags, stylesheets, or imports — they may be used elsewhere
- HTML elements — they may be targeted by JS or CSS
- Config entries — they may affect build or deploy

If a fix requires replacing an element (e.g., `<div onclick>` → `<a href>`), carry over all existing attributes, classes, and children. Don't strip anything the original had.
