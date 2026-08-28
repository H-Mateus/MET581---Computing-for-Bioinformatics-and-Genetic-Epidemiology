# LLM use — teaching materials

Material for the "how to use AI assistants responsibly" strand of *Data Science
for Life Sciences I*. Staff-facing notes here; student-facing content is the
`.qmd` and the prompt files.

## Contents

| File | Audience | Purpose |
|---|---|---|
| `met581_llm_demo_slides.qmd` | students, live | ~15–20 min segment for **session 3**. Seven verified examples of fluent, non-erroring, wrong R, then the prompting guidance. |
| `using_ai_assistants.qmd` | students, reference | Website page: the norms, the prompting guide, what's fine in assessed work, links to the tutor prompt. |
| `r_tutor_prompt.md` | students | Tool-agnostic paste-in tutor prompt (Claude, ChatGPT, Gemini, Copilot…). |
| `skills/r-tutor/SKILL.md` | students | Claude Code skill version. Drops into `~/.claude/skills/r-tutor/`. |
| `CLAUDE.md.example` | students | Template for their own coursework directory. |
| `assessment_wording_draft.md` | **staff only** | Draft assessment wording. **Needs module-team sign-off — do not publish.** |

## The three layers, and why

A tutor prompt on its own is bypassable in four seconds by opening another tab,
so on its own it mostly disciplines the students who least need it. It works as
one of three:

1. **Assessment design** (strongest lever) — the process appendix and
   debug-the-generated-code items in `assessment_wording_draft.md`. Assesses the
   evaluative skill directly instead of prohibiting the tool. MLO-5 already
   requires students to *defend* analytical choices, which is the mandate.
2. **The session 3 demo** (most persuasive) — the employability argument lands
   far harder *after* students watch a model produce confidently wrong R than
   before. Run the code live; don't read the output off the slide.
3. **The tutor prompt** (a gift, not a fence) — framed as something that makes
   them better, not something that stops them cheating. Its second purpose is
   that the prompt is itself a worked example of context engineering, so it can
   be taught *from*.

## The examples are verified

Every code example in the slides and the website page was run against
**R 4.6.1 / dplyr 1.2.1** and does what the slide claims. This matters more than
usual: a segment about models being confidently wrong loses all its authority if
the lecturer is confidently wrong in it.

Re-verify after major tidyverse updates — particularly:

- `if_else()` keeping the `Date` class in exhibit F (dplyr behaviour)
- `$` partial matching warning behaviour on tibbles vs `data.frame`s
- deprecation status of anything used as a "model suggested a dead function"
  example

The seven slide exhibits, all non-erroring:

1. `mean(x, na.omit = TRUE)` → `NA` (argument absorbed by `...`)
2. `as.numeric()` on a factor of numerals → level codes
3. `filter(g != "a")` also drops `NA` rows
4. `left_join()` on a duplicated key inflates row count 3 → 4
5. `sapply()` returns matrix or list depending on the data
6. `ifelse()` strips the `Date` class
7. `mean(c(a, b))` inside `mutate()` — one value for every row

Exhibit 4 is the most important one; it's the bug that actually ruins real
analyses, and the habit it teaches (`nrow()` before and after every join) is the
single most transferable thing in the segment.

## Placement

Put the segment in **session 3 (Introduction to R)**, after the first hands-on
exercises — students need enough R to read the examples, and the argument is more
credible once they've felt the friction themselves. Then refer back to it: the
join exhibit belongs again in session 5 when joins are taught properly.

**Check with Richard Anney first.** His sessions 1–2 cover the role of code in
scientific analysis, reproducibility and documentation; the AI conversation may
already be there in some form, and it shouldn't contradict him.

## Rendering

`met581_llm_demo_slides.qmd` and `using_ai_assistants.qmd` render as part of the
site. The `.md` files deliberately do not — students copy them raw, and
`assessment_wording_draft.md` must not be published.

The slides use the `drop` webr plugin (as lectures 01/06/07 do) so students can
run the exhibits in the browser during the session.
