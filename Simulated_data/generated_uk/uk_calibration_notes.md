# UK Calibration Notes

This note records the main epidemiological choices used to calibrate the simulated cohort.
The aim was not to recreate one named survey exactly, but to produce a plausible England-based teaching dataset with realistic prevalence levels and moderate, interpretable associations.
Calibration diagnostics are calculated before the reproducible teaching mess is added; the distributed raw CSVs therefore require cleaning before their estimates are compared with this note.

## Population frame
- The age band has been extended to 50 to 90 years to support teaching on multimorbidity, frailty, mortality, death-censored visits, and longer follow-up.
- The cohort is community-based rather than a strict NHS Health Check eligibility sample, so diagnosed hypertension, type 2 diabetes, chronic kidney disease, frailty, and previous cardiovascular disease are retained for teaching.
- Several prevalences are therefore expected to be higher than all-age England figures because the simulated cohort is older and more cardiometabolic than the general adult population.

## How the main variables were tuned
- Smoking was kept close to modern England levels at 14.0%, with a deprivation gradient rather than random allocation.
- Inactivity was kept close to national levels at 22.9%, and linked to higher resting heart rate and slightly worse weight trajectories.
- Obesity was tuned to 33.8% and linked to fasting glucose, prediabetes, type 2 diabetes, blood pressure, and central adiposity.
- Measured hypertension was tuned to 58.4% and diagnosed hypertension to 33.8%, with age and adiposity contributing more than smoking alone.
- Prediabetes was tuned to 30.6% and type 2 diabetes to 8.2%, with higher risks in more deprived groups, those with obesity, and those with family history.
- Raised total cholesterol was tuned to 57.7% and paired with total:HDL ratio so lipid summaries can be used in regression and CVD-risk style teaching.
- Longstanding condition prevalence was tuned to 66.3% and linked to self-rated health, multimorbidity, frailty, hospital admission, and mortality.
- Five-year mortality was tuned to 8.4% with risk increasing by age, male sex, smoking, CKD, COPD, dementia, previous cardiovascular disease, care-home residence, multimorbidity, and frailty.

## Association map used when iterating the simulation
- Older age increases systolic blood pressure and hypertension risk. Final age vs systolic blood pressure correlation: 0.290.
- Higher BMI increases fasting glucose and glycaemic risk. Final BMI vs fasting glucose correlation: 0.374.
- Obesity raises prediabetes risk but not so strongly that the data feel engineered. Final obesity vs prediabetes odds ratio: 2.011.
- More weekly exercise is associated with lower resting heart rate. Final exercise vs resting heart rate correlation: -0.195.
- HDL is inversely related to triglycerides as expected in routine lipid data. Final HDL vs triglycerides correlation: -0.338.
- Current smoking is associated with higher CRP and only a modest increase in diagnosed hypertension. Final smoking vs hypertension odds ratio: 1.260; smoker vs never-smoker median CRP ratio: 1.262.
- Deprivation raises diabetes risk without making IMD dominate the whole dataset. Final type 2 diabetes prevalence difference between IMD quintile 5 and 1: 0.097.
- Ethnicity is linked to glycaemic risk in a broad UK-consistent direction. Final prediabetes prevalence ratio for Asian or Black participants vs White, Mixed, or Other participants: 1.263.
- Blood group was deliberately kept close to null for glycaemic outcomes. Final blood group vs prediabetes p-value: 0.456.
- Mortality risk increases with age and multimorbidity. Final age vs predicted five-year mortality risk correlation: 0.667; multimorbidity vs predicted mortality risk correlation: 0.705.

## Main sources used for calibration
- NHS Health Check age band and programme context: <https://www.nhs.uk/conditions/nhs-health-check/nhs-health-check/>
- Health Survey for England 2024 overview: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024>
- Health Survey for England 2024 adults' health-related behaviours: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-health-related-behaviours>
- Health Survey for England 2024 adults' health: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-health>
- Health Survey for England 2024 adults' overweight and obesity: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-overweight-and-obesity>
- Health Survey for England 2022 adults' health-related behaviours for the smoking-by-deprivation pattern: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2022-part-1/adults-health-related-behaviours>
- Quality and Outcomes Framework 2024-25 for GP-recorded hypertension and obesity prevalence: <https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2024-25>
- Diabetes profile statistical commentary, March 2025, for England type 2 diabetes prevalence: <https://www.gov.uk/government/statistics/diabetes-profile-update-march-2025/diabetes-profile-statistical-commentary-march-2025>
- NHS England release on non-diabetic hyperglycaemia: <https://www.england.nhs.uk/2024/06/nhs-identifies-over-half-a-million-more-people-at-risk-of-type-2-diabetes-in-a-year/>
- NHS Blood and Transplant donor blood group frequencies: <https://www.blood.co.uk/why-give-blood/blood-types/>
- Exercise and resting heart rate meta-analysis (Reimers et al., 2018): <https://pubmed.ncbi.nlm.nih.gov/30513777/>
- Obesity and prediabetes meta-analysis (Amani-Beni et al., 2026): <https://pubmed.ncbi.nlm.nih.gov/41492061/>
- Family history and type 2 diabetes risk in EPIC-InterAct: <https://pubmed.ncbi.nlm.nih.gov/23052052/>
- Waist-to-height ratio and cardiometabolic risk meta-analysis: <https://pubmed.ncbi.nlm.nih.gov/24179379/>
- UK evidence on ethnic differences in type 2 diabetes diagnosis profiles: <https://pubmed.ncbi.nlm.nih.gov/31923438/>
- QRISK3 risk calculator fields, including total cholesterol:HDL ratio: <https://www.qrisk.org/index.php>
- Office for National Statistics life tables and mortality publications for age-patterned mortality: <https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/lifeexpectancies>
- NHS England frailty and older people resources: <https://www.england.nhs.uk/ourwork/clinical-policy/older-people/frailty/>

## Teaching caveat
- This is teaching data, not a synthetic copy of a protected NHS dataset. The goal is plausible structure, not exact prevalence reproduction for any single survey year or local authority.
