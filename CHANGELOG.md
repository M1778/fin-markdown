# Changelog — fin-markdown

All notable changes to this library are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.0] — 2026-10-21

### Added
- Initial release: Markdown → HTML for Fin, pure Fin + stdlib
  `strings::std` only, no `@define` externs.
- Public API: `md_to_html`, `md_inline`, `md_escape_html`, `md_version`
  (`import { md_to_html } from markdown::fin;`) — same module name and
  signatures as the subset fin-ssg vendored, so it is a drop-in
  replacement for `src/vendor/markdown.fin`.
- Block: ATX headings `#`–`######` with optional closing `#`s, setext
  `===`/`---` underlines (runs of 1+, setext beats `<hr>` under text),
  paragraphs with hard breaks (two trailing spaces → `<br>`), fenced
  code with info-string → `<pre><code class="language-x">`, unordered
  and ordered lists, blockquotes, horizontal rules (`---`/`***`/`___`
  runs of 3+).
- Inline: `` `code` ``, `**bold**`, `*italic*`, `***bold italic***`,
  `~~strikethrough~~`, `[links](url)`, `![images](url)`, reference
  links (`[t][id]`, `[t][]`, `[t]`) with fence-aware definition
  collection (forward references work, first definition wins, ids
  match after trim + lowercase), autolinks (`<https://…>`).
- Full lifecycle: README, `docs/api.md`, 72-check test suite
  (`tests/run_tests.sh`, exit 0 on green), `examples/demo.fin` +
  `examples/sample.md`, GitHub Actions CI (builds finc 0.4.0 from
  source), real-format `finn.toml` (`src/markdown.fin` entrypoint —
  NOT `src/lib.fin`, so the module name stays `markdown`), MIT license.

### Changed
- Relative to the fin-ssg vendored subset: fenced blocks with an info
  string now emit `<pre><code class="language-x">` instead of bare
  `<pre><code>` (fin-ssg's smoke test needs its one `<pre><code>`
  assertion updated when it adopts this library — verified in the
  swap test, full SMOKE OK otherwise).

### Fixed during development (caught by executing, not review)
- Paragraph/list/heading/quote rendering bypassed backtick code-span
  handling (`` `code` `` rendered literally in block contexts) — the
  block path now uses the code-span-aware `md_inline_full` with
  document definitions threaded through.
- Setext detection required exactly `===`/`---`; runs like
  `============` were missed — now any run of `=`/`-`.
- Empty-output documents returned the `""` struct-literal initializer,
  which callers must not `free_str` — `st.html` / `md_inline`'s
  accumulator now start as heap strings via `clone("")`.

### Not supported (documented limits)
- Nested lists, tables, indented code blocks, reference images,
  underscore emphasis, link titles, definitions inside lists/quotes.
