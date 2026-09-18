# Mortality And Comorbidity Model Notes

This linked table is simulated from the baseline clinical, lifestyle, deprivation, frailty, and comorbidity variables.
It is intended for teaching risk prediction, confounding, time-to-event thinking, attrition, and the difference between observed outcomes and modelled risk.

## Generated File
- `bioinformatics_msc_stats_mortality_comorbidity.csv`: one row per participant, linked by `participant_id`.

## Model Inputs
- Age, sex, IMD quintile, smoking, diabetes, measured hypertension, chronic kidney disease, previous myocardial infarction, previous stroke or TIA, atrial fibrillation, COPD, cancer history, dementia or cognitive impairment, frailty, care-home residence, and CRP all contribute to the simulated five-year mortality risk.
- Deaths are then sampled from the predicted five-year risk. Participants who die are censored from later visit rows.
- Broad cause of death is generated conditionally from the same risk profile, so cardiovascular, cancer, respiratory, dementia, stroke, and other causes are not randomly interchangeable.

## Overall Mortality And Comorbidity
- Mean predicted five-year mortality risk: 7.9%.
- Observed five-year deaths: 201 of 2400 (8.4%).
- Mean multimorbidity count: 1.78 conditions.
- Moderate or severe frailty: 36.0%.
- Care-home residence: 7.0%.

## Deaths By Simulated Primary Cause
- Dementia and neurodegenerative disease: 42
- Cancer: 35
- Other: 34
- Ischaemic heart disease: 31
- Stroke: 30
- Respiratory disease: 26
- Ischaemic heart diesease: 3

## Deaths By Frailty Category
- Fit: 3/308 deaths (1.0%)
- mild frailty: 0/1 deaths (0.0%)
- Mild frailty: 47/1226 deaths (3.8%)
- Mild frailty : 0/1 deaths (0.0%)
- Moderate frailty: 100/735 deaths (13.6%)
- Severe frailty: 51/129 deaths (39.5%)

## Teaching Caveats
- These are modelled outcomes, not real patient deaths.
- The aim is internal realism: older age, frailty, multimorbidity, CKD, COPD, dementia, prior cardiovascular disease, deprivation, and smoking increase risk in plausible directions.
- The mortality model is deliberately transparent enough for students to critique and refit; it should not be presented as a clinical risk calculator.
