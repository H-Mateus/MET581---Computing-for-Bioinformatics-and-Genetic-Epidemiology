# CLAUDE.md

Teaching materials for the R lecture series delivered by Gabriel Mateus Bernardo
Harrington on a Cardiff University bioinformatics MSc. Quarto website, source
`.qmd` → rendered `docs/`, published on GitHub Pages.

## Module context (important — the course was redesigned for 2026/27)

The repo is named for the **old** module, `MET581 - Computing for Bioinformatics
and Genetic Epidemiology`, in which this material filled **9 lectures**.

The new module is **`Data Science for Life Sciences I`** (code TBC — the module
description says `METXX1`, the syllabus filename says `MET993`; both are in
`module_docs/`). Key facts:

- 20 credits, Level 7, Autumn, **5-week intensive block**, max 30 students.
- Module leads: W. John Watkins and Mateus Bernardo-Harrington.
- 14 sessions total across the teaching team. **Mateus delivers 6: sessions 3–8.**
- Assessment: 25% short-answer *Programming in R* (set wk1, due wk5), 25%
  short-answer *Applied Statistics* (set wk2, due wk5), 50% report
  *Pipelines for Applied Statistical Analysis in R* (set wk3, due wk5).
- MLOs 1–5 are in the module description PDF; MLO-1/2/4 map onto this material,
  MLO-3/5 onto the statistics half.

Session ownership in the new module:

| # | Session | Owner |
|---|---------|-------|
| 1–2 | Introduction to Data Science — Data and Code I & II | Richard Anney |
| **3** | **Introduction to R** | **this repo** |
| **4** | **Data Wrangling in R I** | **this repo** |
| **5** | **Data Wrangling in R II** | **this repo** |
| **6** | **Programming in R** | **this repo** |
| **7** | **Exploratory Data Analysis in R** | **this repo** |
| **8** | **Data Visualisation in R** | **this repo** |
| 9–10 | Probability, Data Sampling and Distributions I & II | Christopher Wills |
| 11–12 | Statistical Experiments and Significance Testing I & II | Daniel Farewell |
| 13–14 | Regression and Prediction in R I & II | John Watkins |

Consequences for this repo: **Shiny is dropped entirely**; **Modelling in R has
moved to Watkins** (sessions 13–14); the three wrangling lectures must compress
into two; and **EDA is a session in its own right** (previously spread across
`02_explore_r` and other lectures).

## Layout

Directories are numbered by the *old* lecture order:

```
00_llm_use/               AI-assistant strand (see below) → segment in session 3
01_intro_to_r/            Intro to R           → new session 3
02_explore_r/             Quarto, tibbles, readr → feeds new session 7 (EDA)
03_wrangling_data_1/      dplyr verbs, pipe    → new session 4
04_wrangling_data_2/      tidyr, joins, stringr/regex → new session 5
05_wrangling_data_3/      forcats, lubridate, functions → new session 5 (+6)
06_Programming_in_R/      conditionals, functions, purrr, loops → new session 6
07_Data_Visualisation_in_R/ ggplot2            → new session 8
10_resources/00_images/           shared images
10_resources/01_workshop_answers/ answer versions of workshops
archive/                  retired material, excluded from render — see its README
  08_Modelling_in_R/        lm/glm — now Watkins, sessions 13–14 (offer as handover)
  09_ShinyApp/              Shiny — dropped from the new module
data/                     pheno.txt, pheno_unclean.txt
module_docs/              new module description + syllabus PDFs
docs/                     RENDERED SITE — committed, served by GitHub Pages
_extensions/r-wasm/drop/  webr plugin for in-browser code cells
```

## The AI-assistant strand (`00_llm_use/`)

A three-layer response to student LLM use — the stance is *use them well*, not
*don't use them*. See `00_llm_use/README.md` for the rationale and placement.

- `met581_llm_demo_slides.qmd` — ~15–20 min segment for session 3: seven
  examples of fluent, non-erroring, **wrong** R, then prompting guidance.
- `using_ai_assistants.qmd` — student reference page on the site.
- `r_tutor_prompt.md`, `skills/r-tutor/SKILL.md`, `CLAUDE.md.example` — tutor-mode
  prompts, tool-agnostic and tool-specific. Deliberately not rendered (students
  copy them raw).
- `assessment_wording_draft.md` — **staff only, not published, needs module-team
  sign-off.**

Every code example was verified against R 4.6.1 / dplyr 1.2.1 and does what the
slide claims. **Keep it that way** — a segment about models being confidently
wrong has no authority if the lecturer is confidently wrong in it. Re-verify
after major tidyverse updates.

## Build

```sh
quarto render                       # whole site → docs/ (slow; re-runs all R code)
quarto render path/to/file.qmd      # single document — prefer this while iterating
quarto preview path/to/file.qmd
```

- `_quarto.yml`: `type: website`, `output-dir: docs`, `execute: freeze: auto`.
  `_freeze/` is **gitignored, deliberately**. It was committed briefly and then
  dropped: a full cold render with no cache takes **1m 41s**, which does not
  justify 45 MB across 197 files of churn on every render. `freeze: auto` still
  works locally as a cache; it just isn't shared.
- `docs/` **is committed** — GitHub Pages serves it. Re-rendering churns hundreds
  of generated PNGs and `site_libs/` files (`docs/` is ~77 MB). Render narrowly
  and check `git status` before committing.
- **No `renv`/lockfile — this is the real reproducibility gap**, and it now has no
  `_freeze/` safety net. A fresh clone renders only if these are installed:
  tidyverse, conflicted, gapminder, skimr, ggrepel, lubridate, broom, plotly,
  ggstatsplot, qrcode, here, nycflights13, babynames. Currently R 4.6.1, Quarto
  1.10.18. Adding `renv` would close this properly.

  ```r
  install.packages(c("tidyverse", "conflicted", "gapminder", "skimr", "ggrepel",
                     "lubridate", "broom", "plotly", "ggstatsplot", "qrcode",
                     "here", "nycflights13", "babynames"))
  ```
- `_extensions/r-wasm/drop/` provides the `drop` revealjs plugin (webr in-browser
  code cells) used by lectures 01, 02, 06, 07 and the LLM slides. It was
  previously **missing from the repo** — the site had been rendered on a machine
  where it was installed locally but it was never committed, so a clean clone
  could not build. Installed with `quarto add r-wasm/quarto-drop`; keep it
  committed.

## Two authoring styles coexist

**Newer, Mateus-authored** (`01`, `02`, `06`, `07`, `08`) — one `.qmd` per
lecture, `format: revealjs`, `theme: [dark, ../styles.scss]`, full author/ORCID/
affiliation YAML block, `logo: /10_resources/00_images/combined_logos.png`, and a
`drop:` block configuring **webr** so students can run code in the browser
(needs `revealjs-plugins: [drop]`).

**Inherited from Matthew Bracher-Smith** (`03`, `04`, `05`) — three files per
lecture: `*-Slides.qmd` (revealjs, `embed-resources`/`self-contained`, `theme:
dark`), `*-Lecture-Notes.qmd` (html, `theme: united`, prose version of the same
content), `*-Homework.qmd`. Different YAML idiom, hand-rolled HTML `<div>`
blocks for image layout, and heavy use of `## Topic - Practice!` slides.

When editing, match the surrounding file's style rather than imposing one.
Recurring slide idioms worth preserving: `## Todays Aims` / `## Learning
Objectives` openers, in-lecture `Practice!` and `Extra Practice!` slides, a
`## Break` slide mid-session, and `## Additional Resources` at the end.

## The pre-2026 Dropbox working copy

An older, non-git working copy of this project exists at:

```
~/UK Dementia Research Institute Dropbox/Gabriel Bernardo Harrington/backup/teaching/bioinformatic_masters_r_lectures
```

It is a snapshot of the pre-restructure state (last activity ~Oct/Nov 2025): no
`00_llm_use/`, no `module_docs/`, no `archive/`, and `08_Modelling_in_R/` and
`09_ShinyApp/` still at top level. Its `.git` directory is unusable — every
object is zero bytes, plus ~30 Dropbox "conflicted copy" index files.

**It was the source for the assets git never had** (see below). If something else
turns out to be missing from this repo, look there first. Note that the files are
Dropbox online-only placeholders by default: `stat` reports 0 bytes and reads
return nothing until the folder is made available offline in Finder. Check for
the `com.dropbox.placeholder` xattr before concluding a file is empty.

## Known breakage

Resolved:

- ~~Missing images~~ — all 29 recovered from the Dropbox copy into
  `10_resources/00_images/` (39 files). Every image reference across all
  non-archived `.qmd` files now resolves.
- ~~Missing `10_resources/styles.css`~~ — recovered; lecture 03's `css:` now
  resolves. **04 and 05 still reference a bare `styles.css` in their own
  directories, which does not exist anywhere.**
- ~~Homework answers for 03/04/05 source-less~~ — the real `.qmd` sources were
  recovered from the Dropbox copy (no reconstruction from HTML needed) and are
  now linked in the sidebar.
- ~~Site title/footers say `MET581`~~ — titles and footers now say **Data Science
  for Life Sciences I**. Lecture 03's footer also had a lower-cased site URL,
  which was a dead link (github.io paths are case-sensitive).
- ~~"avilable" typo~~ — fixed in all five footers.

Outstanding:

- The **repo name, repo URL and published site URL still say `MET581`**. Renaming
  the repository would break every existing link, including the QR code baked
  into the slides, so this was left deliberately. `README.md` and `index.qmd` both
  carry a note explaining the mismatch.
- Directory names and `.qmd` **filenames** still use the old `MET581`/lecture-NN
  scheme. Only the rendered titles were changed. Renaming files would churn
  `docs/`, `_freeze/` and every sidebar href for no student-visible gain.
- Lecture/session numbering has **not** been remapped to the new session numbers
  (3–8), because the restructure it depends on hasn't happened yet — the three
  wrangling lectures still need compressing into two, and `05` currently splits
  across sessions 5 and 6. Assigning numbers now would encode a mapping that is
  about to change.
- Legacy `.pptx`/`.rmd`/`.pdf` originals still sit alongside their `.qmd`
  replacements in `01`, `02`, `07`. Harmless but confusing; decide whether they
  belong in `archive/`.
- `data/eukaryotes.tsv` (10.5 MB, full NCBI dump, 37,951 rows) was recovered but
  **nothing references it** — the programming workshop reads a smaller subset from
  a GitHub raw URL. Probably delete.

## Theming (`_brand.yml`)

Colours are sampled from the logo files in `10_resources/00_images/`, not chosen
by eye: Cardiff red `#CE0439`, DRI navy `#001F8F`, DRI cyan `#59FFFF`.

- The website toggles light/dark (`[flatly, brand]` / `[darkly, brand]`); the
  revealjs decks are always dark and pin themselves with **`brand-mode: dark`**.
- `-bright` palette variants exist because the raw logo colours are unreadable on
  the dark slide background — `#001F8F` on `#12162A` scores **1.36:1**. All
  foreground/background pairs currently pass WCAG AA.
- **Do not use a font family whose name contains a digit** (e.g. `Source Sans 3`).
  Quarto emits it unquoted, which is invalid CSS, so browsers silently fall back
  to the bootswatch default. Quoting it in `_brand.yml` instead breaks the
  generated Google Fonts `@import` URL. Hence Inter + Fira Code.
- Brand palette colours are available to `styles.scss` as Sass variables named
  `$brand-<palette-name>`, e.g. `$brand-dri-navy-bright`.
- A document-level `theme:` **array** cannot merge with the project-level
  `theme: {light: …, dark: …}` **object** — Quarto flattens them and then tries to
  read the object as a file path, failing the whole render with
  `TypeError: Path must be a string`. The html pages in `03`–`05` therefore carry
  no `theme:` of their own and inherit the project's. Only the revealjs decks set
  a document-level theme, and `format: revealjs` never merges with the project's
  `format: html`, so they are safe.
- **`embed-resources`/`self-contained` interacts badly with brand webfonts.**
  Self-containment inlines the Google Fonts CSS *and the font binaries*, as
  percent-encoded data URIs, once per theme variant — it took the `03`–`05` html
  pages from ~2.2 MB to ~16 MB each (three ~4.4 MB `<link href="data:text/css,…">`
  blocks per page). Those pages are served from the website with shared
  `site_libs` and gain nothing from being standalone, so the flags were removed.
  The revealjs decks keep them deliberately, to stay usable offline while
  lecturing — which is also why `_brand.yml` requests only upright weights for
  Inter. **Adding a font weight or style multiplies the size of every deck.**

## Conventions

- British spelling in prose (visualisation, colour).
- Tidyverse-first teaching, native pipe `|>`, `conflicted` for masking.
- `gapminder` is the workhorse teaching dataset; `data/pheno*.txt` are the
  bespoke bioinformatics-flavoured ones.
- Image paths are written project-absolute (`/10_resources/00_images/x.png`),
  which Quarto resolves from the project root.
- `ls` on this machine is aliased to `eza`; `ls --icons`-style flags differ from
  GNU/BSD `ls`.
