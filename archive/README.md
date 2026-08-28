# Archive

Material from the old **MET581 - Computing for Bioinformatics and Genetic
Epidemiology** module that is no longer taught in
**Data Science for Life Sciences I**.

Nothing in here is rendered: `_quarto.yml` excludes `archive/` from the
project render, and the corresponding output has been removed from `docs/`.
It is kept in the repo because the content is still good and may be wanted
again.

## `09_ShinyApp/`

Two lectures' worth of R Shiny material — reactive UI, inputs/outputs,
`eventReactive`, layout, plus a large set of worked code examples and
solutions (~7,600 lines in `met581_09_shiny_code_examples.qmd`).

**Why archived:** Shiny is not in the new module syllabus. The redesigned
course stops at reproducible analysis pipelines; interactive apps are out of
scope.

## `08_Modelling_in_R/`

Linear and logistic modelling in R: `lm()`/`glm()`, model summaries and
diagnostics, `broom`, plus a practice workbook and homework.

**Why archived:** this topic did not disappear — it *changed owner*. In the new
module, **sessions 13–14, "Regression and Prediction in R", are delivered by
John Watkins**. The syllabus for those sessions (simple and multiple linear
regression, factor variables, prediction, model fit, regression diagnostics,
an introduction to logistic regression) overlaps substantially with what is
here.

> **Handover:** offer this material to John Watkins rather than letting it rot.
> `met581_08_modelling_r.qmd` (slides), `modelling_in_r_practice.qmd`
> (practice), `../archive/10_resources_workshop_answers/modelling_in_r_practice_answers.qmd`
> (answers) and the two PDFs are the whole set. Rendered HTML for these is
> recoverable from git history (`git show 4f78824:docs/08_Modelling_in_R/...`).

## `10_resources_workshop_answers/`

Answer key for the modelling practice workbook, moved out of
`10_resources/01_workshop_answers/` so the archived lecture stays self-contained.

## Recovering the rendered versions

The rendered HTML for all of the above was deleted from `docs/` in the same
commit that created this directory. To get it back:

```sh
git log --diff-filter=D --name-only -- 'docs/09_ShinyApp/*'
git checkout <commit-before-deletion> -- docs/09_ShinyApp
```
