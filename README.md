# fin-markdown

Markdown → HTML for [Fin](https://github.com/M1778/Fin). A pure-Fin,
dependency-free library (stdlib `strings::std` only) that renders a
practical Markdown subset to an HTML fragment.

This is the library fin-ssg's vendored `src/vendor/markdown.fin` was
marked to be replaced by: same module name (`markdown`), same import
spelling, same public function signatures.

```fin
import { md_to_html } from markdown::fin;

fun main() <noret> {
    let html <string> = md_to_html("# Hello\n\n**Fin** is *fun*.");
    printf("%s", html);   // <h1>Hello</h1>\n<p><strong>Fin</strong> is <em>fun</em>.</p>\n
}
```

## Install

With [finn](https://github.com/M1778/finn) (once the registry lists it):

```toml
[packages]
fin-markdown = "M1778/fin-markdown@0.1.0"
```

By hand today: copy this repo's `src/` onto your finc search path and
compile with `finc -I <path-to>/src`. Import spelling:

```fin
import { md_to_html, md_inline, md_escape_html } from markdown::fin;
```

## Build & test

```sh
finc -I src src/markdown.fin                                # frontend check
sh tests/run_tests.sh                                       # 72 checks, exit 0 on green
finc -I src examples/demo.fin -o demo && ./demo             # feature tour
```

CI (`.github/workflows/ci.yml`) builds finc 0.4.0 from source, runs the
check, the test suite, and the example.

## API

Full reference: [docs/api.md](docs/api.md).

```fin
pub fun md_to_html(md: string) <string>    // document -> HTML fragment (no <html> wrapper)
pub fun md_inline(s: string) <string>      // inline markup on one span of text
pub fun md_escape_html(s: string) <string> // escape &, <, >
pub fun md_version() <string>             // "0.1.0"
```

All results are heap-allocated: release them with `free_str` (or `free`).
Never `free_str` a string literal.

Supported block syntax: ATX headings `#`–`######` (optional closing
`#`s), setext headings (`===` / `---` underlines), paragraphs, fenced
code blocks (```` ``` ```` with optional info string →
`<pre><code class="language-x">`), unordered lists (`-`, `*`), ordered
lists (`1.`), blockquotes (`>`), horizontal rules (`---`, `***`,
`___`), hard breaks (two trailing spaces → `<br>`).

Supported inline syntax: `` `code` ``, `**bold**`, `*italic*`,
`***bold italic***`, `~~strikethrough~~`, `[links](url)`,
`![images](url)`, reference links (`[t][id]`, `[t][]`, `[t]` with
`[id]: url` definitions), autolinks (`<https://…>`).

Not supported (documented in `docs/api.md`): nested lists, tables,
indented code blocks, reference images, underscore emphasis, link titles.

## Contract notes

- Malformed markup degrades to literal text; the library never `blame`s.
- Limits: 8192 lines per document, 512 reference definitions.
- Reference-definition ids match after trim + lowercase (first
  definition wins); definition lines render nothing and never interrupt
  a paragraph; a definition-looking line inside a fenced block stays code.

## License

MIT — see [LICENSE](LICENSE).
