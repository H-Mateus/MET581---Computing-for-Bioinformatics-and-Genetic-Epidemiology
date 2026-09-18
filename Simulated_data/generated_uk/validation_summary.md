# General Dataset Summary

This summary provides a full descriptive overview of the final England-focused simulated dataset.
It includes variable-level summary statistics for both tables and association statistics for the main teaching examples.
These summaries describe the raw distributed CSVs, so deliberately planted data-quality problems are visible in the levels, ranges, row counts, and some association estimates.

## Summary Files
- `bioinformatics_msc_stats_variable_summaries.csv` contains long-format summary statistics for every variable.
- `bioinformatics_msc_stats_category_levels.csv` contains counts and percentages for categorical levels.
- `bioinformatics_msc_stats_teaching_associations.csv` contains the association statistics used in the practical teaching examples.
- `bioinformatics_msc_stats_mortality_comorbidity.csv` contains the linked risk prediction and mortality outcome table.

## Cohort Size
- Participants: 2400
- Visit rows: 10730
- Retention at 24 months: 75.5%
- Retention at 60 months: 57.4%
- Deaths over five years: 8.4%

## Teaching Association Statistics
| Theme | Variables | Method | N | Statistic | Estimate | P value | Details |
| --- | --- | --- | ---: | --- | ---: | ---: | --- |
| Correlation | age_years vs systolic_bp_mmHg | Pearson correlation | 2400 | r | 0.093 | <0.001 |   |
| Correlation | age_years vs diastolic_bp_mmHg | Pearson correlation | 2400 | r | 0.309 | <0.001 |   |
| Correlation | bmi_kg_m2 vs fasting_glucose_mmol_L | Pearson correlation | 2400 | r | 0.374 | <0.001 |   |
| Correlation | bmi_kg_m2 vs hba1c_mmol_mol | Pearson correlation | 2300 | r | 0.289 | <0.001 |   |
| Correlation | weekly_exercise_min vs resting_heart_rate_bpm | Pearson correlation | 2400 | r | -0.191 | <0.001 |   |
| Correlation | hdl_cholesterol_mmol_L vs triglycerides_mmol_L | Pearson correlation | 2342 | r | -0.338 | <0.001 |   |
| Correlation | age_years vs mortality_risk_5y_pct | Pearson correlation | 2400 | r | 0.667 | <0.001 |   |
| Correlation | multimorbidity_count vs mortality_risk_5y_pct | Pearson correlation | 2400 | r | 0.705 | <0.001 |   |
| Correlation | frailty_index vs mortality_risk_5y_pct | Pearson correlation | 2400 | r | 0.755 | <0.001 |   |
| Group comparison | sex_at_birth vs systolic_bp_mmHg | Two-sample t-test (Male - Female) | 2397 | mean difference | 2.021 | 0.130 | Female mean=138.530; Male mean=140.551 |
| Non-parametric comparison | smoking_status vs crp_mg_L | Kruskal-Wallis test | 2307 | chi-squared | 49.095 | <0.001 | Never median=1.950; Former median=1.960; Current median=2.460; Currnt median=2.550 |
| Binary association | obesity vs prediabetes | Odds ratio for obesity Yes vs No | 2400 | odds ratio | 2.006 | <0.001 | Yes prevalence when exposed=40.7%; when unexposed=25.5% |
| Binary association | obesity vs type2_diabetes | Odds ratio for obesity Yes vs No | 2400 | odds ratio | 3.469 | <0.001 | Yes prevalence when exposed=14.9%; when unexposed=4.8% |
| Binary association | diagnosed_hypertension vs high_cardiovascular_risk | Odds ratio for diagnosed hypertension Yes vs No | 2400 | odds ratio | 1.926 | <0.001 | Yes prevalence when exposed=40.5%; when unexposed=26.1% |
| Binary association | family_history_diabetes vs type2_diabetes | Odds ratio for family history diabetes Yes vs No | 2400 | odds ratio | 2.371 | <0.001 | Yes prevalence when exposed=12.8%; when unexposed=5.8% |
| Binary association | smoking_status vs diagnosed_hypertension | Odds ratio for current smoking vs other smoking categories | 2400 | odds ratio | 1.251 | 0.070 | Yes prevalence when exposed=38.1%; when unexposed=33.0% |
| Binary association | chronic_kidney_disease vs died_during_followup | Odds ratio for CKD Yes vs No | 2400 | odds ratio | 3.203 | <0.001 | Yes prevalence when exposed=16.2%; when unexposed=5.7% |
| Binary association | frailty_category vs died_during_followup | Odds ratio for severe frailty vs other frailty categories | 2400 | odds ratio | 9.248 | <0.001 | Yes prevalence when exposed=39.5%; when unexposed=6.6% |
| Binary association | care_home_resident vs died_during_followup | Odds ratio for care-home residence Yes vs No | 2400 | odds ratio | 4.537 | <0.001 | Yes prevalence when exposed=25.6%; when unexposed=7.1% |
| Categorical association | blood_group vs prediabetes | Chi-square test | 2400 | Cramer's V | 0.033 | 0.456 |   |
| Categorical association | imd_quintile vs type2_diabetes | Chi-square test | 2400 | Cramer's V | 0.137 | <0.001 |   |
| Categorical association | frailty_category vs died_during_followup | Chi-square test | 2400 | Cramer's V | 0.319 | <0.001 |   |
| Non-parametric comparison | self_rated_health vs crp_mg_L | Kruskal-Wallis test | 2266 | chi-squared | 121.993 | <0.001 | Very bad median=2.345; Bad median=1.940; Fair median=1.790; Good median=1.770; Very good median=1.580; very good median=1.990; Very Good median=1.490; Very good  median=1.540 |
| Repeated measures | weight_kg visit_0 vs visit_2 | Paired t-test (visit_2 - visit_0) | 1812 | mean change | -0.204 | <0.001 | visit_0 mean=80.757; visit_2 mean=80.553 |
| Repeated measures | systolic_bp_mmHg visit_0 vs visit_2 | Paired t-test (visit_2 - visit_0) | 1812 | mean change | 0.773 | <0.001 | visit_0 mean=138.403; visit_2 mean=139.176 |
| Repeated measures | weight_kg visit_0 vs visit_5 | Paired t-test (visit_5 - visit_0) | 1378 | mean change | -0.742 | <0.001 | visit_0 mean=79.944; visit_5 mean=79.201 |
| Programme comparison | lifestyle_program_enrolled vs weight_kg change | Two-sample t-test on change scores (Yes - No) | 1812 | mean difference in change | -2.946 | <0.001 | No mean change=0.401; Yes mean change=-2.545 |

## Baseline Variable Summaries
### participant_id
Unique participant identifier (`identifier`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Unique values | 2400 |
| Duplicate values | 0 |

### site_code
Recruiting clinic site in England (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 5 |
| Mode count | 700 |
| Mode percent | 29.2% |
| Mode level | Birmingham |

| Level | Count | Percent |
| --- | ---: | ---: |
| Bristol | 549 | 22.9% |
| Birmingham | 700 | 29.2% |
| Leeds | 573 | 23.9% |
| Manchester | 574 | 23.9% |
| Manchster | 4 | 0.2% |

### imd_quintile
Index of Multiple Deprivation quintile (1 least deprived, 5 most deprived) (`ordered integer`, units: `quintile`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 3.026 |
| SD | 1.413 |
| Median | 3.000 |
| IQR | 2.000 |
| Min | 1.000 |
| Q1 | 2.000 |
| Q3 | 4.000 |
| Max | 9.000 |

### recruitment_year
Year of recruitment (`integer`, units: `year`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 2024.903 |
| SD | 0.766 |
| Median | 2025.000 |
| IQR | 1.000 |
| Min | 2024.000 |
| Q1 | 2024.000 |
| Q3 | 2025.000 |
| Max | 2026.000 |

### age_years
Age at recruitment (`continuous`, units: `years`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 70.641 |
| SD | 8.446 |
| Median | 71.000 |
| IQR | 13.000 |
| Min | 51.000 |
| Q1 | 64.000 |
| Q3 | 77.000 |
| Max | 89.000 |

### sex_at_birth
Recorded sex at birth (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 3 |
| Mode count | 1203 |
| Mode percent | 50.1% |
| Mode level | Male |

| Level | Count | Percent |
| --- | ---: | ---: |
| Female | 1194 | 49.8% |
| Male | 1203 | 50.1% |
| female | 3 | 0.1% |

### ethnicity_group
Broad ethnicity group (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 6 |
| Mode count | 1909 |
| Mode percent | 79.5% |
| Mode level | White |

| Level | Count | Percent |
| --- | ---: | ---: |
| White | 1909 | 79.5% |
| Asian | 258 | 10.8% |
| Black | 102 | 4.2% |
| Mixed | 62 | 2.6% |
| Other | 66 | 2.8% |
| Asain | 3 | 0.1% |

### blood_group
ABO blood group (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 4 |
| Mode count | 1196 |
| Mode percent | 49.8% |
| Mode level | O |

| Level | Count | Percent |
| --- | ---: | ---: |
| O | 1196 | 49.8% |
| A | 897 | 37.4% |
| B | 227 | 9.5% |
| AB | 80 | 3.3% |

### smoking_status
Current smoking history category (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 4 |
| Mode count | 1268 |
| Mode percent | 52.8% |
| Mode level | Never |

| Level | Count | Percent |
| --- | ---: | ---: |
| Never | 1268 | 52.8% |
| Former | 795 | 33.1% |
| Current | 333 | 13.9% |
| Currnt | 4 | 0.2% |

### alcohol_units_per_week
Self-reported alcohol intake (`continuous`, units: `units/week`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 8.860 |
| SD | 5.392 |
| Median | 8.000 |
| IQR | 7.000 |
| Min | 0.000 |
| Q1 | 5.000 |
| Q3 | 12.000 |
| Max | 40.000 |

### weekly_exercise_min
Weekly moderate exercise time (`continuous`, units: `minutes/week`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 85.120 |
| SD | 62.296 |
| Median | 81.000 |
| IQR | 92.250 |
| Min | 0.000 |
| Q1 | 34.000 |
| Q3 | 126.250 |
| Max | 289.000 |

### inactive_under_30min
Less than 30 minutes of moderate or vigorous activity per week (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1851 |
| Mode percent | 77.1% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1851 | 77.1% |
| Yes | 549 | 22.9% |

### sleep_hours_per_night
Average sleep per night (`continuous`, units: `hours`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2367 |
| Missing n | 33 |
| Missing % | 1.4% |
| Mean | 6.704 |
| SD | 0.781 |
| Median | 6.700 |
| IQR | 1.000 |
| Min | 4.500 |
| Q1 | 6.200 |
| Q3 | 7.200 |
| Max | 9.500 |

### fruit_veg_portions_per_day
Daily fruit and vegetable intake (`continuous`, units: `portions/day`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2358 |
| Missing n | 42 |
| Missing % | 1.8% |
| Mean | 3.955 |
| SD | 1.081 |
| Median | 3.900 |
| IQR | 1.500 |
| Min | 0.500 |
| Q1 | 3.200 |
| Q3 | 4.700 |
| Max | 7.600 |

### family_history_cvd
Family history of cardiovascular disease (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1698 |
| Mode percent | 70.8% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1698 | 70.8% |
| Yes | 702 | 29.2% |

### family_history_diabetes
Family history of diabetes (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1585 |
| Mode percent | 66.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1585 | 66.0% |
| Yes | 815 | 34.0% |

### height_cm
Standing height (`continuous`, units: `cm`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 168.725 |
| SD | 9.471 |
| Median | 168.300 |
| IQR | 14.100 |
| Min | 145.000 |
| Q1 | 161.600 |
| Q3 | 175.700 |
| Max | 199.700 |

### weight_kg
Body weight (`continuous`, units: `kg`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 80.815 |
| SD | 15.057 |
| Median | 80.050 |
| IQR | 20.500 |
| Min | 45.200 |
| Q1 | 70.300 |
| Q3 | 90.800 |
| Max | 132.600 |

### bmi_kg_m2
Body mass index derived from height and weight (`continuous`, units: `kg/m^2`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 28.277 |
| SD | 4.053 |
| Median | 28.100 |
| IQR | 5.625 |
| Min | 19.000 |
| Q1 | 25.500 |
| Q3 | 31.125 |
| Max | 41.200 |

### obesity
BMI at least 30 kg/m^2 (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 4 |
| Mode count | 1590 |
| Mode percent | 66.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1590 | 66.2% |
| Yes | 808 | 33.7% |
| Y | 1 | 0.0% |
| YES | 1 | 0.0% |

### waist_cm
Waist circumference (`continuous`, units: `cm`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 93.321 |
| SD | 9.759 |
| Median | 93.100 |
| IQR | 13.500 |
| Min | 62.000 |
| Q1 | 86.400 |
| Q3 | 99.900 |
| Max | 122.700 |

### waist_to_height_ratio
Waist-to-height ratio (`continuous`, units: `ratio`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 0.554 |
| SD | 0.060 |
| Median | 0.550 |
| IQR | 0.080 |
| Min | 0.360 |
| Q1 | 0.510 |
| Q3 | 0.590 |
| Max | 0.790 |

### high_central_adiposity
Waist-to-height ratio at least 0.6 (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1810 |
| Mode percent | 75.4% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1810 | 75.4% |
| Yes | 590 | 24.6% |

### systolic_bp_mmHg
Systolic blood pressure (`continuous`, units: `mmHg`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 140.040 |
| SD | 40.790 |
| Median | 139.000 |
| IQR | 17.000 |
| Min | 91.000 |
| Q1 | 131.000 |
| Q3 | 148.000 |
| Max | 1620.000 |

### diastolic_bp_mmHg
Diastolic blood pressure (`continuous`, units: `mmHg`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 80.743 |
| SD | 8.434 |
| Median | 81.000 |
| IQR | 11.000 |
| Min | 52.000 |
| Q1 | 75.000 |
| Q3 | 86.000 |
| Max | 109.000 |

### measured_hypertension
Measured hypertension or antihypertensive treatment (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1401 |
| Mode percent | 58.4% |
| Mode level | Yes |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 999 | 41.6% |
| Yes | 1401 | 58.4% |

### resting_heart_rate_bpm
Resting heart rate (`continuous`, units: `beats/min`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 71.567 |
| SD | 6.133 |
| Median | 72.000 |
| IQR | 9.000 |
| Min | 48.000 |
| Q1 | 67.000 |
| Q3 | 76.000 |
| Max | 96.000 |

### fasting_glucose_mmol_L
Fasting glucose (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 5.334 |
| SD | 0.730 |
| Median | 5.250 |
| IQR | 0.982 |
| Min | 3.600 |
| Q1 | 4.808 |
| Q3 | 5.790 |
| Max | 7.630 |

### hba1c_mmol_mol
HbA1c glycaemic marker (`continuous`, units: `mmol/mol`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2300 |
| Missing n | 100 |
| Missing % | 4.2% |
| Mean | 36.151 |
| SD | 6.971 |
| Median | 35.100 |
| IQR | 9.000 |
| Min | 25.000 |
| Q1 | 31.100 |
| Q3 | 40.100 |
| Max | 58.000 |

### type2_diabetes
Simulated type 2 diabetes status based on glycaemic profile (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2204 |
| Mode percent | 91.8% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2204 | 91.8% |
| Yes | 196 | 8.2% |

### prediabetes
Prediabetes or non-diabetic hyperglycaemia (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1665 |
| Mode percent | 69.4% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1665 | 69.4% |
| Yes | 735 | 30.6% |

### total_cholesterol_mmol_L
Total cholesterol (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 5.119 |
| SD | 0.616 |
| Median | 5.130 |
| IQR | 0.850 |
| Min | 2.930 |
| Q1 | 4.700 |
| Q3 | 5.550 |
| Max | 7.280 |

### raised_total_cholesterol
Total cholesterol at least 5 mmol/L (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1384 |
| Mode percent | 57.7% |
| Mode level | Yes |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1016 | 42.3% |
| Yes | 1384 | 57.7% |

### hdl_cholesterol_mmol_L
HDL cholesterol (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 1.297 |
| SD | 0.202 |
| Median | 1.300 |
| IQR | 0.270 |
| Min | 0.700 |
| Q1 | 1.160 |
| Q3 | 1.430 |
| Max | 1.950 |

### ldl_cholesterol_mmol_L
Estimated LDL cholesterol (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 3.056 |
| SD | 0.692 |
| Median | 3.060 |
| IQR | 0.940 |
| Min | 1.200 |
| Q1 | 2.590 |
| Q3 | 3.530 |
| Max | 5.520 |

### triglycerides_mmol_L
Triglycerides (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2342 |
| Missing n | 58 |
| Missing % | 2.4% |
| Mean | 1.690 |
| SD | 0.655 |
| Median | 1.580 |
| IQR | 0.840 |
| Min | 0.450 |
| Q1 | 1.210 |
| Q3 | 2.050 |
| Max | 5.500 |

### total_hdl_ratio
Total cholesterol divided by HDL cholesterol (`continuous`, units: `ratio`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 4.060 |
| SD | 0.903 |
| Median | 3.950 |
| IQR | 1.120 |
| Min | 2.040 |
| Q1 | 3.420 |
| Q3 | 4.540 |
| Max | 8.460 |

### high_total_hdl_ratio
Total-to-HDL cholesterol ratio at least 6 (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2319 |
| Mode percent | 96.6% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2319 | 96.6% |
| Yes | 81 | 3.4% |

### crp_mg_L
C-reactive protein (`continuous`, units: `mg/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2307 |
| Missing n | 93 |
| Missing % | 3.9% |
| Mean | 2.439 |
| SD | 1.620 |
| Median | 2.010 |
| IQR | 1.680 |
| Min | 0.260 |
| Q1 | 1.390 |
| Q3 | 3.070 |
| Max | 18.140 |

### creatinine_umol_L
Serum creatinine (`continuous`, units: `umol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 81.485 |
| SD | 12.342 |
| Median | 81.200 |
| IQR | 16.600 |
| Min | 45.000 |
| Q1 | 73.300 |
| Q3 | 89.900 |
| Max | 120.100 |

### egfr_ml_min_1_73m2
Estimated glomerular filtration rate (`continuous`, units: `mL/min/1.73m^2`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2368 |
| Missing n | 32 |
| Missing % | 1.3% |
| Mean | 73.967 |
| SD | 12.993 |
| Median | 73.750 |
| IQR | 18.650 |
| Min | 36.700 |
| Q1 | 64.475 |
| Q3 | 83.125 |
| Max | 114.900 |

### self_rated_health
Self-rated overall health using UK survey wording (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2358 |
| Missing n | 42 |
| Missing % | 1.8% |
| Levels observed | 8 |
| Mode count | 1094 |
| Mode percent | 46.4% |
| Mode level | Very bad |

| Level | Count | Percent |
| --- | ---: | ---: |
| Very bad | 1094 | 46.4% |
| Bad | 533 | 22.6% |
| Fair | 384 | 16.3% |
| Good | 209 | 8.9% |
| Very good | 135 | 5.7% |
| very good | 1 | 0.0% |
| Very Good | 1 | 0.0% |
| Very good  | 1 | 0.0% |

### longstanding_condition
Longstanding health condition (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1591 |
| Mode percent | 66.3% |
| Mode level | Yes |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 809 | 33.7% |
| Yes | 1591 | 66.3% |

### chronic_kidney_disease
Simulated chronic kidney disease status (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1781 |
| Mode percent | 74.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1781 | 74.2% |
| Yes | 619 | 25.8% |

### atrial_fibrillation
Simulated atrial fibrillation history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2058 |
| Mode percent | 85.8% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2058 | 85.8% |
| Yes | 342 | 14.2% |

### previous_mi
Previous myocardial infarction history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2075 |
| Mode percent | 86.5% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2075 | 86.5% |
| Yes | 325 | 13.5% |

### previous_stroke_tia
Previous stroke or transient ischaemic attack history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2159 |
| Mode percent | 90.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2159 | 90.0% |
| Yes | 241 | 10.0% |

### copd
Simulated chronic obstructive pulmonary disease status (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2212 |
| Mode percent | 92.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2212 | 92.2% |
| Yes | 188 | 7.8% |

### cancer_history
Previous cancer diagnosis history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2100 |
| Mode percent | 87.5% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2100 | 87.5% |
| Yes | 300 | 12.5% |

### osteoarthritis
Simulated osteoarthritis status (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1686 |
| Mode percent | 70.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1686 | 70.2% |
| Yes | 714 | 29.8% |

### depression_anxiety
Depression or anxiety history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2081 |
| Mode percent | 86.7% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2081 | 86.7% |
| Yes | 319 | 13.3% |

### dementia_cognitive_impairment
Dementia or cognitive impairment history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2183 |
| Mode percent | 91.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2183 | 91.0% |
| Yes | 217 | 9.0% |

### multimorbidity_count
Count of selected long-term conditions (`count`, units: `conditions`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 1.780 |
| SD | 1.371 |
| Median | 2.000 |
| IQR | 2.000 |
| Min | 0.000 |
| Q1 | 1.000 |
| Q3 | 3.000 |
| Max | 9.000 |

### falls_last_12m
Falls reported in the last year (`count`, units: `falls`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 0.444 |
| SD | 0.700 |
| Median | 0.000 |
| IQR | 1.000 |
| Min | 0.000 |
| Q1 | 0.000 |
| Q3 | 1.000 |
| Max | 5.000 |

### polypharmacy_5plus
Taking five or more regular medicines (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1714 |
| Mode percent | 71.4% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1714 | 71.4% |
| Yes | 686 | 28.6% |

### frailty_index
Simplified frailty index derived from age, conditions, falls, and polypharmacy (`continuous`, units: `index`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 0.215 |
| SD | 0.084 |
| Median | 0.210 |
| IQR | 0.116 |
| Min | 0.020 |
| Q1 | 0.155 |
| Q3 | 0.271 |
| Max | 0.512 |

### frailty_category
Frailty category derived from frailty index (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 4 |
| Mode count | 1228 |
| Mode percent | 51.2% |
| Mode level | Mild frailty |

| Level | Count | Percent |
| --- | ---: | ---: |
| Fit | 308 | 12.8% |
| Mild frailty | 1228 | 51.2% |
| Moderate frailty | 735 | 30.6% |
| Severe frailty | 129 | 5.4% |

### care_home_resident
Simulated care-home residence at baseline (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2232 |
| Mode percent | 93.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2232 | 93.0% |
| Yes | 168 | 7.0% |

### gp_visits_last_12m
General practice visits in the last year (`count`, units: `visits`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 3.945 |
| SD | 2.593 |
| Median | 4.000 |
| IQR | 3.000 |
| Min | 0.000 |
| Q1 | 2.000 |
| Q3 | 5.000 |
| Max | 18.000 |

### sick_days_last_12m
Days off work or study due to illness (`count`, units: `days`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 2.532 |
| SD | 2.013 |
| Median | 2.000 |
| IQR | 3.000 |
| Min | 0.000 |
| Q1 | 1.000 |
| Q3 | 4.000 |
| Max | 13.000 |

### on_antihypertensive
Currently taking blood pressure medication (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1792 |
| Mode percent | 74.7% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1792 | 74.7% |
| Yes | 608 | 25.3% |

### on_statin
Currently taking statin medication (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1550 |
| Mode percent | 64.6% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1550 | 64.6% |
| Yes | 850 | 35.4% |

### diagnosed_hypertension
Clinical hypertension diagnosis (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1590 |
| Mode percent | 66.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1590 | 66.2% |
| Yes | 810 | 33.8% |

### high_cardiovascular_risk
Elevated cardiovascular risk category (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1657 |
| Mode percent | 69.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1657 | 69.0% |
| Yes | 743 | 31.0% |

### hospital_admission_24m
Any hospital admission during the first 24 months (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2048 |
| Mode percent | 85.3% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2048 | 85.3% |
| Yes | 352 | 14.7% |

### hospital_admission_5y
Any hospital admission during five-year follow-up (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1361 |
| Mode percent | 56.7% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1361 | 56.7% |
| Yes | 1039 | 43.3% |

### metabolic_risk_group
Overall metabolic risk group (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 3 |
| Mode count | 1157 |
| Mode percent | 48.2% |
| Mode level | Low |

| Level | Count | Percent |
| --- | ---: | ---: |
| Low | 1157 | 48.2% |
| Intermediate | 615 | 25.6% |
| High | 628 | 26.2% |

### lifestyle_program_enrolled
Joined the lifestyle support programme (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1914 |
| Mode percent | 79.8% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1914 | 79.8% |
| Yes | 486 | 20.2% |

### mortality_risk_5y_pct
Predicted five-year mortality risk from the simulated risk model (`continuous`, units: `percent`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 7.908 |
| SD | 10.063 |
| Median | 4.200 |
| IQR | 7.025 |
| Min | 0.400 |
| Q1 | 2.100 |
| Q3 | 9.125 |
| Max | 60.000 |

### died_during_followup
Died during five-year follow-up (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2199 |
| Mode percent | 91.6% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2199 | 91.6% |
| Yes | 201 | 8.4% |

### death_month
Month of death after baseline for participants who died (`continuous`, units: `months`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 201 |
| Missing n | 2199 |
| Missing % | 91.6% |
| Mean | 32.657 |
| SD | 14.770 |
| Median | 34.000 |
| IQR | 24.000 |
| Min | 2.000 |
| Q1 | 21.000 |
| Q3 | 45.000 |
| Max | 59.000 |

### age_at_death
Age at death for participants who died (`continuous`, units: `years`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 201 |
| Missing n | 2199 |
| Missing % | 91.6% |
| Mean | 80.721 |
| SD | 6.913 |
| Median | 81.800 |
| IQR | 10.000 |
| Min | 62.000 |
| Q1 | 75.900 |
| Q3 | 85.900 |
| Max | 92.500 |

### primary_cause_of_death
Broad simulated primary cause of death (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 7 |
| Mode count | 2199 |
| Mode percent | 91.6% |
| Mode level | Not applicable |

| Level | Count | Percent |
| --- | ---: | ---: |
| Not applicable | 2199 | 91.6% |
| Cancer | 35 | 1.5% |
| Dementia and neurodegenerative disease | 42 | 1.8% |
| Ischaemic heart disease | 34 | 1.4% |
| Respiratory disease | 26 | 1.1% |
| Stroke | 30 | 1.2% |
| Other | 34 | 1.4% |


## Visit Variable Summaries
### participant_id
Unique participant identifier (`identifier`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Unique values | 2400 |
| Duplicate values | 8332 |

### visit_number
Visit order (`integer`, units: `visit index`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 2.187 |
| SD | 1.707 |
| Median | 2.000 |
| IQR | 3.000 |
| Min | 0.000 |
| Q1 | 1.000 |
| Q3 | 4.000 |
| Max | 5.000 |

### visit_label
Human-readable visit label (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 9 |
| Mode count | 2400 |
| Mode percent | 22.4% |
| Mode level | baseline |

| Level | Count | Percent |
| --- | ---: | ---: |
| baseline | 2400 | 22.4% |
| 12_month | 1983 | 18.5% |
| 24_month | 1814 | 16.9% |
| 36_month | 1650 | 15.4% |
| 48_month | 1504 | 14.0% |
| 60_month | 1378 | 12.8% |
| 12 month | 1 | 0.0% |
| 12_Month | 1 | 0.0% |
| 12month | 1 | 0.0% |

### months_since_baseline
Approximate months since baseline (`integer`, units: `months`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 26.331 |
| SD | 22.588 |
| Median | 24.000 |
| IQR | 36.000 |
| Min | -12.000 |
| Q1 | 10.000 |
| Q3 | 46.000 |
| Max | 999.000 |

### age_at_visit_years
Age at visit (`continuous`, units: `years`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 72.272 |
| SD | 8.472 |
| Median | 72.100 |
| IQR | 12.900 |
| Min | 51.000 |
| Q1 | 66.000 |
| Q3 | 78.900 |
| Max | 94.100 |

### site_code
Recruiting clinic site (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 6 |
| Mode count | 3108 |
| Mode percent | 29.0% |
| Mode level | Birmingham |

| Level | Count | Percent |
| --- | ---: | ---: |
| Bristol | 2475 | 23.1% |
| Birmingham | 3108 | 29.0% |
| Leeds | 2572 | 24.0% |
| Manchester | 2575 | 24.0% |
| Bristl | 1 | 0.0% |
| bristol | 1 | 0.0% |

### imd_quintile
Index of Multiple Deprivation quintile carried forward (`ordered integer`, units: `quintile`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 2.983 |
| SD | 1.404 |
| Median | 3.000 |
| IQR | 2.000 |
| Min | 1.000 |
| Q1 | 2.000 |
| Q3 | 4.000 |
| Max | 5.000 |

### smoking_status
Baseline smoking category carried forward (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 6 |
| Mode count | 5796 |
| Mode percent | 54.0% |
| Mode level | Never |

| Level | Count | Percent |
| --- | ---: | ---: |
| Never | 5796 | 54.0% |
| Former | 3507 | 32.7% |
| Current | 1426 | 13.3% |
| former | 1 | 0.0% |
| Former  | 1 | 0.0% |
| Formr | 1 | 0.0% |

### lifestyle_program_enrolled
Programme enrolment carried forward (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 8525 |
| Mode percent | 79.4% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 8525 | 79.4% |
| Yes | 2207 | 20.6% |

### multimorbidity_count
Baseline multimorbidity count carried forward (`count`, units: `conditions`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 1.668 |
| SD | 1.321 |
| Median | 1.000 |
| IQR | 1.000 |
| Min | 0.000 |
| Q1 | 1.000 |
| Q3 | 2.000 |
| Max | 9.000 |

### frailty_category
Baseline frailty category carried forward (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 4 |
| Mode count | 5729 |
| Mode percent | 53.4% |
| Mode level | Mild frailty |

| Level | Count | Percent |
| --- | ---: | ---: |
| Fit | 1510 | 14.1% |
| Mild frailty | 5729 | 53.4% |
| Moderate frailty | 3028 | 28.2% |
| Severe frailty | 465 | 4.3% |

### mortality_risk_5y_pct
Baseline predicted five-year mortality risk carried forward (`continuous`, units: `percent`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 7.090 |
| SD | 9.112 |
| Median | 3.800 |
| IQR | 6.500 |
| Min | 0.400 |
| Q1 | 1.900 |
| Q3 | 8.400 |
| Max | 60.000 |

### weekly_exercise_min
Exercise reported at visit (`continuous`, units: `minutes/week`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 106.861 |
| SD | 70.733 |
| Median | 102.000 |
| IQR | 101.000 |
| Min | 0.000 |
| Q1 | 52.000 |
| Q3 | 153.000 |
| Max | 398.000 |

### weight_kg
Body weight at visit (`continuous`, units: `kg`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 80.267 |
| SD | 15.057 |
| Median | 79.500 |
| IQR | 20.425 |
| Min | 43.000 |
| Q1 | 69.675 |
| Q3 | 90.100 |
| Max | 134.500 |

### bmi_kg_m2
BMI at visit (`continuous`, units: `kg/m^2`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 28.128 |
| SD | 4.093 |
| Median | 28.100 |
| IQR | 5.700 |
| Min | 16.800 |
| Q1 | 25.300 |
| Q3 | 31.000 |
| Max | 42.700 |

### systolic_bp_mmHg
Systolic blood pressure at visit (`continuous`, units: `mmHg`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 139.382 |
| SD | 14.303 |
| Median | 140.000 |
| IQR | 19.000 |
| Min | 85.000 |
| Q1 | 130.000 |
| Q3 | 149.000 |
| Max | 189.000 |

### diastolic_bp_mmHg
Diastolic blood pressure at visit (`continuous`, units: `mmHg`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 80.675 |
| SD | 9.541 |
| Median | 81.000 |
| IQR | 13.000 |
| Min | 50.000 |
| Q1 | 74.000 |
| Q3 | 87.000 |
| Max | 118.000 |

### resting_heart_rate_bpm
Resting heart rate at visit (`continuous`, units: `beats/min`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 70.963 |
| SD | 7.286 |
| Median | 71.000 |
| IQR | 10.000 |
| Min | 45.000 |
| Q1 | 66.000 |
| Q3 | 76.000 |
| Max | 100.000 |

### fasting_glucose_mmol_L
Fasting glucose at visit (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 5.388 |
| SD | 0.764 |
| Median | 5.330 |
| IQR | 1.030 |
| Min | 3.500 |
| Q1 | 4.850 |
| Q3 | 5.880 |
| Max | 8.230 |

### hba1c_mmol_mol
HbA1c at visit (`continuous`, units: `mmol/mol`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10456 |
| Missing n | 276 |
| Missing % | 2.6% |
| Mean | 36.676 |
| SD | 7.230 |
| Median | 35.500 |
| IQR | 9.400 |
| Min | 22.000 |
| Q1 | 31.500 |
| Q3 | 40.900 |
| Max | 63.900 |

### total_cholesterol_mmol_L
Total cholesterol at visit (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 5.043 |
| SD | 0.673 |
| Median | 5.050 |
| IQR | 0.910 |
| Min | 2.700 |
| Q1 | 4.590 |
| Q3 | 5.500 |
| Max | 7.600 |

### hdl_cholesterol_mmol_L
HDL cholesterol at visit (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 1.321 |
| SD | 0.212 |
| Median | 1.320 |
| IQR | 0.280 |
| Min | 0.600 |
| Q1 | 1.180 |
| Q3 | 1.460 |
| Max | 2.090 |

### triglycerides_mmol_L
Triglycerides at visit (`continuous`, units: `mmol/L`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10488 |
| Missing n | 244 |
| Missing % | 2.3% |
| Mean | 1.623 |
| SD | 0.673 |
| Median | 1.500 |
| IQR | 0.830 |
| Min | 0.400 |
| Q1 | 1.140 |
| Q3 | 1.970 |
| Max | 5.500 |

### crp_mg_L
C-reactive protein at visit (`continuous`, units: `mg/L`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10357 |
| Missing n | 375 |
| Missing % | 3.5% |
| Mean | 2.337 |
| SD | 1.618 |
| Median | 1.910 |
| IQR | 1.630 |
| Min | 0.140 |
| Q1 | 1.280 |
| Q3 | 2.910 |
| Max | 20.000 |

### medication_adherence_pct
Medication adherence for treated participants (`continuous`, units: `percent`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 5077 |
| Missing n | 5655 |
| Missing % | 52.7% |
| Mean | 82.478 |
| SD | 11.117 |
| Median | 83.000 |
| IQR | 16.000 |
| Min | -5.000 |
| Q1 | 75.000 |
| Q3 | 91.000 |
| Max | 150.000 |

### self_rated_health
Self-rated health at visit (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 5 |
| Mode count | 3300 |
| Mode percent | 30.7% |
| Mode level | Fair |

| Level | Count | Percent |
| --- | ---: | ---: |
| Very bad | 1534 | 14.3% |
| Bad | 2691 | 25.1% |
| Fair | 3300 | 30.7% |
| Good | 2269 | 21.1% |
| Very good | 938 | 8.7% |

### living_status_at_visit
Living status at each observed visit (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 10732 |
| Non-missing n | 10732 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 1 |
| Mode count | 10732 |
| Mode percent | 100.0% |
| Mode level | Alive |

| Level | Count | Percent |
| --- | ---: | ---: |
| Alive | 10732 | 100.0% |


## Mortality And Comorbidity Variable Summaries
### participant_id
Unique participant identifier (`identifier`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Unique values | 2400 |
| Duplicate values | 0 |

### age_years
Age at recruitment copied from baseline (`continuous`, units: `years`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 70.641 |
| SD | 8.446 |
| Median | 71.000 |
| IQR | 13.000 |
| Min | 51.000 |
| Q1 | 64.000 |
| Q3 | 77.000 |
| Max | 89.000 |

### sex_at_birth
Recorded sex at birth copied from baseline (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1203 |
| Mode percent | 50.1% |
| Mode level | Male |

| Level | Count | Percent |
| --- | ---: | ---: |
| Female | 1197 | 49.9% |
| Male | 1203 | 50.1% |

### imd_quintile
Index of Multiple Deprivation quintile copied from baseline (`ordered integer`, units: `quintile`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 3.024 |
| SD | 1.409 |
| Median | 3.000 |
| IQR | 2.000 |
| Min | 1.000 |
| Q1 | 2.000 |
| Q3 | 4.000 |
| Max | 5.000 |

### multimorbidity_count
Count of selected long-term conditions (`count`, units: `conditions`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 1.780 |
| SD | 1.371 |
| Median | 2.000 |
| IQR | 2.000 |
| Min | 0.000 |
| Q1 | 1.000 |
| Q3 | 3.000 |
| Max | 9.000 |

### frailty_index
Simplified frailty index (`continuous`, units: `index`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 0.215 |
| SD | 0.084 |
| Median | 0.210 |
| IQR | 0.116 |
| Min | 0.020 |
| Q1 | 0.155 |
| Q3 | 0.271 |
| Max | 0.512 |

### frailty_category
Frailty category (`ordered categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 6 |
| Mode count | 1226 |
| Mode percent | 51.1% |
| Mode level | Mild frailty |

| Level | Count | Percent |
| --- | ---: | ---: |
| Fit | 308 | 12.8% |
| Mild frailty | 1226 | 51.1% |
| Moderate frailty | 735 | 30.6% |
| Severe frailty | 129 | 5.4% |
| mild frailty | 1 | 0.0% |
| Mild frailty  | 1 | 0.0% |

### chronic_kidney_disease
Simulated chronic kidney disease status (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1781 |
| Mode percent | 74.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1781 | 74.2% |
| Yes | 619 | 25.8% |

### atrial_fibrillation
Simulated atrial fibrillation history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2058 |
| Mode percent | 85.8% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2058 | 85.8% |
| Yes | 342 | 14.2% |

### previous_mi
Previous myocardial infarction history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2075 |
| Mode percent | 86.5% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2075 | 86.5% |
| Yes | 325 | 13.5% |

### previous_stroke_tia
Previous stroke or TIA history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2159 |
| Mode percent | 90.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2159 | 90.0% |
| Yes | 241 | 10.0% |

### copd
Simulated COPD status (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2212 |
| Mode percent | 92.2% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2212 | 92.2% |
| Yes | 188 | 7.8% |

### cancer_history
Previous cancer diagnosis history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2100 |
| Mode percent | 87.5% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2100 | 87.5% |
| Yes | 300 | 12.5% |

### dementia_cognitive_impairment
Dementia or cognitive impairment history (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2183 |
| Mode percent | 91.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2183 | 91.0% |
| Yes | 217 | 9.0% |

### polypharmacy_5plus
Taking five or more regular medicines (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 1714 |
| Mode percent | 71.4% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 1714 | 71.4% |
| Yes | 686 | 28.6% |

### care_home_resident
Simulated care-home residence (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2232 |
| Mode percent | 93.0% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2232 | 93.0% |
| Yes | 168 | 7.0% |

### mortality_risk_5y_pct
Predicted five-year mortality risk (`continuous`, units: `percent`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Mean | 7.908 |
| SD | 10.063 |
| Median | 4.200 |
| IQR | 7.025 |
| Min | 0.400 |
| Q1 | 2.100 |
| Q3 | 9.125 |
| Max | 60.000 |

### died_during_followup
Died during five-year follow-up (`binary categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 2 |
| Mode count | 2199 |
| Mode percent | 91.6% |
| Mode level | No |

| Level | Count | Percent |
| --- | ---: | ---: |
| No | 2199 | 91.6% |
| Yes | 201 | 8.4% |

### death_month
Month of death after baseline (`continuous`, units: `months`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 201 |
| Missing n | 2199 |
| Missing % | 91.6% |
| Mean | 32.657 |
| SD | 14.770 |
| Median | 34.000 |
| IQR | 24.000 |
| Min | 2.000 |
| Q1 | 21.000 |
| Q3 | 45.000 |
| Max | 59.000 |

### death_calendar_year
Approximate calendar year of death (`integer`, units: `year`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 201 |
| Missing n | 2199 |
| Missing % | 91.6% |
| Mean | 2027.104 |
| SD | 1.416 |
| Median | 2027.000 |
| IQR | 2.000 |
| Min | 2024.000 |
| Q1 | 2026.000 |
| Q3 | 2028.000 |
| Max | 2030.000 |

### age_at_death
Age at death (`continuous`, units: `years`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 201 |
| Missing n | 2199 |
| Missing % | 91.6% |
| Mean | 80.721 |
| SD | 6.913 |
| Median | 81.800 |
| IQR | 10.000 |
| Min | 62.000 |
| Q1 | 75.900 |
| Q3 | 85.900 |
| Max | 92.500 |

### primary_cause_of_death
Broad simulated primary cause of death (`categorical`)

| Statistic | Value |
| --- | --- |
| Rows | 2400 |
| Non-missing n | 2400 |
| Missing n | 0 |
| Missing % | 0.0% |
| Levels observed | 8 |
| Mode count | 2199 |
| Mode percent | 91.6% |
| Mode level | Not applicable |

| Level | Count | Percent |
| --- | ---: | ---: |
| Not applicable | 2199 | 91.6% |
| Cancer | 35 | 1.5% |
| Dementia and neurodegenerative disease | 42 | 1.8% |
| Ischaemic heart disease | 31 | 1.3% |
| Respiratory disease | 26 | 1.1% |
| Stroke | 30 | 1.2% |
| Other | 34 | 1.4% |
| Ischaemic heart diesease | 3 | 0.1% |

