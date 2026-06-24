# Semantic HTML Reference

Search engines use HTML landmark elements to understand page structure — what's navigation, what's the main content, what's a sidebar. Div-soup gives Google nothing to work with. Semantic markup is also an indirect ranking signal via accessibility: screen readers, structured data parsers, and Google's rendering engine all benefit from correct semantics.

---

## Landmark Elements

Every page should have exactly this structure:

```html
<body>
  <header>          <!-- Site header: logo, primary nav -->
    <nav>           <!-- Primary navigation links -->
      <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/blog">Blog</a></li>
      </ul>
    </nav>
  </header>

  <main>            <!-- ONE per page — the primary content -->
    <article>       <!-- Self-contained content (blog post, course module) -->
      <header>      <!-- Article-level header: title, byline, date -->
        <h1>How to Build AI Agents</h1>
        <time datetime="2024-06-01">June 1, 2024</time>
      </header>
      <section>     <!-- Thematic section within the article -->
        <h2>What is an agent?</h2>
        <p>...</p>
      </section>
    </article>

    <aside>         <!-- Supplementary content: related posts, sidebar -->
      ...
    </aside>
  </main>

  <footer>          <!-- Site footer: links, copyright, secondary nav -->
    ...
  </footer>
</body>
```

Rules:
- `<main>` appears **once per page** — never twice
- `<header>` and `<footer>` can appear inside `<article>` or `<section>` as well as at page level
- `<nav>` wraps navigation link groups — not every `<ul>` on the page
- `<aside>` is for content tangentially related to the main content — not just "stuff on the side"

---

## Article vs Section vs Div

| Element | Use when | Ask yourself |
|---|---|---|
| `<article>` | Content that makes sense on its own, out of context (blog post, product card, comment) | "Would this make sense if I shared just this piece?" |
| `<section>` | Thematic grouping within a larger page or article | "Does this have a heading that describes a distinct topic?" |
| `<div>` | Layout/styling wrapper with no semantic meaning | "Am I only adding this for CSS or JS purposes?" |

**Div-soup pattern to fix:**
```html
<!-- Bad -->
<div class="post">
  <div class="post-header">
    <div class="title">How to Build AI Agents</div>
  </div>
  <div class="post-body">
    <div class="section">
      <div class="section-heading">What is an agent?</div>
      <p>...</p>
    </div>
  </div>
</div>

<!-- Good -->
<article>
  <header>
    <h1>How to Build AI Agents</h1>
  </header>
  <section>
    <h2>What is an agent?</h2>
    <p>...</p>
  </section>
</article>
```

---

## Heading Hierarchy (repeated from on-page-seo.md — enforced here structurally)

- One `<h1>` per page. Always. No exceptions.
- Never skip levels: `<h1>` → `<h2>` → `<h3>`. Not `<h1>` → `<h3>`.
- Never use headings for visual sizing — use CSS. A heading communicates document structure, not font size.

Common violation: using `<h3>` because it "looks right" in the design. Fix the CSS, not the heading level.

---

## Interactive Elements

```html
<!-- Links navigate. Buttons act. Never swap them. -->

<!-- Navigate to a page -->
<a href="/blog/ai-agents">Read the post</a>

<!-- Trigger an action (submit, open modal, toggle) -->
<button type="button" onclick="openModal()">Watch demo</button>

<!-- Never do this -->
<div onclick="navigate()">Click me</div>        <!-- not keyboard accessible -->
<a href="#" onclick="doThing()">Do thing</a>    <!-- misleading, broken semantics -->
```

Google cannot reliably follow `<div>` and `<span>` click handlers as links. Use real `<a href>` for anything that should be crawlable.

---

## Lists

Use real list markup — not divs styled as lists.

```html
<!-- Unordered: items without inherent sequence -->
<ul>
  <li>Offer engineering</li>
  <li>Inbound systems</li>
  <li>AI automation</li>
</ul>

<!-- Ordered: steps, rankings, sequences -->
<ol>
  <li>Deploy to GitHub Pages</li>
  <li>Run PageSpeed Insights</li>
  <li>Fix flagged items</li>
</ol>

<!-- Description list: term/definition pairs, FAQs -->
<dl>
  <dt>LCP</dt>
  <dd>Largest Contentful Paint — measures when the main content loads</dd>
</dl>
```

---

## Images: Decorative vs Informative

```html
<!-- Informative image — describe what it shows -->
<img src="dashboard.webp" alt="Agent workflow showing three steps: input, process, output" />

<!-- Decorative image — empty alt, no description needed -->
<img src="background-pattern.svg" alt="" role="presentation" />

<!-- Never omit alt entirely — missing alt is an accessibility and SEO error -->
<img src="chart.png" />  <!-- BAD — Google and screen readers get nothing -->
```

---

## `<head>` Completeness Checklist

Every page's `<head>` should contain all of these:

```html
<head>
  <!-- 1. Character encoding — must be first -->
  <meta charset="UTF-8" />

  <!-- 2. Viewport — required for mobile-first indexing -->
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- 3. Title — 50-60 chars, unique per page -->
  <title>Page Title — Brand Name</title>

  <!-- 4. Meta description — 150-160 chars, unique per page -->
  <meta name="description" content="..." />

  <!-- 5. Canonical — every page, pointing to itself -->
  <link rel="canonical" href="https://yourdomain.com/this-page" />

  <!-- 6. Favicon -->
  <link rel="icon" href="/favicon.ico" sizes="any" />
  <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
  <link rel="apple-touch-icon" href="/apple-touch-icon.png" />

  <!-- 7. Open Graph -->
  <meta property="og:title" content="..." />
  <meta property="og:description" content="..." />
  <meta property="og:image" content="https://yourdomain.com/og.jpg" />
  <meta property="og:url" content="https://yourdomain.com/this-page" />
  <meta property="og:type" content="website" />

  <!-- 8. Language -->
  <!-- (set on <html> tag, not here — reminder only) -->
  <!-- <html lang="en"> -->

  <!-- 9. Preconnect for external resources (fonts, CDN) -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />

  <!-- 10. Preload LCP image (if applicable) -->
  <link rel="preload" as="image" href="/images/hero.webp" fetchpriority="high" />

  <!-- 11. Structured data -->
  <script type="application/ld+json">{ ... }</script>
</head>
```

Missing any of items 1-6 = CRITICAL. Items 7-9 = HIGH. Items 10-11 = MEDIUM.
