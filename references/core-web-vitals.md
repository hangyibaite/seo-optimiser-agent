# Core Web Vitals Reference

Google uses CWV as a ranking signal. Three metrics, each with a hard pass/fail threshold.

## The Three Metrics

| Metric | What it measures | Pass threshold |
|---|---|---|
| **LCP** (Largest Contentful Paint) | Load speed — when the main content appears | < 2.5s |
| **INP** (Interaction to Next Paint) | Responsiveness — how fast the page reacts to clicks | < 200ms |
| **CLS** (Cumulative Layout Shift) | Visual stability — content jumping around during load | < 0.1 |

Measure with: Google PageSpeed Insights, Search Console → Core Web Vitals report, Chrome DevTools → Lighthouse.

---

## LCP Fixes

LCP is usually the hero image, H1, or above-fold block. Slow LCP = slow-loading main element.

**Image optimisation:**
```html
<!-- Use WebP or AVIF instead of PNG/JPG -->
<img src="hero.webp" alt="..." loading="eager" fetchpriority="high" width="1200" height="600" />

<!-- Lazy-load everything below the fold -->
<img src="content-image.webp" alt="..." loading="lazy" width="800" height="450" />
```

- Always set explicit `width` and `height` on images — prevents layout shift too
- Never lazy-load the LCP element — it's above the fold by definition
- Use `fetchpriority="high"` on the hero image

**Preload critical resources:**
```html
<link rel="preload" as="image" href="hero.webp" />
<link rel="preload" as="font" href="font.woff2" crossorigin />
```

**Minify CSS/JS:**
- All modern bundlers (Vite, webpack, Next.js) do this by default in production
- Verify: check Network tab in DevTools — `.min.js` / `.min.css`

**CDN:**
- Serve static assets from a CDN (Cloudflare, Vercel Edge, AWS CloudFront)
- Target TTFB (Time to First Byte) < 200ms

---

## INP Fixes

INP replaced FID as of March 2024. Measures input responsiveness across the entire page visit.

- Avoid long JavaScript tasks (>50ms) on the main thread
- Debounce/throttle event handlers on scroll and input fields
- Defer non-critical JS: `<script defer src="analytics.js"></script>`
- Use `requestIdleCallback` for non-urgent DOM work

```js
// Debounce expensive handler
const handleSearch = debounce((e) => {
  fetchResults(e.target.value);
}, 300);
```

---

## CLS Fixes

CLS = content jumping. Caused by elements that load and push other content down.

**Always reserve space for images/videos:**
```html
<!-- Set width + height so browser reserves space before image loads -->
<img src="card.webp" width="400" height="300" alt="..." />
```

Or with CSS aspect ratio:
```css
.hero-image {
  aspect-ratio: 16 / 9;
  width: 100%;
}
```

**Font loading:**
```css
/* Prevents invisible text during font swap */
@font-face {
  font-display: swap;
}
```

**Avoid inserting DOM above existing content** — banners, cookie notices, and ads injected above the fold are the #1 CLS culprit. Use reserved-height containers.

---

## Image Format Decision Tree

```
Photo/complex image with many colours → WebP (85% quality)
Screenshot/graphic with flat colour → WebP or PNG
Animation → WebP (animated) or use <video> for longer clips
Icon/logo → SVG (infinitely scalable, tiny file)
```

Never use uncompressed PNG for photos. Never use GIF for video.

---

## Font Best Practices

```html
<!-- Preconnect to font host -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />

<!-- Load only weights you actually use -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet" />
```

Self-hosting fonts eliminates the DNS lookup entirely — fastest option.

---

## Quick Wins Checklist

- [ ] Hero image is WebP with `fetchpriority="high"` and explicit dimensions
- [ ] All below-fold images have `loading="lazy"` and explicit dimensions
- [ ] JS files use `defer` or `async` unless render-critical
- [ ] No layout shifts from fonts (`font-display: swap`)
- [ ] CDN serving static assets
- [ ] No uncompressed images above 200KB
