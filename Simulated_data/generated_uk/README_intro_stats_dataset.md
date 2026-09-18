# Introductory Biostatistics Teaching Dataset

This folder contains a fully simulated England-based older adult cardiometabolic cohort designed for an introductory statistics module.
The cohort now spans 50 to 90 years and includes five years of follow-up so that multimorbidity, frailty, mortality, and death-censored visits can be taught alongside core introductory statistics.

## Files
- `bioinformatics_msc_stats_baseline.csv`: one row per participant with demographics, deprivation, lifestyle, clinical measures, laboratory results, and binary outcomes.
- `bioinformatics_msc_stats_visits.csv`: repeated measurements at baseline, 12, 24, 36, 48, and 60 months for paired tests, change scores, attrition, and longitudinal plots.
- `bioinformatics_msc_stats_mortality_comorbidity.csv`: linked participant-level comorbidity, frailty, predicted five-year mortality risk, death timing, and broad cause of death.
- `bioinformatics_msc_stats_codebook.csv`: variable dictionary with labels, data types, units, and teaching suggestions.
- `bioinformatics_msc_stats_diagnostics.csv`: summary metrics used to judge whether the simulated dataset feels plausible.
- `bioinformatics_msc_stats_variable_summaries.csv`: long-format summary statistics for every variable.
- `bioinformatics_msc_stats_category_levels.csv`: counts and percentages for categorical levels.
- `bioinformatics_msc_stats_teaching_associations.csv`: association statistics for the main teaching examples.
- `validation_summary.md`: general dataset summary with full descriptives and teaching associations.
- `mortality_comorbidity_model_notes.md`: plain-language explanation of the simulated mortality and comorbidity model.
- `uk_calibration_notes.md`: source-backed notes describing how the UK-focused prevalences and associations were calibrated.
- `data_cleaning_student_brief.md`: spoiler-free student instructions for auditing and cleaning the deliberately messy data.
- `data_cleaning_instructor_key.md`: instructor-only answer key with every planted problem and its exact location.
- `data_cleaning_issue_key.csv`: machine-readable audit log of the planted problems and intended values.
- `simulate_intro_stats_dataset.R`: the reproducible generator script.

## Cohort profile
- Participants: 2400 baseline records across four English sites.
- Visit rows: 10732 records covering baseline to 60 months.
- Age range: 51 to 89 years.
- Obesity prevalence: 33.8%.
- Measured hypertension prevalence: 58.4%.
- Diagnosed hypertension prevalence: 33.8%.
- Prediabetes prevalence: 30.6%.
- Type 2 diabetes prevalence: 8.2%.

## Design notes
- The data are entirely simulated and do not describe real patients.
- The cohort is UK-flavoured rather than generic. Variables such as IMD quintile, self-rated general health wording, NHS-style risk factors, older-age comorbidities, and blood group frequencies were chosen to feel familiar in an England teaching context.
- This is no longer a strict NHS Health Check age-band sample. The older age range deliberately increases chronic disease, multimorbidity, attrition, and deaths for teaching.
- Associations were tuned to be plausible rather than perfect. Some variables are moderately related, some are weakly related, and a few were left close to null on purpose.
- BMI is derived from height and weight, waist-to-height ratio is derived from waist circumference and height, and LDL cholesterol is estimated from the lipid profile. Those stronger relationships are therefore expected.
- The `prediabetes` variable is intended as an accessible teaching label for non-diabetic hyperglycaemia or prediabetes.
- A small amount of missingness is included in selected questionnaire and laboratory variables.
- The distributed CSVs deliberately contain 41 planted data-quality issues for cleaning exercises, including categorical inconsistencies, invalid ranges, and duplicate visit rows.
- Treat the three cohort CSVs as raw teaching data. The codebook records the intended categories and ranges; the instructor key should be withheld from students until debriefing.
- The reproducible master seed is `20260420` and the selected simulation seed is `20260421`.

## Suggested practical uses
- Descriptive statistics and visualisation: age, BMI, systolic blood pressure, HbA1c, CRP, triglycerides, and total:HDL ratio.
- Probability and odds: smoking, measured hypertension, diagnosed hypertension, prediabetes, type 2 diabetes, hospital admission, frailty, and death.
- Distributions and transformations: triglycerides and CRP are deliberately right-skewed, while height is closer to normal.
- Categorical data: IMD quintile, smoking status, blood group, self-rated health, and ethnicity group.
- Parametric tests: compare systolic blood pressure, BMI, or fasting glucose between groups.
- Non-parametric tests: compare CRP across smoking groups or self-rated health categories.
- Regression: fit linear models for systolic blood pressure or glucose, and logistic models for prediabetes, type 2 diabetes, hospital admission, or mortality.
- Confounding and mediation examples: obesity, central adiposity, deprivation, smoking, family history, multimorbidity, and frailty in relation to clinical outcomes.
- Longitudinal work: use the visits table for paired tests, repeated measures plots, change-score analyses, death-censoring, and attrition checks.

## Teaching Suggestions By Learning Objective
1. Understand data structure and variable types. Use `bioinformatics_msc_stats_baseline.csv` and `bioinformatics_msc_stats_visits.csv` to identify continuous variables such as `age_years` and `bmi_kg_m2`, binary variables such as `prediabetes` and `type2_diabetes`, categorical variables such as `smoking_status` and `blood_group`, and ordered variables such as `imd_quintile` and `self_rated_health`. Teaching tip: ask students to classify each variable before they choose any graph or statistical test.
2. Summarise data appropriately. Use `age_years`, `bmi_kg_m2`, `systolic_bp_mmHg`, `weekly_exercise_min`, and `crp_mg_L` to compare mean and standard deviation against median and interquartile range. Teaching tip: make students justify why one summary is more appropriate than another instead of treating summary tables as automatic output.
3. Recognise common distributions. `height_cm` is roughly normal, while `triglycerides_mmol_L` and `crp_mg_L` are right-skewed, and outcomes such as `measured_hypertension` and `prediabetes` behave like binary variables. Teaching tip: ask students to predict the shape of each distribution before they plot it.
4. Work with probability, risk, and odds. Use prevalence of `current_smoker`, `obesity`, `prediabetes`, `type2_diabetes`, `hospital_admission_5y`, and `died_during_followup` to teach absolute probability, odds, odds ratios, and conditional probability. Teaching tip: keep returning to plain-language interpretations such as 'about 1 in 4' before introducing formulas.
5. Analyse categorical associations. Good examples are `smoking_status` by `self_rated_health`, `imd_quintile` by `type2_diabetes`, and `blood_group` by `prediabetes`. Teaching tip: include one real association and one near-null association so students see that not every cross-tabulation should be significant.
6. Compare two groups with parametric methods. Use t-tests or confidence intervals for means with outcomes such as `systolic_bp_mmHg` by `sex_at_birth`, or `fasting_glucose_mmol_L` by `obesity`. Teaching tip: have students inspect the distributions and spread before they run the test, so the method follows the reasoning.
7. Use non-parametric methods when appropriate. `crp_mg_L` across `smoking_status` or `self_rated_health` works well for Mann-Whitney or Kruskal-Wallis tests. Teaching tip: stress that non-parametric methods are often the more defensible choice for skewed data rather than a weaker fallback.
8. Interpret correlation properly. Use `age_years` with `systolic_bp_mmHg`, `bmi_kg_m2` with `fasting_glucose_mmol_L`, and `hdl_cholesterol_mmol_L` with `triglycerides_mmol_L`. Teaching tip: make students describe direction, strength, and plausibility separately, and repeat that correlation is not causation.
9. Fit and interpret linear regression. Good outcomes are `systolic_bp_mmHg`, `fasting_glucose_mmol_L`, or `resting_heart_rate_bpm`, with predictors such as `age_years`, `sex_at_birth`, `bmi_kg_m2`, `smoking_status`, and `weekly_exercise_min`. Teaching tip: start with one-predictor models and then add covariates so students can see adjustment happen rather than only seeing the final model.
10. Fit and interpret logistic regression. Use binary outcomes such as `prediabetes`, `measured_hypertension`, `type2_diabetes`, `hospital_admission_5y`, or `died_during_followup`. Teaching tip: insist on translating odds ratios back into plain English because students often confuse odds ratios with risk ratios.
11. Teach confounding and adjustment. The association between `obesity` and `prediabetes`, or between `imd_quintile` and `type2_diabetes`, is useful for showing how age, sex, ethnicity, and lifestyle can alter crude effect estimates. Teaching tip: require the crude result first, then the adjusted result, then a short explanation of why they differ.
12. Introduce interaction and effect modification. Possible examples are whether the BMI and glycaemia relationship differs by `sex_at_birth` or `ethnicity_group`, or whether age relates to blood pressure differently by sex. Teaching tip: only introduce interaction once students are comfortable with main effects, otherwise interpretation becomes noise.
13. Work with repeated measures and paired data. The visits table supports paired analysis of `weight_kg`, `systolic_bp_mmHg`, `hba1c_mmol_mol`, or `weekly_exercise_min` between visit 0 and later visits, including comparison by `lifestyle_program_enrolled`. Teaching tip: use this to explain why repeated observations from the same person are not independent and why deaths censor later observations.
14. Handle missing data sensibly. `hba1c_mmol_mol` and `crp_mg_L` contain light missingness, which is enough to discuss complete-case analysis, missing-data summaries, and potential bias. Teaching tip: ask students to compare the characteristics of complete and incomplete cases before they drop rows.
15. Emphasise effect sizes, uncertainty, and realism. Because the dataset contains moderate rather than extreme associations, it is useful for confidence intervals, practical significance, and the difference between statistical significance and importance. Teaching tip: require an estimate, a confidence interval, and one sentence of practical interpretation rather than a p-value alone.
16. Audit and clean raw data before analysis. Ask students to check duplicated keys, unexpected factor levels, leading or trailing whitespace, inconsistent case, and values outside codebook ranges. Teaching tip: require a reproducible cleaning log showing the original value, rule applied, and cleaned value.

## General Teaching Tips
- Start with plots before tests wherever possible.
- Ask students to predict the likely direction of an association before they run any code.
- Keep at least one weak or null example in each practical so students do not expect significance everywhere.
- Repeatedly distinguish `measured_hypertension` from `diagnosed_hypertension` so students see that similar-looking binary variables can represent different underlying concepts.
- Use the baseline table when teaching cross-sectional methods, the visits table when teaching within-person change and attrition, and the mortality/comorbidity table when teaching risk prediction and outcome modelling.

## Re-run
From the command line, run:

```powershell
Rscript simulate_intro_stats_dataset.R generated_uk 2400 20260420
```

The generated dataset currently retains approximately 75.5% of participants at 24 months; see diagnostics for 60-month retention and mortality.
