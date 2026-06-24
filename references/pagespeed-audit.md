# PageSpeed Audit Reference

Triage table for Lighthouse and PageSpeed Insights reports. The fixer subagent reads this to map failed audits to root causes and fix references.

---

## Step 1: Parse the Report

Identify which of these the user has provided:

| Input type | How to handle |
|---|---|
| Raw PSI score only (e.g. "I got 62 on mobile") | Ask them to paste the full Diagnostics section — score alone is not actionable |
| PSI Diagnostics list (opportunities + diagnostics) | Proceed directly — full triage below |
| Lighthouse JSON export | Extract `audits` object — same triage applies |
| Screenshot of PSI results | Read visible line items — treat as Diagnostics list |
| Lighthouse summary file path (from automated post-deploy audit) | Read the `.summary.md` file — it contains scores + failed audits + opportunities. Proceed with triage below |

Do not guess fixes from the score alone. The score is a composite — the same 62 can have completely different root causes.

---

## Step 2: Triage by Audit Category

PSI groups findings into four categories. Map each flagged item to the correct fix reference:

### Performance (affects LCP, INP, CLS, Speed Index, TBT)

| PSI audit item | Root cause | Fix reference |
|---|---|---|
| Largest Contentful Paint (LCP) > 2.5s | Slow hero image, no preload, no CDN, render-blocking resources | `references/core-web-vitals.md` → LCP section |
| Interaction to Next Paint (INP) > 200ms | Long JS tasks, unthrottled event handlers | `references/core-web-vitals.md` → INP section |
| Cumulative Layout Shift (CLS) > 0.1 | Missing image dimensions, injected banners, font swap | `references/core-web-vitals.md` → CLS section |
| Eliminate render-blocking resources | CSS/JS in `<head>` blocking paint | Add `defer` to scripts; inline critical CSS |
| Properly size images | Serving 2x images at 1x display size | Resize to display dimensions; serve WebP |
| Serve images in next-gen formats | PNG/JPG served instead of WebP/AVIF | Convert to WebP; use `<picture>` for AVIF fallback |
| Efficiently encode images | Images not compressed | Re-export at 80-85% quality WebP |
| Defer offscreen images | Below-fold images loading eagerly | Add `loading="lazy"` |
| Minify CSS / Minify JavaScript | Unminified assets in production | Verify build tool minification is enabled |
| Remove unused CSS / JavaScript | Dead code shipped to browser | Tree-shaking (Vite/webpack); PurgeCSS for Tailwind |
| Reduce initial server response time (TTFB) | Slow server or no CDN | Move to CDN/edge; check server region |
| Avoid enormous network payloads | Total page weight too high | Audit and compress all assets |
| Avoid an excessive DOM size | Too many nodes (>1,400 warning, >800 ideal) | Virtualise long lists; remove unnecessary wrappers |
| Use efficient cache policy | Static assets not cached | Set `Cache-Control: max-age=31536000` on static files |
| Preload key requests | Critical fonts/images discovered late | Add `<link rel="preload">` for LCP image and fonts |

### Accessibility (indirect ranking signal via engagement)

| PSI audit item | Fix |
|---|---|
| Image elements do not have `[alt]` attributes | Add descriptive alt text; `alt=""` for decorative images |
| Links do not have a discernible name | Add text content or `aria-label` to icon-only links |
| Buttons do not have an accessible name | Add text or `aria-label` |
| Heading elements are not in a sequentially-descending order | Fix heading hierarchy — read `references/semantic-html.md` |
| `[id]` attributes on the page are not unique | Deduplicate IDs |
| Color contrast is insufficient | Check with browser DevTools accessibility panel |

### Best Practices

| PSI audit item | Fix |
|---|---|
| Browser errors logged to console | Open DevTools console, fix JS errors |
| Issues logged to Issues panel (deprecated APIs) | Update deprecated APIs |
| Page has mixed content (HTTP on HTTPS page) | Change all resource URLs to HTTPS |
| Does not use HTTPS | Add SSL; set up HTTP→HTTPS 301 redirect |

### SEO (direct ranking signals)

| PSI audit item | Fix reference |
|---|---|
| Document does not have a meta description | `references/on-page-seo.md` → Meta Description |
| Document does not have a title element | `references/on-page-seo.md` → Title Tags |
| Page is blocked from indexing | Check `<meta name="robots" content="noindex">` and `robots.txt` |
| Links are not crawlable | Replace JS-only navigation with real `<a href>` links |
| `robots.txt` is not valid | `references/technical-seo.md` → robots.txt |
| Image elements do not have `[alt]` attributes | `references/on-page-seo.md` → Image Alt Text |
| Document doesn't use legible font sizes | Minimum 16px body text on mobile |
| Tap targets are not sized appropriately | Minimum 44×44px tap targets on mobile |

---

## Step 3: Prioritise Output

After mapping all flagged items, output in this order — impact first, not PSI category order:

```
CRITICAL — blocks indexing or kills rankings (noindex bug, HTTPS missing, crawl block)
HIGH     — direct LCP/INP/CLS failure (outside passing threshold)
HIGH     — render-blocking resources, missing alt text on key images
MEDIUM   — unused JS/CSS, image format/compression, cache policy
LOW      — console errors, contrast, tap target sizing
```

Never output PSI's category order verbatim. Resequence by real-world impact.

---

## Step 4: Fix Delivery Format

For each HIGH or CRITICAL item, deliver:

1. **One-line diagnosis** — what's actually wrong, not a restatement of the PSI label
2. **Working code fix** — not pseudocode, not "consider using WebP"
3. **Verification step** — how to confirm the fix worked before re-running PSI

Example:

**HIGH: LCP > 4.2s — hero image loading without preload**

Diagnosis: The hero image is discovered by the browser only after the HTML is parsed and CSS is applied. By then, 2-3 seconds are already gone.

Fix:
```html
<!-- Add to <head> immediately after <meta charset> -->
<link rel="preload" as="image" href="/images/hero.webp" fetchpriority="high" />

<!-- Update the <img> tag -->
<img
  src="/images/hero.webp"
  alt="Your hero description"
  width="1440"
  height="600"
  fetchpriority="high"
/>
<!-- Remove loading="lazy" if present — never lazy-load the LCP element -->
```

Verify: Re-run PSI after deploying. Check Network tab in DevTools — hero image should appear in the first 2-3 requests with priority "High".

