# Data Cleaning Practical: Student Brief

The three cohort CSV files are deliberately raw and contain a small number of planted data-quality problems.
Your task is to detect, document, and repair them reproducibly before carrying out statistical analysis.
Do not edit the CSVs manually: import them, preserve the raw objects, and create cleaned objects in R.

## Files To Audit
- `bioinformatics_msc_stats_baseline.csv`: one row should represent one participant.
- `bioinformatics_msc_stats_visits.csv`: one row should represent one participant at one visit.
- `bioinformatics_msc_stats_mortality_comorbidity.csv`: one row should represent one participant.
- `bioinformatics_msc_stats_codebook.csv`: use the documented levels, units, ranges, and meanings as validation rules.

## Minimum Checks
1. Confirm the number of rows and columns and inspect inferred data types.
2. Test the expected keys for missing values and duplicates.
3. List every distinct value and frequency for categorical variables.
4. Repeat categorical checks after trimming whitespace and converting text to a common case.
5. Compare numeric minima and maxima with the codebook and with subject-matter plausibility.
6. Cross-check redundant information, such as visit number versus visit label and months since baseline.
7. Check that variables repeated across linked tables agree for the same participant.
8. Produce a cleaning log containing table, row/key, variable, original value, cleaned value, and rule.

## Suggested R Tools
- Base R: `unique()`, `table()`, `duplicated()`, `trimws()`, `tolower()`, `range()`, and `merge()`.
- Tidyverse alternatives: `count()`, `distinct()`, `str_trim()`, `str_to_lower()`, `case_when()`, `anti_join()`, and `pivot_wider()`.

## Expected Deliverables
- Cleaned versions of all three data tables.
- A reproducible cleaning script.
- A cleaning log and a short paragraph explaining which checks found each class of problem.
- A final validation showing unique keys, intended categorical levels, and plausible numeric ranges.

## Important Note
The ordinary missing values in selected laboratory and questionnaire variables are part of the cohort design, not necessarily data-entry mistakes. Distinguish missing-data handling from correction of invalid entries.
