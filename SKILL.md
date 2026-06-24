---
name: seo-optimizer
description: >
  Apply SEO best practices to any web project — HTML, React, Next.js, or static sites. Use this skill whenever someone asks to "add SEO", "optimise for search", "improve my Google ranking", "fix my meta tags", "make this SEO-friendly", "audit SEO", "add structured data", "fix Core Web Vitals", "technical SEO", or "fix semantic HTML". Also trigger when someone shares code that is missing title tags, meta descriptions, canonical tags, schema markup, landmark elements, or sitemap configuration — even if they don't use the word "SEO". CRITICAL: trigger immediately when the user pastes a PageSpeed Insights or Lighthouse report — read pagespeed-audit.md and run the full triage. Also trigger after any deploy action — "deploy", "push to production", "commit and push", "push to main", "publish site", or any git push to a deploy branch — read post-deploy-audit.md and follow the workflow. This skill covers five areas: on-page HTML, technical crawlability, performance (Core Web Vitals), structured data, and semantic HTML. Always use it before suggesting SEO changes — don't guess from training data when a spec exists.
---

# SEO Optimizer

Produces concrete, code-level SEO recommendations and implementations. Not theory — specific HTML, config, and structural changes with exact values.

## How to use this skill

1. Identify what the user has: pasted code, PageSpeed report, URL, or stack description
2. Determine mode: **PageSpeed Audit** (pasted report) or **standard fix/audit** (code or general request)
3. Apply the relevant reference file(s) from the routing table below
4. Output: working code snippets + a prioritised fix list

## Branch Routing

| If the task involves… | Read |
|---|---|
| Pasted PageSpeed Insights or Lighthouse report | `pagespeed-audit.md` |
| Post-deploy audit, Lighthouse automation, push to production | `post-deploy-audit.md` |
| `<head>` tags, meta, title, H1-H6, URL slugs, internal linking | `references/on-page-seo.md` |
| Semantic HTML, landmark elements, div-soup, heading hierarchy | `references/semantic-html.md` |
| Crawlability, sitemaps, robots.txt, canonicals, redirects, JS rendering | `references/technical-seo.md` |
| LCP, INP, CLS, image optimisation, font loading, render-blocking | `references/core-web-vitals.md` |
| JSON-LD, schema.org, rich results, structured data | `references/structured-data.md` |

If the user asks for a full audit or says "make this SEO-friendly" without specifying — read **all five reference files**. Do not read `pagespeed-audit.md` unless a report has been pasted.

---

## Output Format

Always produce two things:

**1. Prioritised fix list** (ordered by impact, not effort):
```
CRITICAL — blocks indexing or kills rankings
HIGH     — directly impacts ranking signals
MEDIUM   — improves CTR or crawl efficiency
LOW      — good practice, marginal impact
```

**2. Code implementation** — working snippets, not pseudocode. Exact values, not placeholders where the spec defines them (e.g. title max-length is 60 chars — don't say "keep it short").

---

## What this skill never does

- Suggest "publish more content" or "build backlinks" — those are strategy, not implementation
- Use placeholder values where exact specs exist
- Recommend tools (Semrush, Ahrefs, etc.) unless the user asks — they want fixes, not a shopping list
- Apply fixes without explaining the indexing/ranking reason — one sentence per fix is enough
