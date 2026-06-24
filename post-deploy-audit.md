# Post-Deploy Lighthouse Audit

Triggered automatically after any action that puts code live. This closes the build-deploy-audit loop: the user pushes code, Lighthouse runs, and a prioritised fix list appears — no manual step.

---

## Trigger Conditions

Fire this workflow after **any** of the following:

- `git push` to a deploy branch (main, master, gh-pages, production, deploy)
- GitHub Pages, Vercel, Netlify, or Cloudflare Pages deploy commands
- User says "deploy", "push to production", "publish", "commit and push", "push it live"
- User returns to Claude Code after manually pushing (check `git log` — if HEAD was pushed since last interaction, offer the audit)

**Always ask first.** Before running, prompt:

> "Code pushed — want me to run a Lighthouse audit on `<url>`?"

Never run the audit silently. The user must confirm.

---

## Step 1: Detect the Deployed URL

Check these sources in order — use the first one found:

1. **`package.json` → `homepage` field** (common for GitHub Pages / CRA)
2. **`CNAME` file** in project root (GitHub Pages custom domain)
3. **Vercel config** — `.vercel/project.json` or `vercel.json`
4. **Netlify config** — `netlify.toml` → `[build]` section, or `.netlify/state.json`
5. **`.lighthouse-url` file** in project root (plain text, one URL per line — first line is primary)

If none found, ask the user:

> "What's the deployed URL I should audit?"

Store the answer in `.lighthouse-url` for next time.

---

## Step 2: Wait for Deploy Propagation

Wait **60 seconds** after the push completes. GitHub Pages deploys in under 60s for static sites. Vercel and Netlify are faster but 60s covers all cases.

Tell the user:

> "Waiting 60s for deploy to propagate..."

---

## Step 3: Run the Audit

Execute:

```bash
./scripts/lighthouse-audit.sh <url>
```

The script runs both desktop and mobile audits and produces:
- Full JSON + HTML reports in `lighthouse-reports/` (for reference)
- A slim markdown summary (`*.summary.md`) with scores, failed audits, and opportunities

---

## Step 4: Read the Summary

Read the summary file (not the full JSON — it's too token-heavy). The script outputs the path:

```
LIGHTHOUSE_SUMMARY_DESKTOP=lighthouse-reports/20260624-183000-example.com.summary.md
```

Read that file. It contains:
- Scores for all four categories (performance, accessibility, best-practices, SEO)
- Failed audits with numeric values (e.g. LCP: 4.2s, CLS: 0.18)
- Opportunities with estimated savings
- Desktop vs mobile comparison

---

## Step 5: Fire the PageSpeed Triage

Feed the summary into `pagespeed-audit.md` — treat it exactly like a pasted PSI report. Follow the full triage:

1. Map each failed audit to the correct fix reference
2. Prioritise by real-world impact (CRITICAL → LOW)
3. Deliver working code fixes for HIGH and CRITICAL items
4. Include verification steps

---

## Step 6: Offer Re-run

After fixes are applied and deployed again, offer to re-run:

> "Fixes deployed — want me to run another Lighthouse audit to compare?"

If yes, repeat from Step 2. The timestamped reports allow before/after comparison.

---

## Edge Cases

| Scenario | Action |
|---|---|
| User pushes but site isn't deployed (no CI/CD) | Don't offer audit — only trigger when a deploy mechanism is detected |
| Multiple deploy targets (staging + prod) | Ask which URL to audit |
| Lighthouse not installed and npx unavailable | Tell user to install Node.js — Lighthouse requires it |
| Audit fails or times out | Show the error, suggest running manually with `./scripts/lighthouse-audit.sh <url>` |
| User declines the audit | Don't ask again until the next push |
