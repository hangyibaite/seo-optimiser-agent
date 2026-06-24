# Structured Data Reference

JSON-LD is Google's preferred format for structured data. Enables rich results (star ratings, FAQs, breadcrumbs, etc.) in SERPs — direct CTR improvement.

Always inject in `<head>` via a `<script type="application/ld+json">` tag.

---

## Website / Sitelinks Search Box

Identifies your site to Google. Put this on the homepage only.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Baite Studio",
  "url": "https://baitestudio.com",
  "description": "AI automation for coaches and creators"
}
</script>
```

---

## Article / BlogPosting

For blog posts and content pages. Enables rich results in Google Discover and News.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "How to Build AI Agents for Your Content Business",
  "datePublished": "2024-06-01T08:00:00+08:00",
  "dateModified": "2024-06-10T08:00:00+08:00",
  "author": {
    "@type": "Person",
    "name": "Hang Yi",
    "url": "https://baitestudio.com/about"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Baite Studio",
    "logo": {
      "@type": "ImageObject",
      "url": "https://baitestudio.com/logo.png"
    }
  },
  "image": "https://baitestudio.com/images/ai-agents-blog-cover.webp",
  "url": "https://baitestudio.com/blog/how-to-build-ai-agents"
}
</script>
```

---

## FAQ Schema

Adds expandable Q&A directly in the SERP. High CTR boost. Use on FAQ sections or pages.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is Content to Cashflow Academy?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A free course covering offer engineering, inbound systems, and AI automation for coaches and creators."
      }
    },
    {
      "@type": "Question",
      "name": "Who is this course for?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Creators, coaches, and personal brand operators who have content but no consistent revenue pipeline."
      }
    }
  ]
}
</script>
```

Limit: Google typically shows 2-3 FAQs in SERP. Put the most high-value ones first.

---

## Breadcrumb Schema

Adds breadcrumb trail in SERP. Also helps Google understand site hierarchy.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://baitestudio.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Blog",
      "item": "https://baitestudio.com/blog"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "How to Build AI Agents",
      "item": "https://baitestudio.com/blog/how-to-build-ai-agents"
    }
  ]
}
</script>
```

---

## Course Schema

Specific to course/educational content. Use on course landing pages.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "Content to Cashflow Academy",
  "description": "Free course for coaches and creators covering offer engineering, inbound systems, and AI automation.",
  "provider": {
    "@type": "Organization",
    "name": "Baite Studio",
    "sameAs": "https://baitestudio.com"
  },
  "url": "https://join.baitestudio.com",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  }
}
</script>
```

---

## Person Schema

For personal brand sites / about pages. Helps Google understand the entity.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "Hang Yi",
  "url": "https://baitestudio.com",
  "sameAs": [
    "https://www.instagram.com/hangyibaite",
    "https://github.com/hangyibaite"
  ],
  "jobTitle": "Founder, Baite Studio",
  "knowsAbout": ["AI automation", "content marketing", "course creation"]
}
</script>
```

---

## Validation

Always validate before deploying: [Google Rich Results Test](https://search.google.com/test/rich-results)

Common errors:
- Missing required fields (check the error message — it names the field)
- Wrong date format — must be ISO 8601: `2024-06-01T08:00:00+08:00`
- Image URLs that return 404
