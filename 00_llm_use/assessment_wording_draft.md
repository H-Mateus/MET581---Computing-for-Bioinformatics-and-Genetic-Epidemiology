# Draft assessment wording — AI use

**Status: draft for discussion with the module team.** Nothing here is agreed.
Assessment wording and marking criteria need sign-off from the module lead (John
Watkins) and must be checked against current Cardiff University academic
integrity policy on generative AI, which supersedes anything below.

Three proposals, in descending order of how much they'd need agreeing.

---

## 1. Process appendix (report, 50%)

**Rationale.** MLO-5 already requires students to *"defend analytical choices and
methodological approaches … drawing on relevant literature, statistical
reasoning, and critical reflection."* An appendix on tool use is a natural
instrument for exactly that outcome, and it converts an unenforceable prohibition
into an assessable skill.

The key design property: **honest answers are cheap to write and fabricated ones
are hard**, because the interesting content is a specific error and how it was
caught. That's difficult to invent convincingly and easy to probe if it looks
thin.

### Draft student-facing wording

> **Appendix: Development process (up to 300 words, excluded from the word
> count)**
>
> Briefly describe how you used AI assistants, if at all, in producing this
> report. Address:
>
> - what you used them for (e.g. debugging, explaining errors, drafting prose,
>   generating code);
> - one specific instance where an assistant produced something incorrect,
>   inappropriate for your data, or that you chose to reject — and how you
>   identified it;
> - what you changed as a result.
>
> If you did not use AI assistants, say so and describe instead one point where
> you had to choose between analytical approaches, and how you decided.
>
> This appendix is not assessed for writing quality and there is no penalty for
> declaring extensive use. It is assessed as evidence of critical evaluation of
> your own analytical process. Inaccurate declarations are an academic integrity
> matter.

### Marking note (internal)

Not a separate criterion — feeds the existing MLO-5 judgement. Distinguishing
signals:

- **Strong:** names a concrete failure with a mechanism ("suggested
  `summarise_each()`, which is deprecated"; "wrote a `left_join()` that inflated
  my row count from 240 to 287 — I caught it checking `nrow()`").
- **Weak:** generic and mechanism-free ("I checked all the code it gave me
  carefully"). Not penalised, but not evidence of anything either.
- **Concerning:** an appendix describing no involvement in analytical decisions,
  in a report whose code is uniform and idiomatic in a way the student's
  formative work was not. Grounds for a conversation, not an accusation.

---

## 2. "Debug the generated code" items (short-answer papers, 25% each)

**Rationale.** This assesses the capability we claim to be teaching — reading and
evaluating code — rather than the capability that has been commoditised. It's
also close to AI-proof: pasting the item into an assistant tends to produce
confident wrong diagnoses, because these are exactly the bugs models generate.

### Draft item format

> The following R code was produced by an AI assistant in response to the
> request: *"[request]"*. It runs without error.
>
> ```r
> [code]
> ```
>
> **(a)** State what the code actually does, and how it differs from what was
> requested. *(3 marks)*
> **(b)** Explain the underlying R behaviour that causes the discrepancy.
> *(4 marks)*
> **(c)** Give corrected code. *(2 marks)*
> **(d)** State one check you would add to a pipeline to catch this class of
> error in future. *(1 mark)*

Part (d) is the one that transfers — it's asking for a habit, not a fix.

### Verified item bank

All of the following were checked against R 4.6.1 / dplyr 1.2.1. All run without
error and return plausible output. Full worked versions are in
`met581_llm_demo_slides.qmd`.

| # | Bug | Request it answers | Concept |
|---|---|---|---|
| 1 | `mean(x, na.omit = TRUE)` returns `NA` | "mean of a column with missing values" | `...` silently absorbs bad argument names |
| 2 | `as.numeric(factor(c("10","20","5")))` → `1 2 3` | "convert this column to numbers" | factors store level codes |
| 3 | `filter(group != "a")` drops `NA` rows too | "filter out group a" | `NA` in comparisons; `filter()` keeps only `TRUE` |
| 4 | `left_join()` on a duplicated key: 3 rows → 4 | "join phenotype onto samples" | key cardinality; silent row inflation |
| 5 | `sapply()` returns matrix or list depending on data | "apply this function across the list" | type instability |
| 6 | `ifelse()` on `Date` returns numeric | "flag dates after March" | class stripping; `if_else()` |
| 7 | `mean(c(a, b))` in `mutate()` — same value every row | "add a column with the mean of a and b" | vectorised vs rowwise |
| 8 | `1:length(x)` on empty input gives `1 0` | "loop over the elements" | `seq_along()` |
| 9 | `d$val` partial-matches `d$value` on a `data.frame` | "pull out that column" | partial matching; tibbles don't |

Items 1–4 are the highest value: they're the ones that produce wrong *results*
rather than wrong *types*, and item 4 is the one that ruins real analyses.

Because these are on the public module site, exam items should use the same
*mechanisms* with different surface presentation — different data, different
column names, embedded in a longer pipeline.

---

## 3. Not proposed, but worth a decision

Two things I'd flag for the team rather than recommend:

- **Viva / oral defence on the report.** Fully robust to AI use, and MLO-5 is
  phrased as if someone once considered it ("defend"). But 30 students × 10
  minutes is ~5 hours of staff time in a 5-week block that's already dense, and
  it changes the assessment type on the module description. Probably not for
  year one.
- **A blanket declaration checkbox.** Common, and near-worthless — it produces no
  evidence of anything and signals that the module treats this as a compliance
  exercise. Proposal 1 costs students about the same effort and actually
  assesses something.

---

## Coordination needed

- **Sessions 1–2 (Anney)** cover "the role of code in scientific analysis",
  reproducibility, documentation and note-taking. The AI-use conversation
  arguably belongs there, or should at minimum be consistent with whatever is
  said there. Worth checking before session 3 to avoid contradicting him.
- **The statistics half (Wills, Farewell, Watkins)** — the 25% Applied
  Statistics paper is not mine. If the debug-the-code item format is adopted,
  the statistical equivalents (t-test on inappropriate data, uncorrected
  multiple testing, correlation reported without a plot) would need writing by
  whoever owns that paper.
- **University policy** takes precedence over all of the above and should be
  quoted directly in the module handbook rather than paraphrased here.
