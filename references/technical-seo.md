# Technical SEO Reference

## Crawlability Fundamentals

Search engines cannot rank what they cannot find and index. This file covers everything that affects whether pages are discoverable and correctly processed.

---

## robots.txt

Located at `yourdomain.com/robots.txt`. Controls which paths crawlers are allowed to access.

```
User-agent: *
Allow: /

# Block non-indexable paths
Disallow: /admin/
Disallow: /api/
Disallow: /thank-you/
Disallow: /?utm_*

Sitemap: https://yourdomain.com/sitemap.xml
```

Rules:
- `Disallow` paths with no SEO value: admin panels, internal APIs, UTM redirect pages, staging routes
- Always reference your sitemap at the bottom
- Test via Google Search Console → URL Inspection

---

## XML Sitemap

Required for any site with more than ~10 pages. Submit to Google Search Console.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yourdomain.com/</loc>
    <lastmod>2024-06-01</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://yourdomain.com/blog/ai-automation-coaches</loc>
    <lastmod>2024-05-15</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

In Next.js, use `next-sitemap`. In static sites, generate programmatically on build.

---

## Canonical Tags

Prevents duplicate content penalty when the same content is accessible at multiple URLs (e.g., with/without trailing slash, with/without query params).

```html
<!-- Every page should have this in <head> pointing to its own canonical URL -->
<link rel="canonical" href="https://yourdomain.com/blog/ai-automation-coaches" />
```

Cases where canonical matters most:
- Paginated content (`/blog?page=2` → canonicalise to `/blog/`)
- Product variants (`/shirt?color=red` → canonicalise to `/shirt/`)
- Print versions or AMP pages

---

## Redirects

| Type | Code | When to use |
|---|---|---|
| Permanent | 301 | Page moved, URL changed, domain migrated |
| Temporary | 302 | A/B test, maintenance, genuinely temporary |

**Never use 302 for permanent moves** — 301 passes link equity, 302 does not.

In Next.js (`next.config.js`):
```js
module.exports = {
  async redirects() {
    return [
      {
        source: '/old-page',
        destination: '/new-page',
        permanent: true, // 301
      },
    ]
  },
}
```

---

## noindex

Use to prevent specific pages from appearing in search results. Does NOT prevent crawling — just indexing.

```html
<!-- In <head> -->
<meta name="robots" content="noindex, nofollow" />
```

Apply to: thank-you pages, login pages, duplicate/paginated pages with no unique content, internal search results, staging environments.

---

## JavaScript SEO

Google can render JavaScript but it introduces a **two-wave indexing delay** — critical content may not be indexed for days if it's JavaScript-only.

Rules:
- Core page content (title, H1, body text, links) must be present in server-rendered HTML — not injected post-load
- Avoid `display:none` on content you want indexed
- Lazy-load images and non-critical components, not content
- For SPAs: use SSR (Next.js, Nuxt) or pre-rendering

Test: View Source on any page. If your target content isn't in the raw HTML, Google may miss it.

---

## Mobile: Viewport Meta Tag

Required. Google uses mobile-first indexing — the mobile version is what gets ranked.

```html
<meta name="viewport" content="width=device-width, initial-scale=1" />
```

No fixed-width layouts. Use responsive CSS. Test with Chrome DevTools → mobile emulation.

---

## HTTPS

Google confirmed HTTPS as a ranking signal. Ensure:
- Valid SSL cert (auto-renewed via Let's Encrypt / hosting provider)
- All HTTP → HTTPS via 301 redirect (including www vs non-www — pick one and redirect the other)
- No mixed content warnings (HTTP resources loaded on HTTPS pages)

---

## Site Architecture

Pages with the fewest clicks from homepage tend to rank highest — crawl budget and link equity both factor in.

```
Homepage (1)
  └── /blog (2)
        └── /blog/post-title (3) ← Max depth for important pages
```

Avoid orphan pages (no internal links pointing to them) — they receive no link equity and may never be crawled.

---

## hreflang (Multilingual Sites Only)

Tells Google which version of a page to serve to which country/language audience.

```html
<link rel="alternate" hreflang="en" href="https://yourdomain.com/page" />
<link rel="alternate" hreflang="en-sg" href="https://yourdomain.com/sg/page" />
<link rel="alternate" hreflang="x-default" href="https://yourdomain.com/page" />
```

`x-default` is required — points to the fallback version.
