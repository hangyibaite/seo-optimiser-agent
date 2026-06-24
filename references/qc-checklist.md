# QC Verification Checklist

Loaded by the QC subagent when verifying fixes. Organised by audit type — only read the sections relevant to what the fixer changed.

---

## LCP / Image Fixes

- Hero image has `fetchpriority="high"`
- Hero image does NOT have `loading="lazy"` — lazy-loading the LCP element is always wrong
- `<link rel="preload" as="image" href="...">` in `<head>` targets the correct image path
- Image has explicit `width` and `height` attributes
- Image format is WebP or AVIF, not uncompressed PNG/JPG for photos

## CLS Fixes

- All `<img>` tags have explicit `width` and `height` or CSS `aspect-ratio`
- `@font-face` declarations include `font-display: swap`
- No content injected above the fold without reserved height

## SEO Fixes

- `<title>` exists, is unique, is under 60 characters
- `<meta name="description">` exists, is under 160 characters
- `<link rel="canonical">` points to the correct deployed URL — not localhost, not a different page
- `<html lang="...">` is set
- No accidental `<meta name="robots" content="noindex">` on pages that should be indexed

## Accessibility Fixes

- All informative `<img>` have descriptive `alt` text — not empty, not placeholder
- Decorative images have `alt=""`
- Heading hierarchy is sequential (h1 → h2 → h3, no skipped levels)
- Exactly one `<h1>` per page

## Structured Data Fixes

- Required fields are present for the schema type used
- Image URLs and page URLs are absolute, not relative paths

---

## Fragile Fix Detection

Flag these even if the score improved — they will break on subsequent runs or in production:

- `loading="lazy"` on any above-fold image
- `fetchpriority="high"` on more than one image — defeats the purpose
- Preload for a resource that doesn't exist at that path
- `font-display: swap` added to a stylesheet that isn't actually used
- `alt` text that is clearly placeholder ("image", "photo", "alt text here")
- Canonical URL pointing to localhost or a staging domain
- Hard-coded absolute paths that will break in different environments
