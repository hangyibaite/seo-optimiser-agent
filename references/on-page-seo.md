# On-Page SEO Reference

## Title Tags

- Max **60 characters** (Google truncates beyond this in SERPs)
- Format: `Primary Keyword — Brand Name`
- One unique `<title>` per page — never duplicate across pages
- Include the target keyword naturally, front-loaded

```html
<title>AI Automation for Coaches — Baite Studio</title>
```

❌ Bad: `<title>Home</title>` / `<title>Welcome to Our Website</title>`

---

## Meta Description

- **150–160 characters** max
- Not a ranking factor — a CTR factor. Treat it as ad copy.
- Include target keyword (Google bolds matched terms in SERP)
- One unique description per page

```html
<meta name="description" content="Learn how to turn your content into consistent income with AI automation. Free course for coaches and creators." />
```

---

## Heading Hierarchy

- **Exactly one `<h1>` per page** — matches or closely mirrors the `<title>`
- `<h2>` for major sections, `<h3>` for subsections — don't skip levels
- Never use headings for styling — use CSS for that
- Keywords should appear naturally in at least one `<h2>`

```html
<h1>AI Automation for Coaches</h1>
  <h2>What You'll Learn</h2>
    <h3>Module 1: Offer Engineering</h3>
    <h3>Module 2: Inbound Systems</h3>
  <h2>Who This Is For</h2>
```

---

## URL Structure

- Short, descriptive, lowercase, hyphen-separated
- Keywords in slug: `/ai-automation-for-coaches` not `/page?id=42`
- No dates in blog URLs unless content is time-sensitive by nature
- Max 3-4 words in slug

```
✅ /blog/how-to-build-ai-agents
❌ /blog/2024/06/post-123-how-to-build-ai-agents-for-your-business-today
```

---

## Image Alt Text

- Describe what the image shows — concisely, accurately
- Include keyword only if it fits naturally — don't keyword-stuff
- Empty alt (`alt=""`) is correct for purely decorative images

```html
<img src="dashboard.webp" alt="Claude Code agent running a content repurpose workflow" />
<img src="divider.svg" alt="" />  <!-- decorative -->
```

---

## Internal Linking

- Link related pages together using descriptive anchor text — not "click here"
- Every important page should be reachable within 3 clicks from homepage
- Use consistent anchor text for the same destination across the site

```html
<!-- Bad -->
<a href="/offer-engineering">Click here</a>

<!-- Good -->
<a href="/offer-engineering">offer engineering framework</a>
```

---

## Open Graph / Social Meta

Required for correct social previews. Goes in `<head>`:

```html
<meta property="og:title" content="AI Automation for Coaches — Baite Studio" />
<meta property="og:description" content="Free course covering offer engineering, inbound systems, and AI automation." />
<meta property="og:image" content="https://yourdomain.com/og-image.jpg" />
<meta property="og:url" content="https://yourdomain.com/page-path" />
<meta property="og:type" content="website" />

<!-- Twitter/X -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="AI Automation for Coaches — Baite Studio" />
<meta name="twitter:image" content="https://yourdomain.com/og-image.jpg" />
```

OG image: minimum **1200×630px**, under 1MB.

---

## Language Declaration

```html
<html lang="en">
```

Required. Affects search localisation and accessibility.
