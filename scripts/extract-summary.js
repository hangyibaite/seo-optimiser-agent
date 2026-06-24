#!/usr/bin/env node
// Extracts a slim markdown summary from Lighthouse JSON reports.
// Usage: node extract-summary.js <desktop.json> <mobile.json> <output.md> <url> <timestamp>

const fs = require('fs');

const [,, desktopPath, mobilePath, outputPath, url, timestamp] = process.argv;

if (!desktopPath || !mobilePath || !outputPath) {
  console.error('Usage: node extract-summary.js <desktop.json> <mobile.json> <output.md> <url> <timestamp>');
  process.exit(1);
}

function extractReport(filePath, label) {
  const r = JSON.parse(fs.readFileSync(filePath, 'utf8'));

  const scores = {};
  for (const [k, v] of Object.entries(r.categories)) {
    scores[k] = Math.round(v.score * 100);
  }

  const failed = [];
  for (const [id, audit] of Object.entries(r.audits)) {
    if (audit.score !== null && audit.score < 1 && audit.details) {
      const item = { id, title: audit.title, score: audit.score };
      if (audit.numericValue !== undefined) {
        item.value = audit.numericValue;
        item.unit = audit.numericUnit || 'ms';
      }
      if (audit.details && audit.details.overallSavingsMs) {
        item.savingsMs = Math.round(audit.details.overallSavingsMs);
      }
      if (audit.details && audit.details.overallSavingsBytes) {
        item.savingsKB = Math.round(audit.details.overallSavingsBytes / 1024);
      }
      failed.push(item);
    }
  }

  failed.sort((a, b) => (a.score || 0) - (b.score || 0));

  let out = `## ${label}\n\n`;
  out += '| Category | Score |\n|---|---|\n';
  for (const [k, v] of Object.entries(scores)) {
    out += `| ${k} | ${v} |\n`;
  }

  out += '\n### Failed Audits\n\n';
  if (failed.length === 0) {
    out += 'All audits passed.\n';
  } else {
    out += '| Audit | Score | Value | Savings |\n|---|---|---|---|\n';
    for (const f of failed.slice(0, 30)) {
      const val = f.value !== undefined
        ? Math.round(f.value) + (f.unit === 'millisecond' ? 'ms' : f.unit === 'byte' ? 'B' : '')
        : '-';
      const sav = [];
      if (f.savingsMs) sav.push(f.savingsMs + 'ms');
      if (f.savingsKB) sav.push(f.savingsKB + 'KB');
      out += `| ${f.title} | ${Math.round((f.score || 0) * 100)} | ${val} | ${sav.join(', ') || '-'} |\n`;
    }
  }
  return out;
}

let summary = '# Lighthouse Audit Summary\n\n';
summary += `- **URL:** ${url || 'unknown'}\n`;
summary += `- **Timestamp:** ${timestamp || new Date().toISOString()}\n\n`;
summary += extractReport(desktopPath, 'Desktop') + '\n';
summary += extractReport(mobilePath, 'Mobile') + '\n';

fs.writeFileSync(outputPath, summary);
console.log('Summary written to: ' + outputPath);
