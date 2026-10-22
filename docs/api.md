# fin-markdown API reference (v0.1.0)

Import everything by name — qualified calls (`markdown.md_to_html(...)`)
are refused by the finc 0.4.0 backend:

```fin
import { md_to_html, md_inline, md_escape_html, md_version } from markdown::fin;
```

## md_to_html

```fin
pub fun md_to_html(md: string) <string>
```

Renders a whole Markdown document to an HTML fragment (no `<html>`
wrapper). Handles `\n` and `\r\n` line endings.

### Block syntax

| Syntax | Output |
|---|---|
| `#`–`######` + space + text | `<h1>`–`<h6>` (optional closing `#`s stripped: `## T ##`) |
| `=` / `-` run under a paragraph line | `<h1>` / `<h2>` (setext; a `---` run under text is h2, not `<hr>`) |
| blank-line-separated text | `<p>` (soft breaks stay `\n`) |
| line ending in two spaces | `<br>` at that break (hard break) |
| ```` ``` ```` / ```` ```lang ```` | `<pre><code>` / `<pre><code class="language-lang">` (unclosed fence auto-closes) |
| `- ` / `* ` items | `<ul><li>…` |
| `N. ` items | `<ol><li>…` |
| `> text` | `<blockquote><p>…` (one `<p>` per quoted line, one blockquote per run) |
| `---`, `***`, `___` (runs of 3+) | `<hr>` |
| `[id]: url` (top level) | nothing rendered; defines a reference link (first wins) |

### Inline syntax

`` `code` `` → `<code>` (escaped literally, no markup inside);
`**x**` → `<strong>`; `*x*` → `<em>`; `***x***` → `<strong><em>`;
`~~x~~` → `<del>`; `[t](u)` → `<a href="u">t</a>`;
`![a](u)` → `<img src="u" alt="a">`; `[t][id]`, `[t][]`, `[t]` →
reference links; `<https://…>` → `<a href="…">…</a>`.

Unclosed markers stay literal (`**oops` renders as `**oops`).

### Reference links in detail

- Definitions may appear anywhere at top level (before or after use);
  a definition line inside a fenced block is code, not a definition.
- `[id]: url`, `[id]: <url>`, and `[id]: url "title"` (title ignored).
- Ids match after `trim` + lowercase. Undefined references stay literal.
- Definition lines never interrupt a paragraph.

### Limits & edge cases

- 8192 lines per document; 512 reference definitions (extras ignored).
- Not supported: nested lists, tables, indented code blocks, reference
  images, underscore emphasis, link titles, definitions inside
  lists/quotes.
- Hard breaks are applied by newline counting after inline rendering;
  a code span that spans two paragraph lines shifts later breaks (rare).
- Intermediates are not freed (same as the stdlib style): free the
  returned string with `free_str` when done; never `free_str` a literal.

## md_inline

```fin
pub fun md_inline(s: string) <string>
```

Inline markup on one span of text (no block structure, no reference
links — it has no document context). Code spans are handled.

## md_escape_html

```fin
pub fun md_escape_html(s: string) <string>
```

Escapes `&`, `<`, `>` (`&` first, so output never double-escapes).
The result is always a fresh heap string, even when nothing matched.

## md_version

```fin
pub fun md_version() <string>   // "0.1.0"
```

Heap-allocated (safe to `free_str`).

## Backend-limit compliance (finc 0.4.0)

Written against the limits measured by Builders #1/#2: no `const`
declarations anywhere (literals only), no enum-typed struct fields, no
`Collection<StructType>` (definitions live in fixed `[string]` arrays),
no null string returns/arguments, by-name imported calls only, and no
`@define` externs at all — nothing in this module depends on extern
lowering through an import.
