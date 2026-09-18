options(stringsAsFactors = FALSE)

clamp <- function(x, lower, upper) {
  pmin(pmax(x, lower), upper)
}

safe_cor <- function(x, y) {
  stats::cor(x, y, use = "complete.obs")
}

odds_ratio_2x2 <- function(exposure, outcome) {
  tab <- table(exposure, outcome)
  if (!all(dim(tab) == c(2, 2))) {
    return(NA_real_)
  }
  ((tab[2, 2] + 0.5) * (tab[1, 1] + 0.5)) / ((tab[2, 1] + 0.5) * (tab[1, 2] + 0.5))
}

penalty_from_range <- function(value, lower, upper) {
  if (is.na(value)) {
    return(5)
  }
  if (value < lower) {
    return(lower - value)
  }
  if (value > upper) {
    return(value - upper)
  }
  0
}

assign_ordered_levels <- function(score, labels, breaks) {
  cut(
    score,
    breaks = breaks,
    labels = labels,
    include.lowest = TRUE,
    ordered_result = TRUE
  )
}

sample_multinomial_levels <- function(prob_matrix, levels) {
  u <- runif(nrow(prob_matrix))
  cumulative <- t(apply(prob_matrix, 1, cumsum))
  indices <- apply(cumulative, 1, function(row) which(u[1] <= row)[1])
  levels[indices]
}

apply_baseline_missingness <- function(baseline) {
  n <- nrow(baseline)
  smoker <- baseline$smoking_status == "Current"
  younger <- baseline$age_years < 60
  older <- baseline$age_years > 78
  more_deprived <- baseline$imd_quintile >= 4
  manchester <- baseline$site_code == "Manchester"

  lab_missing_prob <- clamp(
    stats::plogis(-3.85 + 0.26 * smoker + 0.16 * older + 0.18 * more_deprived + 0.12 * manchester),
    0.02,
    0.08
  )

  questionnaire_missing_prob <- clamp(
    stats::plogis(-4.25 + 0.18 * smoker + 0.12 * older + 0.18 * more_deprived + 0.10 * younger),
    0.01,
    0.05
  )

  baseline$hba1c_mmol_mol[runif(n) < (lab_missing_prob + 0.01)] <- NA
  baseline$triglycerides_mmol_L[runif(n) < lab_missing_prob] <- NA
  baseline$crp_mg_L[runif(n) < (lab_missing_prob + 0.015)] <- NA
  baseline$egfr_ml_min_1_73m2[runif(n) < (lab_missing_prob - 0.005)] <- NA
  baseline$fruit_veg_portions_per_day[runif(n) < questionnaire_missing_prob] <- NA
  baseline$sleep_hours_per_night[runif(n) < questionnaire_missing_prob] <- NA
  baseline$self_rated_health[runif(n) < (questionnaire_missing_prob - 0.003)] <- NA

  baseline
}

apply_visit_missingness <- function(visits) {
  n <- nrow(visits)
  follow_up <- visits$visit_number > 0
  smoker <- visits$smoking_status == "Current"
  later_visit <- visits$visit_number >= 3
  more_deprived <- visits$imd_quintile >= 4

  lab_missing_prob <- clamp(
    stats::plogis(-3.95 + 0.22 * follow_up + 0.16 * smoker + 0.12 * later_visit + 0.14 * more_deprived),
    0.02,
    0.09
  )

  visits$hba1c_mmol_mol[runif(n) < lab_missing_prob] <- NA
  visits$crp_mg_L[runif(n) < (lab_missing_prob + 0.01)] <- NA
  visits$triglycerides_mmol_L[runif(n) < (lab_missing_prob - 0.003)] <- NA
  visits$medication_adherence_pct[runif(n) < 0.04] <- NA

  visits
}

visible_value <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "<NA>"
  x <- gsub("\\t", "<TAB>", x, fixed = TRUE)
  x <- gsub(" ", "·", x, fixed = TRUE)
  ifelse(nchar(x) == 0, "<EMPTY>", x)
}

apply_teaching_mess <- function(baseline, visits, mortality) {
  tables <- list(
    baseline = baseline,
    visits = visits,
    mortality_comorbidity = mortality
  )
  issues <- data.frame(
    issue_id = character(0),
    table_name = character(0),
    csv_row = integer(0),
    participant_id = character(0),
    visit_number = integer(0),
    variable_name = character(0),
    issue_type = character(0),
    original_value = character(0),
    messy_value = character(0),
    messy_value_visible = character(0),
    intended_value = character(0),
    detection_hint = character(0),
    suggested_fix = character(0),
    stringsAsFactors = FALSE
  )

  change_cells <- function(table_name, row_indices, variable_name, messy_values,
                           issue_type, detection_hint, suggested_fix) {
    data <- tables[[table_name]]
    if (length(row_indices) != length(messy_values)) {
      stop("Each planted cell issue must have exactly one replacement value.")
    }
    if (length(row_indices) == 0) {
      return(invisible(NULL))
    }
    if (!variable_name %in% names(data)) {
      stop(paste("Unknown variable for teaching mess:", variable_name))
    }
    if (any(row_indices < 1 | row_indices > nrow(data))) {
      stop(paste("Invalid row index while planting teaching mess in", table_name))
    }

    original_values <- as.character(data[[variable_name]][row_indices])
    if (is.factor(data[[variable_name]])) {
      data[[variable_name]] <- as.character(data[[variable_name]])
    }
    if (is.numeric(data[[variable_name]])) {
      messy_values <- as.numeric(messy_values)
    }
    data[[variable_name]][row_indices] <- messy_values
    tables[[table_name]] <<- data

    visit_numbers <- if ("visit_number" %in% names(data)) {
      as.integer(data$visit_number[row_indices])
    } else {
      rep(NA_integer_, length(row_indices))
    }
    new_issue_numbers <- nrow(issues) + seq_along(row_indices)
    issues <<- rbind(
      issues,
      data.frame(
        issue_id = sprintf("MESS%03d", new_issue_numbers),
        table_name = table_name,
        csv_row = row_indices + 1L,
        participant_id = as.character(data$participant_id[row_indices]),
        visit_number = visit_numbers,
        variable_name = variable_name,
        issue_type = issue_type,
        original_value = original_values,
        messy_value = as.character(messy_values),
        messy_value_visible = visible_value(messy_values),
        intended_value = original_values,
        detection_hint = detection_hint,
        suggested_fix = suggested_fix,
        stringsAsFactors = FALSE
      )
    )
  }

  baseline_rows <- function(condition, n) head(which(condition), n)

  rows <- baseline_rows(tables$baseline$site_code == "Manchester", 4)
  change_cells("baseline", rows, "site_code", rep("Manchster", length(rows)),
               "categorical misspelling", "Compare distinct site levels with the codebook.",
               "Recode `Manchster` to `Manchester`.")

  rows <- baseline_rows(tables$baseline$smoking_status == "Current", 4)
  change_cells("baseline", rows, "smoking_status", rep("Currnt", length(rows)),
               "categorical misspelling", "Count and inspect all smoking-status levels.",
               "Recode `Currnt` to `Current`.")

  rows <- baseline_rows(tables$baseline$sex_at_birth == "Female", 3)
  change_cells("baseline", rows, "sex_at_birth", rep("female", length(rows)),
               "inconsistent case", "Compare case-insensitive and case-sensitive level counts.",
               "Standardise `female` to `Female`.")

  rows <- baseline_rows(tables$baseline$ethnicity_group == "Asian", 3)
  change_cells("baseline", rows, "ethnicity_group", rep("Asain", length(rows)),
               "categorical misspelling", "Compare the observed levels with the codebook.",
               "Recode `Asain` to `Asian`.")

  rows <- baseline_rows(as.character(tables$baseline$self_rated_health) == "Very good", 3)
  change_cells("baseline", rows, "self_rated_health", c("Very Good", "Very good ", "very good")[seq_along(rows)],
               "case and whitespace inconsistency", "Inspect levels after trimming whitespace and changing case.",
               "Trim whitespace and standardise all three values to `Very good`.")

  rows <- baseline_rows(tables$baseline$obesity == "Yes", 2)
  change_cells("baseline", rows, "obesity", c("YES", "Y")[seq_along(rows)],
               "inconsistent binary coding", "Compare binary levels with the codebook and BMI-derived definition.",
               "Map `YES` and `Y` to `Yes`.")

  rows <- baseline_rows(tables$baseline$systolic_bp_mmHg < 190, 2)
  change_cells("baseline", rows, "systolic_bp_mmHg", tables$baseline$systolic_bp_mmHg[rows] * 10,
               "decimal-place numeric error", "Check the documented range and plot the distribution.",
               "Divide these values by 10 to restore the recorded measurements.")

  rows <- baseline_rows(tables$baseline$imd_quintile == 5, 1)
  change_cells("baseline", rows, "imd_quintile", 9,
               "out-of-range code", "Validate the variable against its allowed range of 1 to 5.",
               "Restore the value to 5.")

  rows <- baseline_rows(tables$visits$visit_label == "12_month", 3)
  change_cells("visits", rows, "visit_label", c("12 month", "12month", "12_Month")[seq_along(rows)],
               "inconsistent categorical formatting", "Inspect visit-label levels and compare them with visit_number.",
               "Map all three values to `12_month`.")

  rows <- baseline_rows(tables$visits$smoking_status == "Former", 3)
  change_cells("visits", rows, "smoking_status", c("Former ", "former", "Formr")[seq_along(rows)],
               "case, whitespace, and spelling inconsistency", "Inspect levels before and after trimming whitespace and changing case.",
               "Standardise all three values to `Former`.")

  rows <- baseline_rows(tables$visits$site_code == "Bristol", 2)
  change_cells("visits", rows, "site_code", c("bristol", "Bristl")[seq_along(rows)],
               "case and spelling inconsistency", "Compare visit-site levels with baseline and the codebook.",
               "Standardise both values to `Bristol`.")

  rows <- baseline_rows(!is.na(tables$visits$medication_adherence_pct), 2)
  change_cells("visits", rows, "medication_adherence_pct", c(150, -5)[seq_along(rows)],
               "out-of-range numeric value", "Check that percentages fall between 0 and 100.",
               "Treat as entry errors and restore the original values from the instructor key.")

  rows <- baseline_rows(tables$visits$visit_number > 0, 2)
  change_cells("visits", rows, "months_since_baseline", c(-12, 999)[seq_along(rows)],
               "impossible time value", "Cross-check months_since_baseline against visit_number and visit_label.",
               "Restore the expected follow-up months from the instructor key.")

  rows <- baseline_rows(tables$mortality_comorbidity$primary_cause_of_death == "Ischaemic heart disease", 3)
  change_cells("mortality_comorbidity", rows, "primary_cause_of_death",
               rep("Ischaemic heart diesease", length(rows)),
               "categorical misspelling", "Inspect cause-of-death levels and rare categories.",
               "Recode `Ischaemic heart diesease` to `Ischaemic heart disease`.")

  rows <- baseline_rows(as.character(tables$mortality_comorbidity$frailty_category) == "Mild frailty", 2)
  change_cells("mortality_comorbidity", rows, "frailty_category", c("Mild frailty ", "mild frailty")[seq_along(rows)],
               "case and whitespace inconsistency", "Inspect levels after trimming whitespace and changing case.",
               "Standardise both values to `Mild frailty`.")

  affected_participants <- unique(issues$participant_id)
  duplicate_source_rows <- head(which(
    tables$visits$visit_number == 2 &
      !tables$visits$participant_id %in% affected_participants
  ), 2)
  if (length(duplicate_source_rows) > 0) {
    duplicate_rows <- tables$visits[duplicate_source_rows, , drop = FALSE]
    first_new_row <- nrow(tables$visits) + 2L
    tables$visits <- rbind(tables$visits, duplicate_rows)
    duplicate_issue_numbers <- nrow(issues) + seq_len(nrow(duplicate_rows))
    issues <- rbind(
      issues,
      data.frame(
        issue_id = sprintf("MESS%03d", duplicate_issue_numbers),
        table_name = "visits",
        csv_row = first_new_row + seq_len(nrow(duplicate_rows)) - 1L,
        participant_id = duplicate_rows$participant_id,
        visit_number = as.integer(duplicate_rows$visit_number),
        variable_name = "[entire row]",
        issue_type = "exact duplicate row",
        original_value = "one unique participant-visit row",
        messy_value = "a second identical row",
        messy_value_visible = "a·second·identical·row",
        intended_value = "keep one copy only",
        detection_hint = "Check duplicated rows and duplicated participant_id + visit_number keys.",
        suggested_fix = "Remove one copy of each exact duplicate row.",
        stringsAsFactors = FALSE
      )
    )
  }

  rownames(tables$visits) <- NULL
  list(
    baseline = tables$baseline,
    visits = tables$visits,
    mortality_comorbidity = tables$mortality_comorbidity,
    issues = issues
  )
}

simulate_baseline_complete <- function(n, seed) {
  set.seed(seed)

  participant_id <- sprintf("BIO%05d", seq_len(n))
  site_code <- sample(
    c("Bristol", "Birmingham", "Leeds", "Manchester"),
    size = n,
    replace = TRUE,
    prob = c(0.24, 0.28, 0.24, 0.24)
  )
  recruitment_year <- sample(
    c(2024L, 2025L, 2026L),
    size = n,
    replace = TRUE,
    prob = c(0.35, 0.40, 0.25)
  )
  sex_at_birth <- sample(
    c("Female", "Male"),
    size = n,
    replace = TRUE,
    prob = c(0.51, 0.49)
  )
  male <- as.integer(sex_at_birth == "Male")

  age_years <- round(50 + stats::rbeta(n, shape1 = 2.25, shape2 = 2.15) * 40)
  age_z <- as.numeric(scale(age_years))

  imd_quintile <- sample(
    1:5,
    size = n,
    replace = TRUE,
    prob = c(0.19, 0.20, 0.20, 0.21, 0.20)
  )
  imd_offset <- imd_quintile - 3

  ethnicity_group <- sample(
    c("White", "Asian", "Black", "Mixed", "Other"),
    size = n,
    replace = TRUE,
    prob = c(0.79, 0.10, 0.05, 0.03, 0.03)
  )
  asian_ethnicity <- as.integer(ethnicity_group == "Asian")
  black_ethnicity <- as.integer(ethnicity_group == "Black")
  higher_glycaemia_ethnicity <- as.integer(ethnicity_group %in% c("Asian", "Black"))

  blood_group <- sample(
    c("O", "A", "B", "AB"),
    size = n,
    replace = TRUE,
    prob = c(0.48, 0.38, 0.10, 0.04)
  )

  behaviour_latent <- rnorm(n)
  frailty_latent <- rnorm(n)
  glycaemic_latent <- rnorm(n)

  family_history_cvd <- ifelse(
    runif(n) < stats::plogis(-0.95 + 0.15 * male + 0.10 * age_z),
    "Yes",
    "No"
  )
  family_history_cvd_num <- as.integer(family_history_cvd == "Yes")

  family_history_diabetes <- ifelse(
    runif(n) < stats::plogis(-0.75 + 0.20 * higher_glycaemia_ethnicity + 0.08 * imd_offset + 0.08 * age_z),
    "Yes",
    "No"
  )
  family_history_diabetes_num <- as.integer(family_history_diabetes == "Yes")

  current_prob <- stats::plogis(-2.05 - 0.55 * behaviour_latent + 0.18 * male + 0.30 * (imd_offset / 2) - 0.04 * age_z)
  former_base <- stats::plogis(0.15 + 0.75 * age_z + 0.18 * male)
  former_prob <- (1 - current_prob) * former_base * 0.70
  never_prob <- pmax(0.08, 1 - current_prob - former_prob)
  smoking_matrix <- cbind(never_prob, former_prob, current_prob)
  smoking_matrix <- smoking_matrix / rowSums(smoking_matrix)
  smoking_status <- apply(smoking_matrix, 1, function(row) {
    sample(c("Never", "Former", "Current"), size = 1, prob = row)
  })
  current_smoker <- as.integer(smoking_status == "Current")
  former_smoker <- as.integer(smoking_status == "Former")

  weekly_exercise_min <- round(clamp(
    rnorm(
      n,
      mean = 90 + 26 * behaviour_latent - 16 * current_smoker - 9 * former_smoker -
        14 * imd_offset - 0.42 * (age_years - 68)^2 / 14,
      sd = 60
    ),
    0,
    420
  ))
  inactive_under_30min <- ifelse(weekly_exercise_min < 30, "Yes", "No")

  alcohol_units_per_week <- round(clamp(
    rgamma(n, shape = 2.3, scale = 3.2) + 2.5 * male + 1.8 * current_smoker - 1.5 * behaviour_latent + 0.5 * imd_offset,
    0,
    40
  ))

  sleep_hours_per_night <- round(clamp(
    rnorm(
      n,
      mean = 7.00 + 0.18 * behaviour_latent - 0.15 * current_smoker - 0.030 * alcohol_units_per_week - 0.10 * imd_offset,
      sd = 0.70
    ),
    4.5,
    9.5
  ), 1)

  fruit_veg_portions_per_day <- round(clamp(
    rnorm(
      n,
      mean = 4.1 + 0.35 * behaviour_latent + 0.0025 * (weekly_exercise_min - 120) - 0.25 * current_smoker - 0.15 * imd_offset,
      sd = 0.95
    ),
    0.5,
    8.0
  ), 1)

  ethnicity_height_offset <- c(White = 0.0, Asian = -1.8, Black = 1.0, Mixed = 0.2, Other = 0.0)
  height_cm <- round(clamp(
    rnorm(
      n,
      mean = ifelse(male == 1, 175.8, 162.1) + ethnicity_height_offset[ethnicity_group],
      sd = ifelse(male == 1, 6.8, 6.1)
    ),
    145,
    200
  ), 1)

  bmi_true <- clamp(
    rnorm(
      n,
        mean = 27.9 +
        0.08 * (age_years - 68) / 5 -
        0.004 * pmax(age_years - 78, 0)^2 +
        0.35 * male -
        0.55 * current_smoker -
        0.010 * (weekly_exercise_min - 90) -
        0.22 * (sleep_hours_per_night - 7) -
        0.16 * (fruit_veg_portions_per_day - 4) +
        0.45 * (imd_offset / 2) +
        0.25 * asian_ethnicity +
        0.15 * black_ethnicity +
        0.85 * frailty_latent,
      sd = 3.9
    ),
    20,
    46
  )

  weight_kg <- round(clamp(
    bmi_true * (height_cm / 100)^2 + rnorm(n, mean = 0, sd = 1.4),
    45,
    160
  ), 1)
  bmi_kg_m2 <- round(weight_kg / (height_cm / 100)^2, 1)
  obesity <- ifelse(bmi_kg_m2 >= 30, "Yes", "No")
  obesity_num <- as.integer(obesity == "Yes")

  waist_cm <- round(clamp(
    39 + 1.82 * bmi_kg_m2 + 0.16 * (age_years - 68) + 4.5 * male + 1.4 * (imd_offset / 2) + rnorm(n, 0, 5.6),
    60,
    145
  ), 1)
  waist_to_height_ratio <- round(waist_cm / height_cm, 2)
  high_central_adiposity <- ifelse(waist_to_height_ratio >= 0.6, "Yes", "No")

  systolic_bp_mmHg <- round(clamp(
    109 +
      0.40 * age_years +
      0.85 * (bmi_kg_m2 - 28) +
      2.2 * current_smoker +
      1.0 * former_smoker +
      0.7 * imd_offset +
      2.2 * family_history_cvd_num -
      0.010 * (weekly_exercise_min - 120) -
      0.6 * (sleep_hours_per_night - 7) +
      rnorm(n, 0, 11.4),
    88,
    195
  ))

  diastolic_bp_mmHg <- round(clamp(
    60 +
      0.28 * age_years +
      0.55 * (bmi_kg_m2 - 28) +
      1.5 * current_smoker +
      0.6 * imd_offset +
      0.9 * family_history_cvd_num -
      0.006 * (weekly_exercise_min - 120) +
      rnorm(n, 0, 7.5),
    52,
    120
  ))

  resting_heart_rate_bpm <- round(clamp(
    71 +
      0.12 * (bmi_kg_m2 - 28) -
      0.018 * (weekly_exercise_min - 90) +
      2.1 * current_smoker +
      0.03 * (age_years - 68) +
      0.4 * (imd_offset / 2) +
      rnorm(n, 0, 6.2),
    48,
    110
  ))

  diabetes_progression <- rbinom(
    n,
    size = 1,
    prob = stats::plogis(
      -2.35 +
        0.045 * (age_years - 65) +
        0.22 * (bmi_kg_m2 - 28) +
        0.55 * family_history_diabetes_num +
        0.70 * higher_glycaemia_ethnicity +
        0.16 * imd_offset +
        0.12 * current_smoker
    )
  )

  fasting_glucose_mmol_L <- round(clamp(
    4.95 +
      0.020 * (age_years - 68) +
      0.030 * (bmi_kg_m2 - 28) +
      0.18 * family_history_diabetes_num +
      0.08 * current_smoker -
      0.0010 * (weekly_exercise_min - 90) +
      0.12 * (imd_offset / 2) +
      0.20 * asian_ethnicity +
      0.15 * black_ethnicity +
      0.24 * glycaemic_latent +
      0.95 * diabetes_progression +
      rnorm(n, 0, 0.42),
    3.60,
    10.20
  ), 2)

  hba1c_mmol_mol <- round(clamp(
    32.7 +
      3.0 * (fasting_glucose_mmol_L - 5.1) +
      0.10 * (age_years - 68) +
      0.9 * family_history_diabetes_num +
      0.60 * imd_offset +
      1.8 * asian_ethnicity +
      1.6 * black_ethnicity +
      1.8 * glycaemic_latent +
      8.5 * diabetes_progression +
      rnorm(n, 0, 3.0),
    25,
    82
  ), 1)

  total_cholesterol_mmol_L <- round(clamp(
    5.02 +
      0.012 * (age_years - 68) -
      0.006 * pmax(age_years - 78, 0) +
      0.032 * (bmi_kg_m2 - 28) +
      0.08 * current_smoker +
      0.12 * (1 - male) -
      0.0008 * (weekly_exercise_min - 95) +
      rnorm(n, 0, 0.60),
    2.80,
    8.50
  ), 2)

  hdl_cholesterol_mmol_L <- round(clamp(
    1.28 -
      0.022 * (bmi_kg_m2 - 28) -
      0.12 * current_smoker +
      0.0008 * (weekly_exercise_min - 90) +
      0.08 * (1 - male) -
      0.025 * imd_offset +
      rnorm(n, 0, 0.15),
    0.70,
    2.50
  ), 2)

  log_triglycerides <- log(1.45) +
    0.030 * (bmi_kg_m2 - 28) +
    0.15 * current_smoker -
    0.0012 * (weekly_exercise_min - 120) -
    0.03 * (fruit_veg_portions_per_day - 4) +
    0.04 * imd_offset +
    0.10 * glycaemic_latent +
    rnorm(n, 0, 0.29)
  triglycerides_mmol_L <- round(clamp(exp(log_triglycerides), 0.45, 5.50), 2)

  ldl_cholesterol_mmol_L <- round(clamp(
    total_cholesterol_mmol_L - hdl_cholesterol_mmol_L - triglycerides_mmol_L / 2.2 + rnorm(n, 0, 0.12),
    1.20,
    6.30
  ), 2)
  total_hdl_ratio <- round(total_cholesterol_mmol_L / hdl_cholesterol_mmol_L, 2)
  high_total_hdl_ratio <- ifelse(total_hdl_ratio >= 6, "Yes", "No")
  raised_total_cholesterol <- ifelse(total_cholesterol_mmol_L >= 5, "Yes", "No")

  log_crp <- log(1.9) +
    0.045 * (bmi_kg_m2 - 28) +
    0.20 * current_smoker -
    0.035 * (fruit_veg_portions_per_day - 4) +
    0.020 * (120 - weekly_exercise_min) / 60 +
    0.06 * imd_offset +
    0.25 * frailty_latent +
    rnorm(n, 0, 0.48)
  crp_mg_L <- round(clamp(exp(log_crp), 0.10, 20.00), 2)

  creatinine_umol_L <- round(clamp(
    75 + 0.50 * (age_years - 68) + 10.5 * male + rnorm(n, 0, 10.5),
    45,
    150
  ), 1)

  egfr_ml_min_1_73m2 <- round(clamp(
    101 -
      0.95 * (age_years - 40) -
      0.30 * (creatinine_umol_L - 84) +
      3 * (1 - male) +
      rnorm(n, 0, 8.2),
    35,
    125
  ), 1)

  type2_diabetes <- ifelse(hba1c_mmol_mol >= 48 | fasting_glucose_mmol_L >= 7.0, "Yes", "No")
  type2_diabetes_num <- as.integer(type2_diabetes == "Yes")

  prediabetes <- ifelse(
    type2_diabetes == "No" & (hba1c_mmol_mol >= 42 | fasting_glucose_mmol_L >= 5.5),
    "Yes",
    "No"
  )
  prediabetes_num <- as.integer(prediabetes == "Yes")

  high_bp_now <- as.integer(systolic_bp_mmHg >= 140 | diastolic_bp_mmHg >= 90)
  diagnosed_hypertension <- ifelse(
    runif(n) < stats::plogis(
      -4.15 +
        3.00 * high_bp_now +
        0.018 * age_years +
        0.12 * imd_offset +
        0.20 * family_history_cvd_num
    ),
    "Yes",
    "No"
  )
  diagnosed_hypertension_num <- as.integer(diagnosed_hypertension == "Yes")

  on_antihypertensive <- ifelse(
    runif(n) < stats::plogis(
      -4.20 +
        3.30 * diagnosed_hypertension_num +
        0.018 * age_years +
        0.018 * (systolic_bp_mmHg - 130)
    ),
    "Yes",
    "No"
  )
  measured_hypertension <- ifelse(high_bp_now == 1 | on_antihypertensive == "Yes", "Yes", "No")
  measured_hypertension_num <- as.integer(measured_hypertension == "Yes")

  high_cardiovascular_risk <- ifelse(
    runif(n) < stats::plogis(
      -8.50 +
        0.070 * age_years +
        0.018 * systolic_bp_mmHg +
        0.60 * (total_hdl_ratio - 4.5) +
        0.55 * current_smoker +
        0.70 * type2_diabetes_num +
        0.30 * measured_hypertension_num
    ),
    "Yes",
    "No"
  )
  high_risk_num <- as.integer(high_cardiovascular_risk == "Yes")

  on_statin <- ifelse(
    runif(n) < stats::plogis(
      -4.45 +
        0.042 * age_years +
        0.85 * as.integer(raised_total_cholesterol == "Yes") +
        0.90 * high_risk_num +
        0.50 * type2_diabetes_num
    ),
    "Yes",
    "No"
  )

  longstanding_condition <- ifelse(
    runif(n) < stats::plogis(
      -2.00 +
        0.030 * age_years +
        0.45 * measured_hypertension_num +
        0.60 * type2_diabetes_num +
        0.25 * obesity_num +
        0.20 * current_smoker +
        0.18 * (1 - male) +
        0.12 * imd_offset
    ),
    "Yes",
    "No"
  )
  longstanding_condition_num <- as.integer(longstanding_condition == "Yes")

  gp_visits_last_12m <- pmin(
    rpois(
      n,
      lambda = exp(
        0.90 +
          0.014 * (age_years - 57) +
          0.22 * diagnosed_hypertension_num +
          0.28 * type2_diabetes_num +
          0.14 * longstanding_condition_num +
          0.06 * imd_offset +
          rnorm(n, 0, 0.28)
      )
    ),
    18
  )

  sick_days_last_12m <- pmin(
    rpois(
      n,
      lambda = exp(
        0.60 +
          0.20 * current_smoker +
          0.12 * type2_diabetes_num +
          0.10 * diagnosed_hypertension_num +
          0.18 * longstanding_condition_num +
          0.10 * as.integer(crp_mg_L > 3) +
          rnorm(n, 0, 0.45)
      )
    ),
    40
  )

  hospital_admission_24m <- ifelse(
    runif(n) < stats::plogis(
      -4.40 +
        0.028 * age_years +
        0.45 * high_risk_num +
        0.25 * type2_diabetes_num +
        0.20 * diagnosed_hypertension_num +
        0.20 * longstanding_condition_num +
        0.08 * gp_visits_last_12m
    ),
    "Yes",
    "No"
  )

  chronic_kidney_disease <- ifelse(
    egfr_ml_min_1_73m2 < 60 |
      runif(n) < stats::plogis(
        -5.10 +
          0.040 * age_years +
          0.55 * type2_diabetes_num +
          0.35 * measured_hypertension_num +
          0.20 * high_risk_num
      ),
    "Yes",
    "No"
  )
  chronic_kidney_disease_num <- as.integer(chronic_kidney_disease == "Yes")

  atrial_fibrillation <- ifelse(
    runif(n) < stats::plogis(
      -7.30 +
        0.070 * age_years +
        0.22 * male +
        0.35 * measured_hypertension_num +
        0.25 * type2_diabetes_num
    ),
    "Yes",
    "No"
  )
  atrial_fibrillation_num <- as.integer(atrial_fibrillation == "Yes")

  previous_mi <- ifelse(
    runif(n) < stats::plogis(
      -6.10 +
        0.050 * age_years +
        0.45 * male +
        0.55 * current_smoker +
        0.35 * type2_diabetes_num +
        0.40 * high_risk_num +
        0.20 * imd_offset
    ),
    "Yes",
    "No"
  )
  previous_mi_num <- as.integer(previous_mi == "Yes")

  previous_stroke_tia <- ifelse(
    runif(n) < stats::plogis(
      -6.40 +
        0.052 * age_years +
        0.35 * atrial_fibrillation_num +
        0.38 * diagnosed_hypertension_num +
        0.25 * type2_diabetes_num +
        0.20 * current_smoker
    ),
    "Yes",
    "No"
  )
  previous_stroke_tia_num <- as.integer(previous_stroke_tia == "Yes")

  copd <- ifelse(
    runif(n) < stats::plogis(
      -5.75 +
        0.040 * age_years +
        1.15 * current_smoker +
        0.52 * former_smoker +
        0.16 * imd_offset
    ),
    "Yes",
    "No"
  )
  copd_num <- as.integer(copd == "Yes")

  cancer_history <- ifelse(
    runif(n) < stats::plogis(
      -5.30 +
        0.046 * age_years +
        0.26 * current_smoker +
        0.12 * male
    ),
    "Yes",
    "No"
  )
  cancer_history_num <- as.integer(cancer_history == "Yes")

  osteoarthritis <- ifelse(
    runif(n) < stats::plogis(
      -4.50 +
        0.046 * age_years +
        0.34 * obesity_num +
        0.24 * (1 - male)
    ),
    "Yes",
    "No"
  )
  osteoarthritis_num <- as.integer(osteoarthritis == "Yes")

  depression_anxiety <- ifelse(
    runif(n) < stats::plogis(
      -2.25 +
        0.22 * current_smoker +
        0.22 * longstanding_condition_num +
        0.14 * imd_offset +
        0.20 * (1 - male) -
        0.006 * (age_years - 68)
    ),
    "Yes",
    "No"
  )
  depression_anxiety_num <- as.integer(depression_anxiety == "Yes")

  dementia_cognitive_impairment <- ifelse(
    runif(n) < stats::plogis(
      -9.30 +
        0.095 * age_years +
        0.30 * previous_stroke_tia_num +
        0.18 * imd_offset
    ),
    "Yes",
    "No"
  )
  dementia_cognitive_impairment_num <- as.integer(dementia_cognitive_impairment == "Yes")

  multimorbidity_count <- diagnosed_hypertension_num +
    type2_diabetes_num +
    chronic_kidney_disease_num +
    previous_mi_num +
    previous_stroke_tia_num +
    atrial_fibrillation_num +
    copd_num +
    cancer_history_num +
    osteoarthritis_num +
    depression_anxiety_num +
    dementia_cognitive_impairment_num

  falls_last_12m <- pmin(
    rpois(
      n,
      lambda = exp(
        -1.55 +
          0.035 * (age_years - 65) +
          0.18 * multimorbidity_count +
          0.28 * dementia_cognitive_impairment_num +
          0.15 * (1 - male)
      )
    ),
    6
  )

  polypharmacy_5plus <- ifelse(
    runif(n) < stats::plogis(
      -2.35 +
        0.52 * multimorbidity_count +
        0.55 * as.integer(on_antihypertensive == "Yes") +
        0.45 * as.integer(on_statin == "Yes") +
        0.18 * (age_years - 68) / 10
    ),
    "Yes",
    "No"
  )
  polypharmacy_5plus_num <- as.integer(polypharmacy_5plus == "Yes")

  frailty_index <- round(clamp(
    0.055 +
      0.0048 * (age_years - 50) +
      0.026 * multimorbidity_count +
      0.020 * falls_last_12m +
      0.020 * polypharmacy_5plus_num +
      0.018 * (imd_offset / 2) +
      rnorm(n, 0, 0.035),
    0.02,
    0.58
  ), 3)

  frailty_category <- assign_ordered_levels(
    frailty_index,
    labels = c("Fit", "Mild frailty", "Moderate frailty", "Severe frailty"),
    breaks = c(-Inf, 0.12, 0.24, 0.36, Inf)
  )
  moderate_or_severe_frailty <- as.integer(frailty_category %in% c("Moderate frailty", "Severe frailty"))
  severe_frailty_num <- as.integer(frailty_category == "Severe frailty")

  care_home_resident <- ifelse(
    runif(n) < stats::plogis(
      -7.80 +
        0.065 * age_years +
        0.95 * severe_frailty_num +
        0.80 * dementia_cognitive_impairment_num +
        0.35 * falls_last_12m
    ),
    "Yes",
    "No"
  )
  care_home_resident_num <- as.integer(care_home_resident == "Yes")

  hospital_admission_5y <- ifelse(
    runif(n) < stats::plogis(
      -3.35 +
        0.032 * age_years +
        0.38 * high_risk_num +
        0.28 * type2_diabetes_num +
        0.25 * diagnosed_hypertension_num +
        0.34 * chronic_kidney_disease_num +
        0.32 * copd_num +
        0.35 * moderate_or_severe_frailty +
        0.07 * gp_visits_last_12m
    ),
    "Yes",
    "No"
  )

  mortality_lp <- -4.50 +
    0.075 * (age_years - 65) +
    0.32 * male +
    0.28 * current_smoker +
    0.18 * former_smoker +
    0.25 * type2_diabetes_num +
    0.22 * measured_hypertension_num +
    0.38 * chronic_kidney_disease_num +
    0.45 * previous_mi_num +
    0.48 * previous_stroke_tia_num +
    0.32 * atrial_fibrillation_num +
    0.35 * copd_num +
    0.34 * cancer_history_num +
    0.72 * dementia_cognitive_impairment_num +
    0.95 * frailty_index +
    0.38 * severe_frailty_num +
    0.42 * care_home_resident_num +
    0.10 * imd_offset +
    0.025 * pmax(crp_mg_L - 2.5, 0)
  mortality_risk_5y <- clamp(stats::plogis(mortality_lp), 0.002, 0.60)
  mortality_risk_5y_pct <- round(100 * mortality_risk_5y, 1)
  died_during_followup <- ifelse(runif(n) < mortality_risk_5y, "Yes", "No")

  death_fraction <- rbeta(
    n,
    shape1 = clamp(1.65 - 0.85 * mortality_risk_5y, 0.75, 1.65),
    shape2 = 1.35
  )
  death_month <- ifelse(
    died_during_followup == "Yes",
    round(clamp(1 + 59 * death_fraction, 1, 60)),
    NA
  )
  age_at_death <- ifelse(
    died_during_followup == "Yes",
    round(age_years + death_month / 12, 1),
    NA
  )

  cause_weights <- cbind(
    `Ischaemic heart disease` = exp(0.70 * previous_mi_num + 0.45 * high_risk_num + 0.25 * male),
    Stroke = exp(0.75 * previous_stroke_tia_num + 0.40 * atrial_fibrillation_num + 0.25 * diagnosed_hypertension_num),
    Cancer = exp(0.80 * cancer_history_num + 0.28 * current_smoker),
    `Dementia and neurodegenerative disease` = exp(0.90 * dementia_cognitive_impairment_num + 0.030 * (age_years - 75) + 0.35 * severe_frailty_num),
    `Respiratory disease` = exp(0.85 * copd_num + 0.40 * current_smoker),
    Other = exp(0.25 * chronic_kidney_disease_num + 0.25 * severe_frailty_num)
  )
  cause_probs <- cause_weights / rowSums(cause_weights)
  cause_levels <- colnames(cause_probs)
  primary_cause_of_death <- rep("Not applicable", n)
  died_index <- which(died_during_followup == "Yes")
  if (length(died_index) > 0) {
    primary_cause_of_death[died_index] <- apply(
      cause_probs[died_index, , drop = FALSE],
      1,
      function(prob) sample(cause_levels, size = 1, prob = prob)
    )
  }

  metabolic_score <- 0.55 * (bmi_kg_m2 - 28) +
    0.10 * (systolic_bp_mmHg - 130) +
    0.85 * (fasting_glucose_mmol_L - 5.2) +
    0.55 * log(triglycerides_mmol_L) +
    0.25 * imd_offset +
    0.45 * current_smoker +
    rnorm(n, 0, 1.1)

  metabolic_risk_group <- assign_ordered_levels(
    metabolic_score,
    labels = c("Low", "Intermediate", "High"),
    breaks = c(-Inf, 1.2, 3.8, Inf)
  )

  self_rated_health_score <- 0.70 * behaviour_latent -
    0.028 * (age_years - 68) -
    0.18 * (bmi_kg_m2 - 28) -
    0.50 * current_smoker -
    0.25 * diagnosed_hypertension_num -
    0.45 * type2_diabetes_num -
    0.35 * longstanding_condition_num -
    0.16 * multimorbidity_count -
    1.05 * frailty_index -
    0.20 * care_home_resident_num -
    0.15 * imd_offset -
    0.05 * gp_visits_last_12m +
    rnorm(n, 0, 0.9)

  self_rated_health <- assign_ordered_levels(
    self_rated_health_score,
    labels = c("Very bad", "Bad", "Fair", "Good", "Very good"),
    breaks = c(-Inf, -1.40, -0.45, 0.45, 1.25, Inf)
  )

  lifestyle_program_enrolled <- ifelse(
    runif(n) < stats::plogis(
      -2.15 +
        0.75 * obesity_num +
        0.95 * prediabetes_num +
        0.35 * high_risk_num +
        0.22 * as.integer(gp_visits_last_12m > 3) -
        0.30 * moderate_or_severe_frailty -
        0.10 * current_smoker +
        0.15 * imd_offset
    ),
    "Yes",
    "No"
  )

  baseline_complete <- data.frame(
    participant_id = participant_id,
    site_code = site_code,
    imd_quintile = imd_quintile,
    recruitment_year = recruitment_year,
    age_years = age_years,
    sex_at_birth = sex_at_birth,
    ethnicity_group = ethnicity_group,
    blood_group = blood_group,
    smoking_status = smoking_status,
    alcohol_units_per_week = alcohol_units_per_week,
    weekly_exercise_min = weekly_exercise_min,
    inactive_under_30min = inactive_under_30min,
    sleep_hours_per_night = sleep_hours_per_night,
    fruit_veg_portions_per_day = fruit_veg_portions_per_day,
    family_history_cvd = family_history_cvd,
    family_history_diabetes = family_history_diabetes,
    height_cm = height_cm,
    weight_kg = weight_kg,
    bmi_kg_m2 = bmi_kg_m2,
    obesity = obesity,
    waist_cm = waist_cm,
    waist_to_height_ratio = waist_to_height_ratio,
    high_central_adiposity = high_central_adiposity,
    systolic_bp_mmHg = systolic_bp_mmHg,
    diastolic_bp_mmHg = diastolic_bp_mmHg,
    measured_hypertension = measured_hypertension,
    resting_heart_rate_bpm = resting_heart_rate_bpm,
    fasting_glucose_mmol_L = fasting_glucose_mmol_L,
    hba1c_mmol_mol = hba1c_mmol_mol,
    type2_diabetes = type2_diabetes,
    prediabetes = prediabetes,
    total_cholesterol_mmol_L = total_cholesterol_mmol_L,
    raised_total_cholesterol = raised_total_cholesterol,
    hdl_cholesterol_mmol_L = hdl_cholesterol_mmol_L,
    ldl_cholesterol_mmol_L = ldl_cholesterol_mmol_L,
    triglycerides_mmol_L = triglycerides_mmol_L,
    total_hdl_ratio = total_hdl_ratio,
    high_total_hdl_ratio = high_total_hdl_ratio,
    crp_mg_L = crp_mg_L,
    creatinine_umol_L = creatinine_umol_L,
    egfr_ml_min_1_73m2 = egfr_ml_min_1_73m2,
    self_rated_health = self_rated_health,
    longstanding_condition = longstanding_condition,
    chronic_kidney_disease = chronic_kidney_disease,
    atrial_fibrillation = atrial_fibrillation,
    previous_mi = previous_mi,
    previous_stroke_tia = previous_stroke_tia,
    copd = copd,
    cancer_history = cancer_history,
    osteoarthritis = osteoarthritis,
    depression_anxiety = depression_anxiety,
    dementia_cognitive_impairment = dementia_cognitive_impairment,
    multimorbidity_count = multimorbidity_count,
    falls_last_12m = falls_last_12m,
    polypharmacy_5plus = polypharmacy_5plus,
    frailty_index = frailty_index,
    frailty_category = frailty_category,
    care_home_resident = care_home_resident,
    gp_visits_last_12m = gp_visits_last_12m,
    sick_days_last_12m = sick_days_last_12m,
    on_antihypertensive = on_antihypertensive,
    on_statin = on_statin,
    diagnosed_hypertension = diagnosed_hypertension,
    high_cardiovascular_risk = high_cardiovascular_risk,
    hospital_admission_24m = hospital_admission_24m,
    hospital_admission_5y = hospital_admission_5y,
    metabolic_risk_group = metabolic_risk_group,
    lifestyle_program_enrolled = lifestyle_program_enrolled,
    mortality_risk_5y_pct = mortality_risk_5y_pct,
    died_during_followup = died_during_followup,
    death_month = death_month,
    age_at_death = age_at_death,
    primary_cause_of_death = primary_cause_of_death,
    stringsAsFactors = FALSE
  )

  baseline_complete$self_rated_health <- factor(
    baseline_complete$self_rated_health,
    levels = c("Very bad", "Bad", "Fair", "Good", "Very good"),
    ordered = TRUE
  )
  baseline_complete$metabolic_risk_group <- factor(
    baseline_complete$metabolic_risk_group,
    levels = c("Low", "Intermediate", "High"),
    ordered = TRUE
  )
  baseline_complete$frailty_category <- factor(
    baseline_complete$frailty_category,
    levels = c("Fit", "Mild frailty", "Moderate frailty", "Severe frailty"),
    ordered = TRUE
  )

  baseline_observed <- apply_baseline_missingness(baseline_complete)

  list(
    complete = baseline_complete,
    observed = baseline_observed
  )
}

simulate_visits <- function(baseline_complete, seed) {
  set.seed(seed + 5000)
  n <- nrow(baseline_complete)

  visit_plan <- expand.grid(
    participant_index = seq_len(n),
    visit_number = 0:5,
    KEEP.OUT.ATTRS = FALSE
  )
  visit_plan <- visit_plan[order(visit_plan$participant_index, visit_plan$visit_number), ]
  base <- baseline_complete[visit_plan$participant_index, ]

  scheduled_month <- c(0, 12, 24, 36, 48, 60)[visit_plan$visit_number + 1]
  alive_for_visit <- visit_plan$visit_number == 0 |
    is.na(base$death_month) |
    scheduled_month <= base$death_month
  retention_prob <- clamp(
    0.94 -
      0.050 * visit_plan$visit_number -
      0.035 * (base$smoking_status == "Current") -
      0.030 * (base$imd_quintile >= 4) -
      0.020 * pmin(base$multimorbidity_count, 6) -
      0.055 * (base$frailty_category %in% c("Moderate frailty", "Severe frailty")) +
      0.040 * (base$lifestyle_program_enrolled == "Yes") +
      0.015 * (base$site_code == "Bristol"),
    0.38,
    0.96
  )

  keep_row <- visit_plan$visit_number == 0 |
    (alive_for_visit & runif(nrow(visit_plan)) < retention_prob)
  visit_plan <- visit_plan[keep_row, ]
  scheduled_month <- scheduled_month[keep_row]
  base <- base[keep_row, ]

  participant_response <- rnorm(n)
  participant_response <- participant_response[visit_plan$participant_index]
  in_program <- base$lifestyle_program_enrolled == "Yes"

  visit_jitter <- rep(0, nrow(visit_plan))
  visit_jitter[visit_plan$visit_number > 0] <- rnorm(sum(visit_plan$visit_number > 0), 0, 1.7)
  months_since_baseline <- round(clamp(scheduled_month + visit_jitter, 0, 63))
  months_since_baseline[visit_plan$visit_number == 0] <- 0
  months_since_baseline <- ifelse(
    !is.na(base$death_month) & months_since_baseline > base$death_month,
    base$death_month,
    months_since_baseline
  )
  years_since_baseline <- months_since_baseline / 12

  exercise_change <- ifelse(
    visit_plan$visit_number == 0,
    0,
    ifelse(in_program, 26 * years_since_baseline, 5 * years_since_baseline)
  ) +
    8 * participant_response +
    rnorm(nrow(visit_plan), 0, 24)
  weekly_exercise_min <- round(clamp(base$weekly_exercise_min + exercise_change, 0, 480))

  weight_change <- ifelse(
    visit_plan$visit_number == 0,
    0,
    ifelse(in_program, -1.35 * years_since_baseline, 0.15 * years_since_baseline)
  ) -
    0.22 * participant_response +
    rnorm(nrow(visit_plan), 0, 2.2)
  weight_kg <- round(clamp(base$weight_kg + weight_change, 43, 160), 1)
  bmi_kg_m2 <- round(weight_kg / (base$height_cm / 100)^2, 1)

  systolic_bp_mmHg <- round(clamp(
    base$systolic_bp_mmHg +
      0.9 * years_since_baseline +
      0.8 * (weight_kg - base$weight_kg) -
      ifelse(in_program, 1.6 * years_since_baseline, 0) +
      rnorm(nrow(visit_plan), 0, 6.4),
    85,
    195
  ))

  diastolic_bp_mmHg <- round(clamp(
    base$diastolic_bp_mmHg +
      0.3 * years_since_baseline +
      0.5 * (weight_kg - base$weight_kg) -
      ifelse(in_program, 0.8 * years_since_baseline, 0) +
      rnorm(nrow(visit_plan), 0, 4.8),
    50,
    118
  ))

  resting_heart_rate_bpm <- round(clamp(
    base$resting_heart_rate_bpm -
      0.025 * (weekly_exercise_min - base$weekly_exercise_min) +
      0.10 * (weight_kg - base$weight_kg) +
      rnorm(nrow(visit_plan), 0, 4.5),
    45,
    110
  ))

  fasting_glucose_mmol_L <- round(clamp(
    base$fasting_glucose_mmol_L +
      0.05 * years_since_baseline +
      0.040 * (bmi_kg_m2 - base$bmi_kg_m2) -
      ifelse(in_program, 0.06 * years_since_baseline, 0) +
      rnorm(nrow(visit_plan), 0, 0.28),
    3.5,
    10.5
  ), 2)

  hba1c_mmol_mol <- round(clamp(
    base$hba1c_mmol_mol +
      1.8 * (fasting_glucose_mmol_L - base$fasting_glucose_mmol_L) +
      0.25 * years_since_baseline +
      rnorm(nrow(visit_plan), 0, 2.1),
    22,
    75
  ), 1)

  total_cholesterol_mmol_L <- round(clamp(
    base$total_cholesterol_mmol_L -
      ifelse(in_program, 0.08 * years_since_baseline, 0.02 * years_since_baseline) +
      0.012 * (weight_kg - base$weight_kg) +
      rnorm(nrow(visit_plan), 0, 0.28),
    2.7,
    8.5
  ), 2)

  hdl_cholesterol_mmol_L <- round(clamp(
    base$hdl_cholesterol_mmol_L +
      0.0008 * (weekly_exercise_min - base$weekly_exercise_min) -
      0.010 * (weight_kg - base$weight_kg) +
      rnorm(nrow(visit_plan), 0, 0.07),
    0.60,
    2.60
  ), 2)

  triglycerides_mmol_L <- round(clamp(
    exp(
      log(base$triglycerides_mmol_L) -
        ifelse(in_program, 0.05 * years_since_baseline, 0.01 * years_since_baseline) +
        0.015 * (weight_kg - base$weight_kg) +
        rnorm(nrow(visit_plan), 0, 0.15)
    ),
    0.40,
    5.50
  ), 2)

  crp_mg_L <- round(clamp(
    exp(
      log(base$crp_mg_L) -
        ifelse(in_program, 0.06 * years_since_baseline, 0.01 * years_since_baseline) +
        0.020 * (weight_kg - base$weight_kg) +
        rnorm(nrow(visit_plan), 0, 0.20)
    ),
    0.10,
    20.00
  ), 2)

  medication_adherence_pct <- ifelse(
    base$on_antihypertensive == "Yes" | base$on_statin == "Yes",
    round(clamp(
      74 +
        4 * years_since_baseline +
        5 * in_program -
        4 * (base$smoking_status == "Current") +
        rnorm(nrow(visit_plan), 0, 9),
      35,
      100
    )),
    NA
  )

  self_rated_health_score <- 0.30 * scale(weekly_exercise_min)[, 1] -
    0.12 * scale(bmi_kg_m2)[, 1] -
    0.14 * scale(systolic_bp_mmHg)[, 1] -
    0.18 * (base$smoking_status == "Current") +
    0.12 * (base$imd_quintile <= 2) -
    0.15 * (base$imd_quintile >= 4) +
    0.22 * in_program +
    rnorm(nrow(visit_plan), 0, 0.60)
  self_rated_health <- assign_ordered_levels(
    self_rated_health_score,
    labels = c("Very bad", "Bad", "Fair", "Good", "Very good"),
    breaks = c(-Inf, -1.20, -0.35, 0.35, 1.05, Inf)
  )

  visit_label <- c("baseline", "12_month", "24_month", "36_month", "48_month", "60_month")[visit_plan$visit_number + 1]
  age_at_visit_years <- round(base$age_years + years_since_baseline, 1)

  visits <- data.frame(
    participant_id = base$participant_id,
    visit_number = visit_plan$visit_number,
    visit_label = visit_label,
    months_since_baseline = months_since_baseline,
    age_at_visit_years = age_at_visit_years,
    site_code = base$site_code,
    imd_quintile = base$imd_quintile,
    smoking_status = base$smoking_status,
    lifestyle_program_enrolled = base$lifestyle_program_enrolled,
    multimorbidity_count = base$multimorbidity_count,
    frailty_category = base$frailty_category,
    mortality_risk_5y_pct = base$mortality_risk_5y_pct,
    weekly_exercise_min = weekly_exercise_min,
    weight_kg = weight_kg,
    bmi_kg_m2 = bmi_kg_m2,
    systolic_bp_mmHg = systolic_bp_mmHg,
    diastolic_bp_mmHg = diastolic_bp_mmHg,
    resting_heart_rate_bpm = resting_heart_rate_bpm,
    fasting_glucose_mmol_L = fasting_glucose_mmol_L,
    hba1c_mmol_mol = hba1c_mmol_mol,
    total_cholesterol_mmol_L = total_cholesterol_mmol_L,
    hdl_cholesterol_mmol_L = hdl_cholesterol_mmol_L,
    triglycerides_mmol_L = triglycerides_mmol_L,
    crp_mg_L = crp_mg_L,
    medication_adherence_pct = medication_adherence_pct,
    self_rated_health = self_rated_health,
    living_status_at_visit = "Alive",
    stringsAsFactors = FALSE
  )

  visits$self_rated_health <- factor(
    visits$self_rated_health,
    levels = c("Very bad", "Bad", "Fair", "Good", "Very good"),
    ordered = TRUE
  )
  visits$frailty_category <- factor(
    visits$frailty_category,
    levels = c("Fit", "Mild frailty", "Moderate frailty", "Severe frailty"),
    ordered = TRUE
  )

  baseline_rows <- visits$visit_number == 0
  visits$weight_kg[baseline_rows] <- base$weight_kg[baseline_rows]
  visits$bmi_kg_m2[baseline_rows] <- base$bmi_kg_m2[baseline_rows]
  visits$systolic_bp_mmHg[baseline_rows] <- base$systolic_bp_mmHg[baseline_rows]
  visits$diastolic_bp_mmHg[baseline_rows] <- base$diastolic_bp_mmHg[baseline_rows]
  visits$resting_heart_rate_bpm[baseline_rows] <- base$resting_heart_rate_bpm[baseline_rows]
  visits$fasting_glucose_mmol_L[baseline_rows] <- base$fasting_glucose_mmol_L[baseline_rows]
  visits$hba1c_mmol_mol[baseline_rows] <- base$hba1c_mmol_mol[baseline_rows]
  visits$total_cholesterol_mmol_L[baseline_rows] <- base$total_cholesterol_mmol_L[baseline_rows]
  visits$hdl_cholesterol_mmol_L[baseline_rows] <- base$hdl_cholesterol_mmol_L[baseline_rows]
  visits$triglycerides_mmol_L[baseline_rows] <- base$triglycerides_mmol_L[baseline_rows]
  visits$crp_mg_L[baseline_rows] <- base$crp_mg_L[baseline_rows]
  visits$weekly_exercise_min[baseline_rows] <- base$weekly_exercise_min[baseline_rows]
  visits$self_rated_health[baseline_rows] <- base$self_rated_health[baseline_rows]

  visits <- apply_visit_missingness(visits)
  visits[order(visits$participant_id, visits$visit_number), ]
}

evaluate_dataset <- function(baseline, visits) {
  baseline_complete <- baseline[complete.cases(
    baseline[, c(
      "age_years",
      "systolic_bp_mmHg",
      "bmi_kg_m2",
      "fasting_glucose_mmol_L",
      "weekly_exercise_min",
      "resting_heart_rate_bpm",
      "hdl_cholesterol_mmol_L",
      "triglycerides_mmol_L",
      "mortality_risk_5y_pct",
      "multimorbidity_count"
    )]
  ), ]

  visit_counts <- table(visits$visit_number)
  retention_24 <- if ("2" %in% names(visit_counts)) as.numeric(visit_counts[["2"]]) / nrow(baseline) else 0
  retention_60 <- if ("5" %in% names(visit_counts)) as.numeric(visit_counts[["5"]]) / nrow(baseline) else 0

  paired_ids <- intersect(
    visits$participant_id[visits$visit_number == 0],
    visits$participant_id[visits$visit_number == 2]
  )
  paired_subset <- visits[visits$participant_id %in% paired_ids, ]
  wide_weight <- reshape(
    paired_subset[, c("participant_id", "visit_number", "weight_kg", "lifestyle_program_enrolled")],
    idvar = c("participant_id", "lifestyle_program_enrolled"),
    timevar = "visit_number",
    direction = "wide"
  )
  colnames(wide_weight) <- gsub("weight_kg\\.", "weight_visit_", colnames(wide_weight))
  mean_weight_change_24m <- mean(wide_weight$weight_visit_2 - wide_weight$weight_visit_0, na.rm = TRUE)
  program_weight_change_24m <- mean(
    wide_weight$weight_visit_2[wide_weight$lifestyle_program_enrolled == "Yes"] -
      wide_weight$weight_visit_0[wide_weight$lifestyle_program_enrolled == "Yes"],
    na.rm = TRUE
  )

  blood_group_test <- suppressWarnings(stats::chisq.test(table(baseline$blood_group, baseline$prediabetes)))
  ethnic_high <- baseline$ethnicity_group %in% c("Asian", "Black")
  ethnic_reference <- baseline$ethnicity_group %in% c("White", "Mixed", "Other")
  ethnic_prediabetes_ratio <- mean(baseline$prediabetes[ethnic_high] == "Yes") /
    mean(baseline$prediabetes[ethnic_reference] == "Yes")
  imd_diabetes_difference <- mean(baseline$type2_diabetes[baseline$imd_quintile == 5] == "Yes") -
    mean(baseline$type2_diabetes[baseline$imd_quintile == 1] == "Yes")

  metrics <- c(
    "participants", "visit_rows", "female_proportion", "mean_age",
    "current_smoker_proportion", "inactive_proportion", "mean_bmi",
    "mean_height_male", "mean_height_female", "obesity_proportion",
    "measured_hypertension_proportion", "diagnosed_hypertension_proportion",
    "prediabetes_proportion", "type2_diabetes_proportion",
    "raised_cholesterol_proportion", "longstanding_condition_proportion",
    "multimorbidity_mean", "chronic_kidney_disease_proportion",
    "atrial_fibrillation_proportion", "copd_proportion",
    "dementia_cognitive_impairment_proportion", "moderate_or_severe_frailty_proportion",
    "severe_frailty_proportion", "polypharmacy_5plus_proportion",
    "high_cardiovascular_risk_proportion", "hospital_admission_5y_proportion",
    "mortality_5y_proportion", "mean_mortality_risk_5y_pct",
    "lifestyle_program_proportion", "corr_age_sbp", "corr_bmi_glucose",
    "corr_exercise_heart_rate", "corr_hdl_triglycerides",
    "corr_age_mortality_risk", "corr_multimorbidity_mortality_risk",
    "or_current_smoker_hypertension", "or_obesity_prediabetes",
    "or_ckd_mortality", "or_severe_frailty_mortality",
    "imd_diabetes_difference", "ethnic_prediabetes_ratio",
    "median_crp_ratio_current_vs_never", "blood_group_vs_prediabetes_pvalue",
    "hba1c_missing_proportion", "crp_missing_proportion",
    "retention_24m", "retention_60m",
    "mean_weight_change_24m", "program_mean_weight_change_24m"
  )

  values <- c(
    nrow(baseline), nrow(visits), mean(baseline$sex_at_birth == "Female"),
    mean(baseline$age_years), mean(baseline$smoking_status == "Current"),
    mean(baseline$inactive_under_30min == "Yes"), mean(baseline$bmi_kg_m2),
    mean(baseline$height_cm[baseline$sex_at_birth == "Male"]),
    mean(baseline$height_cm[baseline$sex_at_birth == "Female"]),
    mean(baseline$obesity == "Yes"), mean(baseline$measured_hypertension == "Yes"),
    mean(baseline$diagnosed_hypertension == "Yes"),
    mean(baseline$prediabetes == "Yes"), mean(baseline$type2_diabetes == "Yes"),
    mean(baseline$raised_total_cholesterol == "Yes"),
    mean(baseline$longstanding_condition == "Yes"),
    mean(baseline$multimorbidity_count),
    mean(baseline$chronic_kidney_disease == "Yes"),
    mean(baseline$atrial_fibrillation == "Yes"), mean(baseline$copd == "Yes"),
    mean(baseline$dementia_cognitive_impairment == "Yes"),
    mean(baseline$frailty_category %in% c("Moderate frailty", "Severe frailty")),
    mean(baseline$frailty_category == "Severe frailty"),
    mean(baseline$polypharmacy_5plus == "Yes"),
    mean(baseline$high_cardiovascular_risk == "Yes"),
    mean(baseline$hospital_admission_5y == "Yes"),
    mean(baseline$died_during_followup == "Yes"),
    mean(baseline$mortality_risk_5y_pct),
    mean(baseline$lifestyle_program_enrolled == "Yes"),
    safe_cor(baseline_complete$age_years, baseline_complete$systolic_bp_mmHg),
    safe_cor(baseline_complete$bmi_kg_m2, baseline_complete$fasting_glucose_mmol_L),
    safe_cor(baseline_complete$weekly_exercise_min, baseline_complete$resting_heart_rate_bpm),
    safe_cor(baseline_complete$hdl_cholesterol_mmol_L, baseline_complete$triglycerides_mmol_L),
    safe_cor(baseline_complete$age_years, baseline_complete$mortality_risk_5y_pct),
    safe_cor(baseline_complete$multimorbidity_count, baseline_complete$mortality_risk_5y_pct),
    odds_ratio_2x2(baseline$smoking_status == "Current", baseline$diagnosed_hypertension == "Yes"),
    odds_ratio_2x2(baseline$obesity == "Yes", baseline$prediabetes == "Yes"),
    odds_ratio_2x2(baseline$chronic_kidney_disease == "Yes", baseline$died_during_followup == "Yes"),
    odds_ratio_2x2(baseline$frailty_category == "Severe frailty", baseline$died_during_followup == "Yes"),
    imd_diabetes_difference, ethnic_prediabetes_ratio,
    stats::median(baseline$crp_mg_L[baseline$smoking_status == "Current"], na.rm = TRUE) /
      stats::median(baseline$crp_mg_L[baseline$smoking_status == "Never"], na.rm = TRUE),
    blood_group_test$p.value,
    mean(is.na(baseline$hba1c_mmol_mol)), mean(is.na(baseline$crp_mg_L)),
    retention_24, retention_60, mean_weight_change_24m, program_weight_change_24m
  )

  target_low <- c(
    2200, 8000, 0.48, 68.0, 0.07, 0.23, 27.4, 174.8, 161.3, 0.28,
    0.50, 0.32, 0.18, 0.08, 0.45, 0.60, 1.6, 0.16, 0.04, 0.07,
    0.03, 0.12, 0.02, 0.20, 0.25, 0.28, 0.07, 7.0, 0.14,
    0.15, 0.15, -0.32, -0.55, 0.45, 0.25, 1.00, 1.40, 1.40, 2.00,
    0.04, 1.20, 1.05, 0.05, 0.03, 0.03, 0.55, 0.30, -0.60, -3.20
  )

  target_high <- c(
    2800, 12000, 0.54, 73.0, 0.15, 0.45, 30.0, 176.5, 162.9, 0.42,
    0.75, 0.58, 0.36, 0.24, 0.70, 0.82, 3.5, 0.42, 0.16, 0.22,
    0.12, 0.36, 0.11, 0.55, 0.48, 0.60, 0.16, 16.0, 0.32,
    0.38, 0.42, -0.08, -0.18, 0.82, 0.75, 1.70, 3.40, 4.80, 10.00,
    0.15, 2.50, 1.75, 1.00, 0.09, 0.10, 0.86, 0.66, 0.60, -0.50
  )

  diagnostics <- data.frame(
    metric = metrics,
    value = values,
    target_low = target_low,
    target_high = target_high,
    stringsAsFactors = FALSE
  )

  diagnostics$penalty <- mapply(
    penalty_from_range,
    diagnostics$value,
    diagnostics$target_low,
    diagnostics$target_high
  )
  diagnostics
}

build_codebook <- function() {
  rows <- list(
    c("baseline", "participant_id", "Unique participant identifier", "identifier", "none", "BIO00001", "Merge baseline and visit tables"),
    c("baseline", "site_code", "Recruiting clinic site in England", "categorical", "none", "Bristol, Birmingham, Leeds, Manchester", "Cross-tabulation, chi-square"),
    c("baseline", "imd_quintile", "Index of Multiple Deprivation quintile (1 least deprived, 5 most deprived)", "ordered integer", "quintile", "1 to 5", "Ordinal analysis, trend tests, regression"),
    c("baseline", "recruitment_year", "Year of recruitment", "integer", "year", "2024, 2025, 2026", "Stratification, trend checks"),
    c("baseline", "age_years", "Age at recruitment", "continuous", "years", "50 to 90", "Descriptives, correlations, regression, mortality risk"),
    c("baseline", "sex_at_birth", "Recorded sex at birth", "binary categorical", "none", "Female, Male", "Proportions, t-tests, regression coding"),
    c("baseline", "ethnicity_group", "Broad ethnicity group", "categorical", "none", "White, Asian, Black, Mixed, Other", "Frequencies, chi-square, ANOVA"),
    c("baseline", "blood_group", "ABO blood group", "categorical", "none", "O, A, B, AB", "Example of a mostly null exposure"),
    c("baseline", "smoking_status", "Current smoking history category", "categorical", "none", "Never, Former, Current", "Contingency tables, ANOVA, regression"),
    c("baseline", "alcohol_units_per_week", "Self-reported alcohol intake", "continuous", "units/week", "0 to 40", "Distributions, transformations"),
    c("baseline", "weekly_exercise_min", "Weekly moderate exercise time", "continuous", "minutes/week", "0 to 420", "Descriptives, non-normal data, regression"),
    c("baseline", "inactive_under_30min", "Less than 30 minutes of moderate or vigorous activity per week", "binary categorical", "none", "Yes, No", "Probability, odds ratios, chi-square"),
    c("baseline", "sleep_hours_per_night", "Average sleep per night", "continuous", "hours", "4.5 to 9.5", "Correlations, missing data"),
    c("baseline", "fruit_veg_portions_per_day", "Daily fruit and vegetable intake", "continuous", "portions/day", "0.5 to 8.0", "Correlations, missing data"),
    c("baseline", "family_history_cvd", "Family history of cardiovascular disease", "binary categorical", "none", "Yes, No", "Odds, logistic regression"),
    c("baseline", "family_history_diabetes", "Family history of diabetes", "binary categorical", "none", "Yes, No", "Odds, logistic regression"),
    c("baseline", "height_cm", "Standing height", "continuous", "cm", "145 to 200", "Approximate normal distribution"),
    c("baseline", "weight_kg", "Body weight", "continuous", "kg", "45 to 160", "Distributions, repeated measures"),
    c("baseline", "bmi_kg_m2", "Body mass index derived from height and weight", "continuous", "kg/m^2", "20 to 46", "Transformations, regression"),
    c("baseline", "obesity", "BMI at least 30 kg/m^2", "binary categorical", "none", "Yes, No", "Odds ratios, logistic regression"),
    c("baseline", "waist_cm", "Waist circumference", "continuous", "cm", "60 to 145", "Correlation, collinearity discussion"),
    c("baseline", "waist_to_height_ratio", "Waist-to-height ratio", "continuous", "ratio", "0.35 to 0.85", "Ratios, derived variables, distributions"),
    c("baseline", "high_central_adiposity", "Waist-to-height ratio at least 0.6", "binary categorical", "none", "Yes, No", "Derived binary outcome"),
    c("baseline", "systolic_bp_mmHg", "Systolic blood pressure", "continuous", "mmHg", "88 to 195", "Parametric tests, linear regression"),
    c("baseline", "diastolic_bp_mmHg", "Diastolic blood pressure", "continuous", "mmHg", "52 to 120", "Parametric tests, linear regression"),
    c("baseline", "measured_hypertension", "Measured hypertension or antihypertensive treatment", "binary categorical", "none", "Yes, No", "Probability, odds, prevalence"),
    c("baseline", "resting_heart_rate_bpm", "Resting heart rate", "continuous", "beats/min", "48 to 110", "Correlations, repeated measures"),
    c("baseline", "fasting_glucose_mmol_L", "Fasting glucose", "continuous", "mmol/L", "3.6 to 10.2", "Distributions, regression"),
    c("baseline", "hba1c_mmol_mol", "HbA1c glycaemic marker", "continuous", "mmol/mol", "25 to 82", "Missing data, regression"),
    c("baseline", "type2_diabetes", "Simulated type 2 diabetes status based on glycaemic profile", "binary categorical", "none", "Yes, No", "Probability, logistic regression"),
    c("baseline", "prediabetes", "Prediabetes or non-diabetic hyperglycaemia", "binary categorical", "none", "Yes, No", "Probability, logistic regression"),
    c("baseline", "total_cholesterol_mmol_L", "Total cholesterol", "continuous", "mmol/L", "2.8 to 8.5", "Descriptives, regression"),
    c("baseline", "raised_total_cholesterol", "Total cholesterol at least 5 mmol/L", "binary categorical", "none", "Yes, No", "Prevalence, chi-square, logistic regression"),
    c("baseline", "hdl_cholesterol_mmol_L", "HDL cholesterol", "continuous", "mmol/L", "0.7 to 2.5", "Correlations, lipid profiles"),
    c("baseline", "ldl_cholesterol_mmol_L", "Estimated LDL cholesterol", "continuous", "mmol/L", "1.2 to 6.3", "Regression, derived variables"),
    c("baseline", "triglycerides_mmol_L", "Triglycerides", "continuous", "mmol/L", "0.45 to 5.5", "Skewed distribution, log transform"),
    c("baseline", "total_hdl_ratio", "Total cholesterol divided by HDL cholesterol", "continuous", "ratio", "1.5 to 10", "Derived cardiovascular risk marker"),
    c("baseline", "high_total_hdl_ratio", "Total-to-HDL cholesterol ratio at least 6", "binary categorical", "none", "Yes, No", "Derived binary risk marker"),
    c("baseline", "crp_mg_L", "C-reactive protein", "continuous", "mg/L", "0.1 to 20", "Skewed distribution, non-parametric tests"),
    c("baseline", "creatinine_umol_L", "Serum creatinine", "continuous", "umol/L", "45 to 150", "Regression, renal markers"),
    c("baseline", "egfr_ml_min_1_73m2", "Estimated glomerular filtration rate", "continuous", "mL/min/1.73m^2", "35 to 125", "Inverse association examples"),
    c("baseline", "self_rated_health", "Self-rated overall health using UK survey wording", "ordered categorical", "none", "Very bad to Very good", "Ordinal data, non-parametric tests"),
    c("baseline", "longstanding_condition", "Longstanding health condition", "binary categorical", "none", "Yes, No", "Probability, odds, regression"),
    c("baseline", "chronic_kidney_disease", "Simulated chronic kidney disease status", "binary categorical", "none", "Yes, No", "Comorbidity, mortality prediction"),
    c("baseline", "atrial_fibrillation", "Simulated atrial fibrillation history", "binary categorical", "none", "Yes, No", "Comorbidity, stroke risk, mortality prediction"),
    c("baseline", "previous_mi", "Previous myocardial infarction history", "binary categorical", "none", "Yes, No", "Comorbidity, cardiovascular risk"),
    c("baseline", "previous_stroke_tia", "Previous stroke or transient ischaemic attack history", "binary categorical", "none", "Yes, No", "Comorbidity, mortality prediction"),
    c("baseline", "copd", "Simulated chronic obstructive pulmonary disease status", "binary categorical", "none", "Yes, No", "Smoking-related comorbidity"),
    c("baseline", "cancer_history", "Previous cancer diagnosis history", "binary categorical", "none", "Yes, No", "Comorbidity, mortality prediction"),
    c("baseline", "osteoarthritis", "Simulated osteoarthritis status", "binary categorical", "none", "Yes, No", "Older-age comorbidity, function"),
    c("baseline", "depression_anxiety", "Depression or anxiety history", "binary categorical", "none", "Yes, No", "Comorbidity, self-rated health"),
    c("baseline", "dementia_cognitive_impairment", "Dementia or cognitive impairment history", "binary categorical", "none", "Yes, No", "Frailty, mortality prediction"),
    c("baseline", "multimorbidity_count", "Count of selected long-term conditions", "count", "conditions", "0 to 11", "Count data, risk modelling"),
    c("baseline", "falls_last_12m", "Falls reported in the last year", "count", "falls", "0 to 6", "Count data, frailty"),
    c("baseline", "polypharmacy_5plus", "Taking five or more regular medicines", "binary categorical", "none", "Yes, No", "Comorbidity burden"),
    c("baseline", "frailty_index", "Simplified frailty index derived from age, conditions, falls, and polypharmacy", "continuous", "index", "0.02 to 0.58", "Risk score, distributions"),
    c("baseline", "frailty_category", "Frailty category derived from frailty index", "ordered categorical", "none", "Fit, Mild frailty, Moderate frailty, Severe frailty", "Ordinal data, mortality prediction"),
    c("baseline", "care_home_resident", "Simulated care-home residence at baseline", "binary categorical", "none", "Yes, No", "Older-age risk stratification"),
    c("baseline", "gp_visits_last_12m", "General practice visits in the last year", "count", "visits", "0 to 18", "Count data, Poisson discussion"),
    c("baseline", "sick_days_last_12m", "Days off work or study due to illness", "count", "days", "0 to 40", "Count data, skewed outcomes"),
    c("baseline", "on_antihypertensive", "Currently taking blood pressure medication", "binary categorical", "none", "Yes, No", "Odds, confounding"),
    c("baseline", "on_statin", "Currently taking statin medication", "binary categorical", "none", "Yes, No", "Odds, confounding"),
    c("baseline", "diagnosed_hypertension", "Clinical hypertension diagnosis", "binary categorical", "none", "Yes, No", "Probability, odds, logistic regression"),
    c("baseline", "high_cardiovascular_risk", "Elevated cardiovascular risk category", "binary categorical", "none", "Yes, No", "Logistic regression"),
    c("baseline", "hospital_admission_24m", "Any hospital admission during the first 24 months", "binary categorical", "none", "Yes, No", "Probability, risk prediction"),
    c("baseline", "hospital_admission_5y", "Any hospital admission during five-year follow-up", "binary categorical", "none", "Yes, No", "Probability, risk prediction"),
    c("baseline", "metabolic_risk_group", "Overall metabolic risk group", "ordered categorical", "none", "Low, Intermediate, High", "Ordinal comparisons"),
    c("baseline", "lifestyle_program_enrolled", "Joined the lifestyle support programme", "binary categorical", "none", "Yes, No", "Observational group comparisons"),
    c("baseline", "mortality_risk_5y_pct", "Predicted five-year mortality risk from the simulated risk model", "continuous", "percent", "0 to 60", "Risk prediction, calibration, logistic regression"),
    c("baseline", "died_during_followup", "Died during five-year follow-up", "binary categorical", "none", "Yes, No", "Survival and mortality teaching"),
    c("baseline", "death_month", "Month of death after baseline for participants who died", "continuous", "months", "1 to 60", "Time-to-event teaching"),
    c("baseline", "age_at_death", "Age at death for participants who died", "continuous", "years", "50 to 95", "Mortality summaries"),
    c("baseline", "primary_cause_of_death", "Broad simulated primary cause of death", "categorical", "none", "Cancer, stroke, dementia, respiratory, heart disease, other", "Cause-specific mortality examples"),
    c("mortality_comorbidity", "participant_id", "Unique participant identifier", "identifier", "none", "BIO00001", "Merge with baseline and visits"),
    c("mortality_comorbidity", "age_years", "Age at recruitment copied from baseline", "continuous", "years", "50 to 90", "Risk modelling"),
    c("mortality_comorbidity", "sex_at_birth", "Recorded sex at birth copied from baseline", "binary categorical", "none", "Female, Male", "Risk modelling"),
    c("mortality_comorbidity", "imd_quintile", "Index of Multiple Deprivation quintile copied from baseline", "ordered integer", "quintile", "1 to 5", "Deprivation gradient"),
    c("mortality_comorbidity", "multimorbidity_count", "Count of selected long-term conditions", "count", "conditions", "0 to 11", "Risk modelling"),
    c("mortality_comorbidity", "frailty_index", "Simplified frailty index", "continuous", "index", "0.02 to 0.58", "Risk score"),
    c("mortality_comorbidity", "frailty_category", "Frailty category", "ordered categorical", "none", "Fit, Mild frailty, Moderate frailty, Severe frailty", "Ordinal risk groups"),
    c("mortality_comorbidity", "chronic_kidney_disease", "Simulated chronic kidney disease status", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "atrial_fibrillation", "Simulated atrial fibrillation history", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "previous_mi", "Previous myocardial infarction history", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "previous_stroke_tia", "Previous stroke or TIA history", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "copd", "Simulated COPD status", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "cancer_history", "Previous cancer diagnosis history", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "dementia_cognitive_impairment", "Dementia or cognitive impairment history", "binary categorical", "none", "Yes, No", "Comorbidity"),
    c("mortality_comorbidity", "polypharmacy_5plus", "Taking five or more regular medicines", "binary categorical", "none", "Yes, No", "Medication burden"),
    c("mortality_comorbidity", "care_home_resident", "Simulated care-home residence", "binary categorical", "none", "Yes, No", "Older-age risk stratification"),
    c("mortality_comorbidity", "mortality_risk_5y_pct", "Predicted five-year mortality risk", "continuous", "percent", "0 to 60", "Risk prediction"),
    c("mortality_comorbidity", "died_during_followup", "Died during five-year follow-up", "binary categorical", "none", "Yes, No", "Mortality outcome"),
    c("mortality_comorbidity", "death_month", "Month of death after baseline", "continuous", "months", "1 to 60", "Time-to-event outcome"),
    c("mortality_comorbidity", "death_calendar_year", "Approximate calendar year of death", "integer", "year", "2024 to 2031", "Event timing"),
    c("mortality_comorbidity", "age_at_death", "Age at death", "continuous", "years", "50 to 95", "Mortality summaries"),
    c("mortality_comorbidity", "primary_cause_of_death", "Broad simulated primary cause of death", "categorical", "none", "Cancer, stroke, dementia, respiratory, heart disease, other", "Cause-specific mortality"),
    c("visits", "participant_id", "Unique participant identifier", "identifier", "none", "BIO00001", "Merge with baseline table"),
    c("visits", "visit_number", "Visit order", "integer", "visit index", "0 to 5", "Repeated-measures filtering"),
    c("visits", "visit_label", "Human-readable visit label", "categorical", "none", "baseline, 12_month, 24_month, 36_month, 48_month, 60_month", "Repeated-measures filtering"),
    c("visits", "months_since_baseline", "Approximate months since baseline", "integer", "months", "0 to 63", "Time trends"),
    c("visits", "age_at_visit_years", "Age at visit", "continuous", "years", "50 to 95", "Longitudinal age effects"),
    c("visits", "site_code", "Recruiting clinic site", "categorical", "none", "Bristol, Birmingham, Leeds, Manchester", "Stratified repeated measures"),
    c("visits", "imd_quintile", "Index of Multiple Deprivation quintile carried forward", "ordered integer", "quintile", "1 to 5", "Stratified repeated measures"),
    c("visits", "smoking_status", "Baseline smoking category carried forward", "categorical", "none", "Never, Former, Current", "Grouped longitudinal summaries"),
    c("visits", "lifestyle_program_enrolled", "Programme enrolment carried forward", "binary categorical", "none", "Yes, No", "Change-score comparisons"),
    c("visits", "multimorbidity_count", "Baseline multimorbidity count carried forward", "count", "conditions", "0 to 11", "Stratified longitudinal summaries"),
    c("visits", "frailty_category", "Baseline frailty category carried forward", "ordered categorical", "none", "Fit, Mild frailty, Moderate frailty, Severe frailty", "Stratified longitudinal summaries"),
    c("visits", "mortality_risk_5y_pct", "Baseline predicted five-year mortality risk carried forward", "continuous", "percent", "0 to 60", "Attrition and risk stratification"),
    c("visits", "weekly_exercise_min", "Exercise reported at visit", "continuous", "minutes/week", "0 to 480", "Paired tests, trajectories"),
    c("visits", "weight_kg", "Body weight at visit", "continuous", "kg", "43 to 160", "Paired tests, repeated measures"),
    c("visits", "bmi_kg_m2", "BMI at visit", "continuous", "kg/m^2", "17 to 45", "Trajectories, change scores"),
    c("visits", "systolic_bp_mmHg", "Systolic blood pressure at visit", "continuous", "mmHg", "85 to 195", "Paired t-tests, mixed-model examples"),
    c("visits", "diastolic_bp_mmHg", "Diastolic blood pressure at visit", "continuous", "mmHg", "50 to 118", "Paired t-tests, mixed-model examples"),
    c("visits", "resting_heart_rate_bpm", "Resting heart rate at visit", "continuous", "beats/min", "45 to 110", "Time trends"),
    c("visits", "fasting_glucose_mmol_L", "Fasting glucose at visit", "continuous", "mmol/L", "3.5 to 10.5", "Paired tests, regression on change"),
    c("visits", "hba1c_mmol_mol", "HbA1c at visit", "continuous", "mmol/mol", "22 to 75", "Missing data, longitudinal summaries"),
    c("visits", "total_cholesterol_mmol_L", "Total cholesterol at visit", "continuous", "mmol/L", "2.7 to 8.5", "Trajectories"),
    c("visits", "hdl_cholesterol_mmol_L", "HDL cholesterol at visit", "continuous", "mmol/L", "0.6 to 2.6", "Trajectories"),
    c("visits", "triglycerides_mmol_L", "Triglycerides at visit", "continuous", "mmol/L", "0.4 to 5.5", "Log-transform examples"),
    c("visits", "crp_mg_L", "C-reactive protein at visit", "continuous", "mg/L", "0.1 to 20", "Non-parametric repeated measures"),
    c("visits", "medication_adherence_pct", "Medication adherence for treated participants", "continuous", "percent", "35 to 100", "Missing data, bounded variables"),
    c("visits", "self_rated_health", "Self-rated health at visit", "ordered categorical", "none", "Very bad to Very good", "Ordinal longitudinal analysis"),
    c("visits", "living_status_at_visit", "Living status at each observed visit", "binary categorical", "none", "Alive", "Death-censored follow-up discussion")
  )

  out <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  colnames(out) <- c(
    "table_name",
    "variable_name",
    "label",
    "data_type",
    "units",
    "example_values",
    "suggested_teaching_use"
  )
  out
}

write_readme <- function(output_dir, baseline, visits, diagnostics, selected_seed, master_seed, issue_count) {
  retention_24 <- diagnostics$value[diagnostics$metric == "retention_24m"]
  obesity <- diagnostics$value[diagnostics$metric == "obesity_proportion"]
  measured_hypertension <- diagnostics$value[diagnostics$metric == "measured_hypertension_proportion"]
  diagnosed_hypertension <- diagnostics$value[diagnostics$metric == "diagnosed_hypertension_proportion"]
  prediabetes <- diagnostics$value[diagnostics$metric == "prediabetes_proportion"]
  type2_diabetes <- diagnostics$value[diagnostics$metric == "type2_diabetes_proportion"]
  lines <- c(
    "# Introductory Biostatistics Teaching Dataset",
    "",
    "This folder contains a fully simulated England-based older adult cardiometabolic cohort designed for an introductory statistics module.",
    "The cohort now spans 50 to 90 years and includes five years of follow-up so that multimorbidity, frailty, mortality, and death-censored visits can be taught alongside core introductory statistics.",
    "",
    "## Files",
    "- `bioinformatics_msc_stats_baseline.csv`: one row per participant with demographics, deprivation, lifestyle, clinical measures, laboratory results, and binary outcomes.",
    "- `bioinformatics_msc_stats_visits.csv`: repeated measurements at baseline, 12, 24, 36, 48, and 60 months for paired tests, change scores, attrition, and longitudinal plots.",
    "- `bioinformatics_msc_stats_mortality_comorbidity.csv`: linked participant-level comorbidity, frailty, predicted five-year mortality risk, death timing, and broad cause of death.",
    "- `bioinformatics_msc_stats_codebook.csv`: variable dictionary with labels, data types, units, and teaching suggestions.",
    "- `bioinformatics_msc_stats_diagnostics.csv`: summary metrics used to judge whether the simulated dataset feels plausible.",
    "- `bioinformatics_msc_stats_variable_summaries.csv`: long-format summary statistics for every variable.",
    "- `bioinformatics_msc_stats_category_levels.csv`: counts and percentages for categorical levels.",
    "- `bioinformatics_msc_stats_teaching_associations.csv`: association statistics for the main teaching examples.",
    "- `validation_summary.md`: general dataset summary with full descriptives and teaching associations.",
    "- `mortality_comorbidity_model_notes.md`: plain-language explanation of the simulated mortality and comorbidity model.",
    "- `uk_calibration_notes.md`: source-backed notes describing how the UK-focused prevalences and associations were calibrated.",
    "- `data_cleaning_student_brief.md`: spoiler-free student instructions for auditing and cleaning the deliberately messy data.",
    "- `data_cleaning_instructor_key.md`: instructor-only answer key with every planted problem and its exact location.",
    "- `data_cleaning_issue_key.csv`: machine-readable audit log of the planted problems and intended values.",
    "- `simulate_intro_stats_dataset.R`: the reproducible generator script.",
    "",
    "## Cohort profile",
    paste0("- Participants: ", nrow(baseline), " baseline records across four English sites."),
    paste0("- Visit rows: ", nrow(visits), " records covering baseline to 60 months."),
    paste0("- Age range: ", min(baseline$age_years), " to ", max(baseline$age_years), " years."),
    paste0("- Obesity prevalence: ", sprintf("%.1f%%", 100 * obesity), "."),
    paste0("- Measured hypertension prevalence: ", sprintf("%.1f%%", 100 * measured_hypertension), "."),
    paste0("- Diagnosed hypertension prevalence: ", sprintf("%.1f%%", 100 * diagnosed_hypertension), "."),
    paste0("- Prediabetes prevalence: ", sprintf("%.1f%%", 100 * prediabetes), "."),
    paste0("- Type 2 diabetes prevalence: ", sprintf("%.1f%%", 100 * type2_diabetes), "."),
    "",
    "## Design notes",
    "- The data are entirely simulated and do not describe real patients.",
    "- The cohort is UK-flavoured rather than generic. Variables such as IMD quintile, self-rated general health wording, NHS-style risk factors, older-age comorbidities, and blood group frequencies were chosen to feel familiar in an England teaching context.",
    "- This is no longer a strict NHS Health Check age-band sample. The older age range deliberately increases chronic disease, multimorbidity, attrition, and deaths for teaching.",
    "- Associations were tuned to be plausible rather than perfect. Some variables are moderately related, some are weakly related, and a few were left close to null on purpose.",
    "- BMI is derived from height and weight, waist-to-height ratio is derived from waist circumference and height, and LDL cholesterol is estimated from the lipid profile. Those stronger relationships are therefore expected.",
    "- The `prediabetes` variable is intended as an accessible teaching label for non-diabetic hyperglycaemia or prediabetes.",
    "- A small amount of missingness is included in selected questionnaire and laboratory variables.",
    paste0("- The distributed CSVs deliberately contain ", issue_count, " planted data-quality issues for cleaning exercises, including categorical inconsistencies, invalid ranges, and duplicate visit rows."),
    "- Treat the three cohort CSVs as raw teaching data. The codebook records the intended categories and ranges; the instructor key should be withheld from students until debriefing.",
    paste0("- The reproducible master seed is `", master_seed, "` and the selected simulation seed is `", selected_seed, "`."),
    "",
    "## Suggested practical uses",
    "- Descriptive statistics and visualisation: age, BMI, systolic blood pressure, HbA1c, CRP, triglycerides, and total:HDL ratio.",
    "- Probability and odds: smoking, measured hypertension, diagnosed hypertension, prediabetes, type 2 diabetes, hospital admission, frailty, and death.",
    "- Distributions and transformations: triglycerides and CRP are deliberately right-skewed, while height is closer to normal.",
    "- Categorical data: IMD quintile, smoking status, blood group, self-rated health, and ethnicity group.",
    "- Parametric tests: compare systolic blood pressure, BMI, or fasting glucose between groups.",
    "- Non-parametric tests: compare CRP across smoking groups or self-rated health categories.",
    "- Regression: fit linear models for systolic blood pressure or glucose, and logistic models for prediabetes, type 2 diabetes, hospital admission, or mortality.",
    "- Confounding and mediation examples: obesity, central adiposity, deprivation, smoking, family history, multimorbidity, and frailty in relation to clinical outcomes.",
    "- Longitudinal work: use the visits table for paired tests, repeated measures plots, change-score analyses, death-censoring, and attrition checks.",
    "",
    "## Teaching Suggestions By Learning Objective",
    "1. Understand data structure and variable types. Use `bioinformatics_msc_stats_baseline.csv` and `bioinformatics_msc_stats_visits.csv` to identify continuous variables such as `age_years` and `bmi_kg_m2`, binary variables such as `prediabetes` and `type2_diabetes`, categorical variables such as `smoking_status` and `blood_group`, and ordered variables such as `imd_quintile` and `self_rated_health`. Teaching tip: ask students to classify each variable before they choose any graph or statistical test.",
    "2. Summarise data appropriately. Use `age_years`, `bmi_kg_m2`, `systolic_bp_mmHg`, `weekly_exercise_min`, and `crp_mg_L` to compare mean and standard deviation against median and interquartile range. Teaching tip: make students justify why one summary is more appropriate than another instead of treating summary tables as automatic output.",
    "3. Recognise common distributions. `height_cm` is roughly normal, while `triglycerides_mmol_L` and `crp_mg_L` are right-skewed, and outcomes such as `measured_hypertension` and `prediabetes` behave like binary variables. Teaching tip: ask students to predict the shape of each distribution before they plot it.",
    "4. Work with probability, risk, and odds. Use prevalence of `current_smoker`, `obesity`, `prediabetes`, `type2_diabetes`, `hospital_admission_5y`, and `died_during_followup` to teach absolute probability, odds, odds ratios, and conditional probability. Teaching tip: keep returning to plain-language interpretations such as 'about 1 in 4' before introducing formulas.",
    "5. Analyse categorical associations. Good examples are `smoking_status` by `self_rated_health`, `imd_quintile` by `type2_diabetes`, and `blood_group` by `prediabetes`. Teaching tip: include one real association and one near-null association so students see that not every cross-tabulation should be significant.",
    "6. Compare two groups with parametric methods. Use t-tests or confidence intervals for means with outcomes such as `systolic_bp_mmHg` by `sex_at_birth`, or `fasting_glucose_mmol_L` by `obesity`. Teaching tip: have students inspect the distributions and spread before they run the test, so the method follows the reasoning.",
    "7. Use non-parametric methods when appropriate. `crp_mg_L` across `smoking_status` or `self_rated_health` works well for Mann-Whitney or Kruskal-Wallis tests. Teaching tip: stress that non-parametric methods are often the more defensible choice for skewed data rather than a weaker fallback.",
    "8. Interpret correlation properly. Use `age_years` with `systolic_bp_mmHg`, `bmi_kg_m2` with `fasting_glucose_mmol_L`, and `hdl_cholesterol_mmol_L` with `triglycerides_mmol_L`. Teaching tip: make students describe direction, strength, and plausibility separately, and repeat that correlation is not causation.",
    "9. Fit and interpret linear regression. Good outcomes are `systolic_bp_mmHg`, `fasting_glucose_mmol_L`, or `resting_heart_rate_bpm`, with predictors such as `age_years`, `sex_at_birth`, `bmi_kg_m2`, `smoking_status`, and `weekly_exercise_min`. Teaching tip: start with one-predictor models and then add covariates so students can see adjustment happen rather than only seeing the final model.",
    "10. Fit and interpret logistic regression. Use binary outcomes such as `prediabetes`, `measured_hypertension`, `type2_diabetes`, `hospital_admission_5y`, or `died_during_followup`. Teaching tip: insist on translating odds ratios back into plain English because students often confuse odds ratios with risk ratios.",
    "11. Teach confounding and adjustment. The association between `obesity` and `prediabetes`, or between `imd_quintile` and `type2_diabetes`, is useful for showing how age, sex, ethnicity, and lifestyle can alter crude effect estimates. Teaching tip: require the crude result first, then the adjusted result, then a short explanation of why they differ.",
    "12. Introduce interaction and effect modification. Possible examples are whether the BMI and glycaemia relationship differs by `sex_at_birth` or `ethnicity_group`, or whether age relates to blood pressure differently by sex. Teaching tip: only introduce interaction once students are comfortable with main effects, otherwise interpretation becomes noise.",
    "13. Work with repeated measures and paired data. The visits table supports paired analysis of `weight_kg`, `systolic_bp_mmHg`, `hba1c_mmol_mol`, or `weekly_exercise_min` between visit 0 and later visits, including comparison by `lifestyle_program_enrolled`. Teaching tip: use this to explain why repeated observations from the same person are not independent and why deaths censor later observations.",
    "14. Handle missing data sensibly. `hba1c_mmol_mol` and `crp_mg_L` contain light missingness, which is enough to discuss complete-case analysis, missing-data summaries, and potential bias. Teaching tip: ask students to compare the characteristics of complete and incomplete cases before they drop rows.",
    "15. Emphasise effect sizes, uncertainty, and realism. Because the dataset contains moderate rather than extreme associations, it is useful for confidence intervals, practical significance, and the difference between statistical significance and importance. Teaching tip: require an estimate, a confidence interval, and one sentence of practical interpretation rather than a p-value alone.",
    "16. Audit and clean raw data before analysis. Ask students to check duplicated keys, unexpected factor levels, leading or trailing whitespace, inconsistent case, and values outside codebook ranges. Teaching tip: require a reproducible cleaning log showing the original value, rule applied, and cleaned value.",
    "",
    "## General Teaching Tips",
    "- Start with plots before tests wherever possible.",
    "- Ask students to predict the likely direction of an association before they run any code.",
    "- Keep at least one weak or null example in each practical so students do not expect significance everywhere.",
    "- Repeatedly distinguish `measured_hypertension` from `diagnosed_hypertension` so students see that similar-looking binary variables can represent different underlying concepts.",
    "- Use the baseline table when teaching cross-sectional methods, the visits table when teaching within-person change and attrition, and the mortality/comorbidity table when teaching risk prediction and outcome modelling.",
    "",
    "## Re-run",
    "From the command line, run:",
    "",
    "```powershell",
    "Rscript simulate_intro_stats_dataset.R generated_uk 2400 20260420",
    "```",
    "",
    paste0("The generated dataset currently retains approximately ", sprintf('%.1f', retention_24 * 100), "% of participants at 24 months; see diagnostics for 60-month retention and mortality.")
  )
  writeLines(lines, con = file.path(output_dir, "README_intro_stats_dataset.md"))
}

preferred_levels_for_variable <- function(var_name, observed_levels) {
  preferred <- switch(
    var_name,
    site_code = c("Bristol", "Birmingham", "Leeds", "Manchester"),
    sex_at_birth = c("Female", "Male"),
    ethnicity_group = c("White", "Asian", "Black", "Mixed", "Other"),
    blood_group = c("O", "A", "B", "AB"),
    smoking_status = c("Never", "Former", "Current"),
    inactive_under_30min = c("No", "Yes"),
    family_history_cvd = c("No", "Yes"),
    family_history_diabetes = c("No", "Yes"),
    obesity = c("No", "Yes"),
    high_central_adiposity = c("No", "Yes"),
    measured_hypertension = c("No", "Yes"),
    type2_diabetes = c("No", "Yes"),
    prediabetes = c("No", "Yes"),
    raised_total_cholesterol = c("No", "Yes"),
    high_total_hdl_ratio = c("No", "Yes"),
    self_rated_health = c("Very bad", "Bad", "Fair", "Good", "Very good"),
    longstanding_condition = c("No", "Yes"),
    chronic_kidney_disease = c("No", "Yes"),
    atrial_fibrillation = c("No", "Yes"),
    previous_mi = c("No", "Yes"),
    previous_stroke_tia = c("No", "Yes"),
    copd = c("No", "Yes"),
    cancer_history = c("No", "Yes"),
    osteoarthritis = c("No", "Yes"),
    depression_anxiety = c("No", "Yes"),
    dementia_cognitive_impairment = c("No", "Yes"),
    polypharmacy_5plus = c("No", "Yes"),
    frailty_category = c("Fit", "Mild frailty", "Moderate frailty", "Severe frailty"),
    care_home_resident = c("No", "Yes"),
    on_antihypertensive = c("No", "Yes"),
    on_statin = c("No", "Yes"),
    diagnosed_hypertension = c("No", "Yes"),
    high_cardiovascular_risk = c("No", "Yes"),
    hospital_admission_24m = c("No", "Yes"),
    hospital_admission_5y = c("No", "Yes"),
    metabolic_risk_group = c("Low", "Intermediate", "High"),
    lifestyle_program_enrolled = c("No", "Yes"),
    died_during_followup = c("No", "Yes"),
    primary_cause_of_death = c("Not applicable", "Cancer", "Dementia and neurodegenerative disease", "Ischaemic heart disease", "Respiratory disease", "Stroke", "Other"),
    visit_label = c("baseline", "12_month", "24_month", "36_month", "48_month", "60_month"),
    living_status_at_visit = c("Alive"),
    NULL
  )

  observed_levels <- observed_levels[!is.na(observed_levels) & observed_levels != ""]
  if (length(observed_levels) == 0) {
    return(character(0))
  }
  if (is.null(preferred)) {
    return(sort(unique(observed_levels)))
  }

  unique_observed <- unique(observed_levels)
  c(preferred[preferred %in% unique_observed], sort(setdiff(unique_observed, preferred)))
}

format_summary_value <- function(statistic, value) {
  if (is.na(value)) {
    return("NA")
  }

  if (statistic %in% c("Rows", "Non-missing n", "Missing n", "Unique values", "Duplicate values", "Levels observed", "Mode count")) {
    return(as.character(as.integer(round(value))))
  }
  if (grepl("%", statistic, fixed = TRUE) || grepl("percent", statistic, ignore.case = TRUE)) {
    return(paste0(formatC(value, format = "f", digits = 1), "%"))
  }
  formatC(value, format = "f", digits = 3)
}

format_percent_text <- function(value, digits = 1) {
  if (length(value) != 1) {
    return(vapply(value, format_percent_text, character(1), digits = digits))
  }
  if (is.na(value)) {
    return("NA")
  }
  paste0(formatC(value, format = "f", digits = digits), "%")
}

format_number_text <- function(value, digits = 3) {
  if (length(value) != 1) {
    return(vapply(value, format_number_text, character(1), digits = digits))
  }
  if (is.na(value)) {
    return("NA")
  }
  formatC(value, format = "f", digits = digits)
}

format_p_value <- function(value) {
  if (is.na(value)) {
    return("NA")
  }
  if (value < 0.001) {
    return("<0.001")
  }
  formatC(value, format = "f", digits = 3)
}

summarise_variable_statistics <- function(x, meta) {
  total_n <- length(x)
  variable_name <- meta$variable_name[[1]]
  data_type <- meta$data_type[[1]]
  label <- meta$label[[1]]
  units <- meta$units[[1]]
  table_name <- meta$table_name[[1]]

  if (data_type == "identifier") {
    x_char <- as.character(x)
    missing_idx <- is.na(x_char) | trimws(x_char) == ""
    non_missing <- x_char[!missing_idx]
    summary_df <- data.frame(
      statistic = c("Rows", "Non-missing n", "Missing n", "Missing %", "Unique values", "Duplicate values"),
      value = c(
        total_n,
        length(non_missing),
        sum(missing_idx),
        100 * mean(missing_idx),
        length(unique(non_missing)),
        length(non_missing) - length(unique(non_missing))
      ),
      stringsAsFactors = FALSE
    )
    return(list(
      meta = data.frame(
        table_name = table_name,
        variable_name = variable_name,
        label = label,
        data_type = data_type,
        units = units,
        stringsAsFactors = FALSE
      ),
      summary = summary_df,
      levels = data.frame(level = character(0), count = numeric(0), percent = numeric(0), stringsAsFactors = FALSE)
    ))
  }

  if (data_type %in% c("continuous", "integer", "ordered integer", "count")) {
    x_num <- as.numeric(x)
    missing_idx <- is.na(x_num)
    non_missing <- x_num[!missing_idx]

    if (length(non_missing) == 0) {
      summary_values <- rep(NA_real_, 8)
    } else {
      summary_values <- c(
        mean(non_missing),
        stats::sd(non_missing),
        stats::median(non_missing),
        stats::IQR(non_missing),
        min(non_missing),
        as.numeric(stats::quantile(non_missing, 0.25, names = FALSE)),
        as.numeric(stats::quantile(non_missing, 0.75, names = FALSE)),
        max(non_missing)
      )
    }

    summary_df <- data.frame(
      statistic = c("Rows", "Non-missing n", "Missing n", "Missing %", "Mean", "SD", "Median", "IQR", "Min", "Q1", "Q3", "Max"),
      value = c(
        total_n,
        length(non_missing),
        sum(missing_idx),
        100 * mean(missing_idx),
        summary_values
      ),
      stringsAsFactors = FALSE
    )

    return(list(
      meta = data.frame(
        table_name = table_name,
        variable_name = variable_name,
        label = label,
        data_type = data_type,
        units = units,
        stringsAsFactors = FALSE
      ),
      summary = summary_df,
      levels = data.frame(level = character(0), count = numeric(0), percent = numeric(0), stringsAsFactors = FALSE)
    ))
  }

  x_char <- as.character(x)
  missing_idx <- is.na(x_char) | trimws(x_char) == ""
  non_missing <- x_char[!missing_idx]
  level_order <- preferred_levels_for_variable(variable_name, non_missing)
  level_counts <- if (length(level_order) == 0) {
    data.frame(level = character(0), count = numeric(0), percent = numeric(0), stringsAsFactors = FALSE)
  } else {
    tab <- table(factor(non_missing, levels = level_order), useNA = "no")
    data.frame(
      level = names(tab),
      count = as.numeric(tab),
      percent = if (length(non_missing) == 0) NA_real_ else 100 * as.numeric(tab) / length(non_missing),
      stringsAsFactors = FALSE
    )
  }

  mode_level <- if (nrow(level_counts) > 0) level_counts$level[which.max(level_counts$count)][1] else NA_character_
  mode_count <- if (nrow(level_counts) > 0) max(level_counts$count) else NA_real_
  mode_percent <- if (nrow(level_counts) > 0) level_counts$percent[which.max(level_counts$count)][1] else NA_real_

  summary_df <- data.frame(
    statistic = c("Rows", "Non-missing n", "Missing n", "Missing %", "Levels observed", "Mode count", "Mode percent"),
    value = c(
      total_n,
      length(non_missing),
      sum(missing_idx),
      100 * mean(missing_idx),
      length(unique(non_missing)),
      mode_count,
      mode_percent
    ),
    stringsAsFactors = FALSE
  )
  if (!is.na(mode_level)) {
    summary_df <- rbind(
      summary_df,
      data.frame(statistic = "Mode level", value = NA_real_, stringsAsFactors = FALSE)
    )
    summary_df$mode_level <- c(rep(NA_character_, nrow(summary_df) - 1), mode_level)
  } else {
    summary_df$mode_level <- NA_character_
  }

  list(
    meta = data.frame(
      table_name = table_name,
      variable_name = variable_name,
      label = label,
      data_type = data_type,
      units = units,
      stringsAsFactors = FALSE
    ),
    summary = summary_df,
    levels = level_counts
  )
}

build_variable_summary_objects <- function(data, codebook_subset) {
  lapply(seq_len(nrow(codebook_subset)), function(i) summarise_variable_statistics(data[[codebook_subset$variable_name[[i]]]], codebook_subset[i, , drop = FALSE]))
}

flatten_summary_rows <- function(summary_objects) {
  rows <- lapply(summary_objects, function(obj) {
    mode_level <- if ("mode_level" %in% names(obj$summary)) obj$summary$mode_level else rep(NA_character_, nrow(obj$summary))
    data.frame(
      table_name = obj$meta$table_name[[1]],
      variable_name = obj$meta$variable_name[[1]],
      label = obj$meta$label[[1]],
      data_type = obj$meta$data_type[[1]],
      units = obj$meta$units[[1]],
      statistic = obj$summary$statistic,
      value = obj$summary$value,
      text_value = mode_level,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

flatten_level_rows <- function(summary_objects) {
  rows <- lapply(summary_objects, function(obj) {
    if (nrow(obj$levels) == 0) {
      return(NULL)
    }
    data.frame(
      table_name = obj$meta$table_name[[1]],
      variable_name = obj$meta$variable_name[[1]],
      label = obj$meta$label[[1]],
      data_type = obj$meta$data_type[[1]],
      level = obj$levels$level,
      count = obj$levels$count,
      percent = obj$levels$percent,
      stringsAsFactors = FALSE
    )
  })
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0) {
    return(data.frame(
      table_name = character(0),
      variable_name = character(0),
      label = character(0),
      data_type = character(0),
      level = character(0),
      count = numeric(0),
      percent = numeric(0),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

render_variable_summary_lines <- function(summary_objects) {
  lines <- character()
  for (obj in summary_objects) {
    units_text <- obj$meta$units[[1]]
    meta_line <- paste0(obj$meta$label[[1]], " (`", obj$meta$data_type[[1]], "`")
    if (!is.na(units_text) && units_text != "none") {
      meta_line <- paste0(meta_line, ", units: `", units_text, "`")
    }
    meta_line <- paste0(meta_line, ")")

    lines <- c(
      lines,
      paste0("### ", obj$meta$variable_name[[1]]),
      meta_line,
      "",
      "| Statistic | Value |",
      "| --- | --- |"
    )

    for (i in seq_len(nrow(obj$summary))) {
      mode_level <- if ("mode_level" %in% names(obj$summary)) obj$summary$mode_level[[i]] else NA_character_
      if (!is.na(mode_level)) {
        display_value <- mode_level
      } else {
        display_value <- format_summary_value(obj$summary$statistic[[i]], obj$summary$value[[i]])
      }
      lines <- c(lines, paste0("| ", obj$summary$statistic[[i]], " | ", display_value, " |"))
    }

    if (nrow(obj$levels) > 0) {
      lines <- c(
        lines,
        "",
        "| Level | Count | Percent |",
        "| --- | ---: | ---: |"
      )
      for (i in seq_len(nrow(obj$levels))) {
        lines <- c(
          lines,
          paste0("| ", obj$levels$level[[i]], " | ", as.integer(round(obj$levels$count[[i]])), " | ", format_percent_text(obj$levels$percent[[i]]), " |")
        )
      }
    }
    lines <- c(lines, "")
  }
  lines
}

association_row <- function(theme, variables, method, n_used, statistic, estimate, p_value, details = "") {
  data.frame(
    theme = theme,
    variables = variables,
    method = method,
    n_used = n_used,
    statistic = statistic,
    estimate = estimate,
    p_value = p_value,
    details = details,
    stringsAsFactors = FALSE
  )
}

summarise_correlation_association <- function(data, x, y) {
  complete_idx <- complete.cases(data[, c(x, y)])
  n_used <- sum(complete_idx)
  if (n_used >= 3) {
    test <- suppressWarnings(stats::cor.test(data[[x]][complete_idx], data[[y]][complete_idx]))
    estimate <- as.numeric(test$estimate)
    p_value <- test$p.value
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
  }
  association_row("Correlation", paste0(x, " vs ", y), "Pearson correlation", n_used, "r", estimate, p_value)
}

summarise_ttest_association <- function(data, outcome, group, group_levels) {
  complete_idx <- !is.na(data[[outcome]]) & !is.na(data[[group]])
  outcome_values <- data[[outcome]][complete_idx]
  group_values <- as.character(data[[group]][complete_idx])
  keep_idx <- group_values %in% group_levels
  outcome_values <- outcome_values[keep_idx]
  group_values <- group_values[keep_idx]
  n_used <- length(outcome_values)

  if (all(group_levels %in% unique(group_values)) && sum(group_values == group_levels[[1]]) >= 2 && sum(group_values == group_levels[[2]]) >= 2) {
    group1 <- outcome_values[group_values == group_levels[[1]]]
    group2 <- outcome_values[group_values == group_levels[[2]]]
    test <- stats::t.test(group2, group1)
    estimate <- mean(group2) - mean(group1)
    p_value <- test$p.value
    details <- paste0(
      group_levels[[1]], " mean=", format_number_text(mean(group1)),
      "; ", group_levels[[2]], " mean=", format_number_text(mean(group2))
    )
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
    details <- ""
  }

  association_row(
    "Group comparison",
    paste0(group, " vs ", outcome),
    paste0("Two-sample t-test (", group_levels[[2]], " - ", group_levels[[1]], ")"),
    n_used,
    "mean difference",
    estimate,
    p_value,
    details
  )
}

summarise_kruskal_association <- function(data, outcome, group) {
  complete_idx <- !is.na(data[[outcome]]) & !is.na(data[[group]])
  outcome_values <- data[[outcome]][complete_idx]
  group_values <- as.character(data[[group]][complete_idx])
  group_levels <- preferred_levels_for_variable(group, group_values)
  factor_values <- factor(group_values, levels = group_levels)
  factor_values <- droplevels(factor_values)
  n_used <- length(outcome_values)

  if (nlevels(factor_values) >= 2) {
    test <- stats::kruskal.test(outcome_values ~ factor_values)
    medians <- tapply(outcome_values, factor_values, stats::median, na.rm = TRUE)
    details <- paste(paste0(names(medians), " median=", format_number_text(as.numeric(medians))), collapse = "; ")
    association_row(
      "Non-parametric comparison",
      paste0(group, " vs ", outcome),
      "Kruskal-Wallis test",
      n_used,
      "chi-squared",
      as.numeric(test$statistic),
      test$p.value,
      details
    )
  } else {
    association_row(
      "Non-parametric comparison",
      paste0(group, " vs ", outcome),
      "Kruskal-Wallis test",
      n_used,
      "chi-squared",
      NA_real_,
      NA_real_,
      ""
    )
  }
}

summarise_or_association <- function(data, exposure, outcome, exposure_value = "Yes", outcome_value = "Yes", comparison_label = NULL) {
  complete_idx <- !is.na(data[[exposure]]) & !is.na(data[[outcome]])
  exposure_values <- as.character(data[[exposure]][complete_idx]) == exposure_value
  outcome_values <- as.character(data[[outcome]][complete_idx]) == outcome_value
  n_used <- length(outcome_values)

  if (length(unique(exposure_values)) == 2 && length(unique(outcome_values)) == 2) {
    contingency <- table(exposure_values, outcome_values)
    estimate <- odds_ratio_2x2(exposure_values, outcome_values)
    p_value <- suppressWarnings(stats::fisher.test(contingency)$p.value)
    details <- paste0(
      outcome_value, " prevalence when exposed=",
      format_percent_text(100 * mean(outcome_values[exposure_values], na.rm = TRUE)),
      "; when unexposed=",
      format_percent_text(100 * mean(outcome_values[!exposure_values], na.rm = TRUE))
    )
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
    details <- ""
  }

  association_row(
    "Binary association",
    paste0(exposure, " vs ", outcome),
    if (is.null(comparison_label)) paste0("Odds ratio for ", exposure_value, " vs not ", exposure_value) else comparison_label,
    n_used,
    "odds ratio",
    estimate,
    p_value,
    details
  )
}

summarise_chisq_association <- function(data, x, y) {
  complete_idx <- !is.na(data[[x]]) & !is.na(data[[y]])
  x_values <- as.character(data[[x]][complete_idx])
  y_values <- as.character(data[[y]][complete_idx])
  x_levels <- preferred_levels_for_variable(x, x_values)
  y_levels <- preferred_levels_for_variable(y, y_values)
  contingency <- table(factor(x_values, levels = x_levels), factor(y_values, levels = y_levels))
  contingency <- contingency[rowSums(contingency) > 0, colSums(contingency) > 0, drop = FALSE]
  n_used <- sum(contingency)

  if (all(dim(contingency) >= 2)) {
    test <- suppressWarnings(stats::chisq.test(contingency))
    min_dim <- min(dim(contingency)) - 1
    estimate <- if (min_dim > 0 && n_used > 0) sqrt(as.numeric(test$statistic) / (n_used * min_dim)) else NA_real_
    p_value <- test$p.value
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
  }

  association_row(
    "Categorical association",
    paste0(x, " vs ", y),
    "Chi-square test",
    n_used,
    "Cramer's V",
    estimate,
    p_value
  )
}

summarise_paired_change_association <- function(visits, outcome, visit_a = 0, visit_b = 2) {
  subset_visits <- visits[visits$visit_number %in% c(visit_a, visit_b), c("participant_id", "visit_number", outcome)]
  wide <- reshape(subset_visits, idvar = "participant_id", timevar = "visit_number", direction = "wide")
  col_a <- paste0(outcome, ".", visit_a)
  col_b <- paste0(outcome, ".", visit_b)

  if (!(col_a %in% names(wide)) || !(col_b %in% names(wide))) {
    return(association_row("Repeated measures", paste0(outcome, " visit ", visit_a, " vs visit ", visit_b), "Paired t-test", 0, "mean change", NA_real_, NA_real_))
  }

  complete_idx <- complete.cases(wide[, c(col_a, col_b)])
  n_used <- sum(complete_idx)

  if (n_used >= 2) {
    before <- wide[[col_a]][complete_idx]
    after <- wide[[col_b]][complete_idx]
    test <- stats::t.test(after, before, paired = TRUE)
    estimate <- mean(after - before)
    p_value <- test$p.value
    details <- paste0("visit_", visit_a, " mean=", format_number_text(mean(before)), "; visit_", visit_b, " mean=", format_number_text(mean(after)))
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
    details <- ""
  }

  association_row(
    "Repeated measures",
    paste0(outcome, " visit_", visit_a, " vs visit_", visit_b),
    paste0("Paired t-test (visit_", visit_b, " - visit_", visit_a, ")"),
    n_used,
    "mean change",
    estimate,
    p_value,
    details
  )
}

summarise_programme_change_association <- function(visits, outcome, visit_a = 0, visit_b = 2) {
  subset_visits <- visits[visits$visit_number %in% c(visit_a, visit_b), c("participant_id", "lifestyle_program_enrolled", "visit_number", outcome)]
  wide <- reshape(
    subset_visits,
    idvar = c("participant_id", "lifestyle_program_enrolled"),
    timevar = "visit_number",
    direction = "wide"
  )
  col_a <- paste0(outcome, ".", visit_a)
  col_b <- paste0(outcome, ".", visit_b)

  if (!(col_a %in% names(wide)) || !(col_b %in% names(wide))) {
    return(association_row("Programme comparison", paste0("lifestyle_program_enrolled vs ", outcome, " change"), "Two-sample t-test on change scores", 0, "mean difference in change", NA_real_, NA_real_))
  }

  wide$change_score <- wide[[col_b]] - wide[[col_a]]
  complete_idx <- !is.na(wide$change_score) & !is.na(wide$lifestyle_program_enrolled)
  analysis_df <- wide[complete_idx, c("change_score", "lifestyle_program_enrolled")]
  analysis_df <- analysis_df[analysis_df$lifestyle_program_enrolled %in% c("No", "Yes"), ]
  n_used <- nrow(analysis_df)

  if (all(c("No", "Yes") %in% unique(analysis_df$lifestyle_program_enrolled)) &&
      sum(analysis_df$lifestyle_program_enrolled == "No") >= 2 &&
      sum(analysis_df$lifestyle_program_enrolled == "Yes") >= 2) {
    no_group <- analysis_df$change_score[analysis_df$lifestyle_program_enrolled == "No"]
    yes_group <- analysis_df$change_score[analysis_df$lifestyle_program_enrolled == "Yes"]
    test <- stats::t.test(yes_group, no_group)
    estimate <- mean(yes_group) - mean(no_group)
    p_value <- test$p.value
    details <- paste0("No mean change=", format_number_text(mean(no_group)), "; Yes mean change=", format_number_text(mean(yes_group)))
  } else {
    estimate <- NA_real_
    p_value <- NA_real_
    details <- ""
  }

  association_row(
    "Programme comparison",
    paste0("lifestyle_program_enrolled vs ", outcome, " change"),
    "Two-sample t-test on change scores (Yes - No)",
    n_used,
    "mean difference in change",
    estimate,
    p_value,
    details
  )
}

build_teaching_associations <- function(baseline, visits) {
  do.call(
    rbind,
    list(
      summarise_correlation_association(baseline, "age_years", "systolic_bp_mmHg"),
      summarise_correlation_association(baseline, "age_years", "diastolic_bp_mmHg"),
      summarise_correlation_association(baseline, "bmi_kg_m2", "fasting_glucose_mmol_L"),
      summarise_correlation_association(baseline, "bmi_kg_m2", "hba1c_mmol_mol"),
      summarise_correlation_association(baseline, "weekly_exercise_min", "resting_heart_rate_bpm"),
      summarise_correlation_association(baseline, "hdl_cholesterol_mmol_L", "triglycerides_mmol_L"),
      summarise_correlation_association(baseline, "age_years", "mortality_risk_5y_pct"),
      summarise_correlation_association(baseline, "multimorbidity_count", "mortality_risk_5y_pct"),
      summarise_correlation_association(baseline, "frailty_index", "mortality_risk_5y_pct"),
      summarise_ttest_association(baseline, "systolic_bp_mmHg", "sex_at_birth", c("Female", "Male")),
      summarise_kruskal_association(baseline, "crp_mg_L", "smoking_status"),
      summarise_or_association(baseline, "obesity", "prediabetes", comparison_label = "Odds ratio for obesity Yes vs No"),
      summarise_or_association(baseline, "obesity", "type2_diabetes", comparison_label = "Odds ratio for obesity Yes vs No"),
      summarise_or_association(baseline, "diagnosed_hypertension", "high_cardiovascular_risk", comparison_label = "Odds ratio for diagnosed hypertension Yes vs No"),
      summarise_or_association(baseline, "family_history_diabetes", "type2_diabetes", comparison_label = "Odds ratio for family history diabetes Yes vs No"),
      summarise_or_association(baseline, "smoking_status", "diagnosed_hypertension", exposure_value = "Current", comparison_label = "Odds ratio for current smoking vs other smoking categories"),
      summarise_or_association(baseline, "chronic_kidney_disease", "died_during_followup", comparison_label = "Odds ratio for CKD Yes vs No"),
      summarise_or_association(baseline, "frailty_category", "died_during_followup", exposure_value = "Severe frailty", comparison_label = "Odds ratio for severe frailty vs other frailty categories"),
      summarise_or_association(baseline, "care_home_resident", "died_during_followup", comparison_label = "Odds ratio for care-home residence Yes vs No"),
      summarise_chisq_association(baseline, "blood_group", "prediabetes"),
      summarise_chisq_association(baseline, "imd_quintile", "type2_diabetes"),
      summarise_chisq_association(baseline, "frailty_category", "died_during_followup"),
      summarise_kruskal_association(baseline, "crp_mg_L", "self_rated_health"),
      summarise_paired_change_association(visits, "weight_kg"),
      summarise_paired_change_association(visits, "systolic_bp_mmHg"),
      summarise_paired_change_association(visits, "weight_kg", visit_b = 5),
      summarise_programme_change_association(visits, "weight_kg")
    )
  )
}

render_teaching_association_lines <- function(associations) {
  lines <- c(
    "| Theme | Variables | Method | N | Statistic | Estimate | P value | Details |",
    "| --- | --- | --- | ---: | --- | ---: | ---: | --- |"
  )

  for (i in seq_len(nrow(associations))) {
    lines <- c(
      lines,
      paste0(
        "| ", associations$theme[[i]],
        " | ", associations$variables[[i]],
        " | ", associations$method[[i]],
        " | ", associations$n_used[[i]],
        " | ", associations$statistic[[i]],
        " | ", format_number_text(associations$estimate[[i]]),
        " | ", format_p_value(associations$p_value[[i]]),
        " | ", ifelse(is.na(associations$details[[i]]) || associations$details[[i]] == "", " ", associations$details[[i]]),
        " |"
      )
    )
  }
  lines
}

build_mortality_comorbidity_table <- function(baseline) {
  mortality <- baseline[, c(
    "participant_id", "age_years", "sex_at_birth", "imd_quintile",
    "multimorbidity_count", "frailty_index", "frailty_category",
    "chronic_kidney_disease", "atrial_fibrillation", "previous_mi",
    "previous_stroke_tia", "copd", "cancer_history",
    "dementia_cognitive_impairment", "polypharmacy_5plus",
    "care_home_resident", "mortality_risk_5y_pct",
    "died_during_followup", "death_month", "age_at_death",
    "primary_cause_of_death"
  )]
  mortality$death_calendar_year <- ifelse(
    mortality$died_during_followup == "Yes",
    baseline$recruitment_year + floor((mortality$death_month - 1) / 12),
    NA
  )
  mortality[, c(
    "participant_id", "age_years", "sex_at_birth", "imd_quintile",
    "multimorbidity_count", "frailty_index", "frailty_category",
    "chronic_kidney_disease", "atrial_fibrillation", "previous_mi",
    "previous_stroke_tia", "copd", "cancer_history",
    "dementia_cognitive_impairment", "polypharmacy_5plus",
    "care_home_resident", "mortality_risk_5y_pct",
    "died_during_followup", "death_month", "death_calendar_year",
    "age_at_death", "primary_cause_of_death"
  )]
}

write_mortality_comorbidity_report <- function(output_dir, mortality_table, diagnostics) {
  cause_counts <- sort(table(mortality_table$primary_cause_of_death[mortality_table$died_during_followup == "Yes"]), decreasing = TRUE)
  cause_lines <- if (length(cause_counts) == 0) {
    "- No deaths were simulated in this run."
  } else {
    paste0("- ", names(cause_counts), ": ", as.integer(cause_counts))
  }

  frailty_tab <- table(mortality_table$frailty_category, mortality_table$died_during_followup)
  frailty_lines <- vapply(seq_len(nrow(frailty_tab)), function(i) {
    row <- frailty_tab[i, ]
    total <- sum(row)
    deaths <- if ("Yes" %in% names(row)) row[["Yes"]] else 0
    paste0("- ", rownames(frailty_tab)[[i]], ": ", deaths, "/", total, " deaths (", format_percent_text(100 * deaths / total), ")")
  }, character(1))

  lines <- c(
    "# Mortality And Comorbidity Model Notes",
    "",
    "This linked table is simulated from the baseline clinical, lifestyle, deprivation, frailty, and comorbidity variables.",
    "It is intended for teaching risk prediction, confounding, time-to-event thinking, attrition, and the difference between observed outcomes and modelled risk.",
    "",
    "## Generated File",
    "- `bioinformatics_msc_stats_mortality_comorbidity.csv`: one row per participant, linked by `participant_id`.",
    "",
    "## Model Inputs",
    "- Age, sex, IMD quintile, smoking, diabetes, measured hypertension, chronic kidney disease, previous myocardial infarction, previous stroke or TIA, atrial fibrillation, COPD, cancer history, dementia or cognitive impairment, frailty, care-home residence, and CRP all contribute to the simulated five-year mortality risk.",
    "- Deaths are then sampled from the predicted five-year risk. Participants who die are censored from later visit rows.",
    "- Broad cause of death is generated conditionally from the same risk profile, so cardiovascular, cancer, respiratory, dementia, stroke, and other causes are not randomly interchangeable.",
    "",
    "## Overall Mortality And Comorbidity",
    paste0("- Mean predicted five-year mortality risk: ", format_number_text(diagnostics$value[diagnostics$metric == "mean_mortality_risk_5y_pct"], 1), "%."),
    paste0("- Observed five-year deaths: ", sum(mortality_table$died_during_followup == "Yes"), " of ", nrow(mortality_table), " (", format_percent_text(100 * mean(mortality_table$died_during_followup == "Yes")), ")."),
    paste0("- Mean multimorbidity count: ", format_number_text(mean(mortality_table$multimorbidity_count), 2), " conditions."),
    paste0("- Moderate or severe frailty: ", format_percent_text(100 * mean(mortality_table$frailty_category %in% c("Moderate frailty", "Severe frailty"))), "."),
    paste0("- Care-home residence: ", format_percent_text(100 * mean(mortality_table$care_home_resident == "Yes")), "."),
    "",
    "## Deaths By Simulated Primary Cause",
    cause_lines,
    "",
    "## Deaths By Frailty Category",
    frailty_lines,
    "",
    "## Teaching Caveats",
    "- These are modelled outcomes, not real patient deaths.",
    "- The aim is internal realism: older age, frailty, multimorbidity, CKD, COPD, dementia, prior cardiovascular disease, deprivation, and smoking increase risk in plausible directions.",
    "- The mortality model is deliberately transparent enough for students to critique and refit; it should not be presented as a clinical risk calculator."
  )

  writeLines(lines, con = file.path(output_dir, "mortality_comorbidity_model_notes.md"))
}

write_validation_summary <- function(output_dir, baseline, visits, mortality_table, diagnostics) {
  codebook <- build_codebook()
  baseline_codebook <- codebook[codebook$table_name == "baseline", ]
  visits_codebook <- codebook[codebook$table_name == "visits", ]
  mortality_codebook <- codebook[codebook$table_name == "mortality_comorbidity", ]

  baseline_summaries <- build_variable_summary_objects(baseline, baseline_codebook)
  visit_summaries <- build_variable_summary_objects(visits, visits_codebook)
  mortality_summaries <- build_variable_summary_objects(mortality_table, mortality_codebook)

  variable_summary_rows <- rbind(
    flatten_summary_rows(baseline_summaries),
    flatten_summary_rows(visit_summaries),
    flatten_summary_rows(mortality_summaries)
  )
  category_level_rows <- rbind(
    flatten_level_rows(baseline_summaries),
    flatten_level_rows(visit_summaries),
    flatten_level_rows(mortality_summaries)
  )
  teaching_associations <- suppressWarnings(build_teaching_associations(baseline, visits))

  utils::write.csv(
    variable_summary_rows,
    file = file.path(output_dir, "bioinformatics_msc_stats_variable_summaries.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    category_level_rows,
    file = file.path(output_dir, "bioinformatics_msc_stats_category_levels.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    teaching_associations,
    file = file.path(output_dir, "bioinformatics_msc_stats_teaching_associations.csv"),
    row.names = FALSE,
    na = ""
  )

  lines <- c(
    "# General Dataset Summary",
    "",
    "This summary provides a full descriptive overview of the final England-focused simulated dataset.",
    "It includes variable-level summary statistics for both tables and association statistics for the main teaching examples.",
    "These summaries describe the raw distributed CSVs, so deliberately planted data-quality problems are visible in the levels, ranges, row counts, and some association estimates.",
    "",
    "## Summary Files",
    "- `bioinformatics_msc_stats_variable_summaries.csv` contains long-format summary statistics for every variable.",
    "- `bioinformatics_msc_stats_category_levels.csv` contains counts and percentages for categorical levels.",
    "- `bioinformatics_msc_stats_teaching_associations.csv` contains the association statistics used in the practical teaching examples.",
    "- `bioinformatics_msc_stats_mortality_comorbidity.csv` contains the linked risk prediction and mortality outcome table.",
    "",
    "## Cohort Size",
    paste0("- Participants: ", diagnostics$value[diagnostics$metric == "participants"]),
    paste0("- Visit rows: ", diagnostics$value[diagnostics$metric == "visit_rows"]),
    paste0("- Retention at 24 months: ", format_percent_text(100 * diagnostics$value[diagnostics$metric == "retention_24m"])),
    paste0("- Retention at 60 months: ", format_percent_text(100 * diagnostics$value[diagnostics$metric == "retention_60m"])),
    paste0("- Deaths over five years: ", format_percent_text(100 * diagnostics$value[diagnostics$metric == "mortality_5y_proportion"])),
    "",
    "## Teaching Association Statistics",
    render_teaching_association_lines(teaching_associations),
    "",
    "## Baseline Variable Summaries",
    render_variable_summary_lines(baseline_summaries),
    "",
    "## Visit Variable Summaries",
    render_variable_summary_lines(visit_summaries),
    "",
    "## Mortality And Comorbidity Variable Summaries",
    render_variable_summary_lines(mortality_summaries)
  )

  writeLines(lines, con = file.path(output_dir, "validation_summary.md"))
}

write_uk_calibration_notes <- function(output_dir, diagnostics) {
  fetch_value <- function(name, digits = 3) {
    sprintf(paste0("%.", digits, "f"), diagnostics$value[diagnostics$metric == name])
  }
  fetch_percent <- function(name, digits = 1) {
    sprintf(paste0("%.", digits, "f%%"), 100 * diagnostics$value[diagnostics$metric == name])
  }

  lines <- c(
    "# UK Calibration Notes",
    "",
    "This note records the main epidemiological choices used to calibrate the simulated cohort.",
    "The aim was not to recreate one named survey exactly, but to produce a plausible England-based teaching dataset with realistic prevalence levels and moderate, interpretable associations.",
    "Calibration diagnostics are calculated before the reproducible teaching mess is added; the distributed raw CSVs therefore require cleaning before their estimates are compared with this note.",
    "",
    "## Population frame",
    "- The age band has been extended to 50 to 90 years to support teaching on multimorbidity, frailty, mortality, death-censored visits, and longer follow-up.",
    "- The cohort is community-based rather than a strict NHS Health Check eligibility sample, so diagnosed hypertension, type 2 diabetes, chronic kidney disease, frailty, and previous cardiovascular disease are retained for teaching.",
    "- Several prevalences are therefore expected to be higher than all-age England figures because the simulated cohort is older and more cardiometabolic than the general adult population.",
    "",
    "## How the main variables were tuned",
    paste0("- Smoking was kept close to modern England levels at ", fetch_percent("current_smoker_proportion"), ", with a deprivation gradient rather than random allocation."),
    paste0("- Inactivity was kept close to national levels at ", fetch_percent("inactive_proportion"), ", and linked to higher resting heart rate and slightly worse weight trajectories."),
    paste0("- Obesity was tuned to ", fetch_percent("obesity_proportion"), " and linked to fasting glucose, prediabetes, type 2 diabetes, blood pressure, and central adiposity."),
    paste0("- Measured hypertension was tuned to ", fetch_percent("measured_hypertension_proportion"), " and diagnosed hypertension to ", fetch_percent("diagnosed_hypertension_proportion"), ", with age and adiposity contributing more than smoking alone."),
    paste0("- Prediabetes was tuned to ", fetch_percent("prediabetes_proportion"), " and type 2 diabetes to ", fetch_percent("type2_diabetes_proportion"), ", with higher risks in more deprived groups, those with obesity, and those with family history."),
    paste0("- Raised total cholesterol was tuned to ", fetch_percent("raised_cholesterol_proportion"), " and paired with total:HDL ratio so lipid summaries can be used in regression and CVD-risk style teaching."),
    paste0("- Longstanding condition prevalence was tuned to ", fetch_percent("longstanding_condition_proportion"), " and linked to self-rated health, multimorbidity, frailty, hospital admission, and mortality."),
    paste0("- Five-year mortality was tuned to ", fetch_percent("mortality_5y_proportion"), " with risk increasing by age, male sex, smoking, CKD, COPD, dementia, previous cardiovascular disease, care-home residence, multimorbidity, and frailty."),
    "",
    "## Association map used when iterating the simulation",
    paste0("- Older age increases systolic blood pressure and hypertension risk. Final age vs systolic blood pressure correlation: ", fetch_value("corr_age_sbp"), "."),
    paste0("- Higher BMI increases fasting glucose and glycaemic risk. Final BMI vs fasting glucose correlation: ", fetch_value("corr_bmi_glucose"), "."),
    paste0("- Obesity raises prediabetes risk but not so strongly that the data feel engineered. Final obesity vs prediabetes odds ratio: ", fetch_value("or_obesity_prediabetes"), "."),
    paste0("- More weekly exercise is associated with lower resting heart rate. Final exercise vs resting heart rate correlation: ", fetch_value("corr_exercise_heart_rate"), "."),
    paste0("- HDL is inversely related to triglycerides as expected in routine lipid data. Final HDL vs triglycerides correlation: ", fetch_value("corr_hdl_triglycerides"), "."),
    paste0("- Current smoking is associated with higher CRP and only a modest increase in diagnosed hypertension. Final smoking vs hypertension odds ratio: ", fetch_value("or_current_smoker_hypertension"), "; smoker vs never-smoker median CRP ratio: ", fetch_value("median_crp_ratio_current_vs_never"), "."),
    paste0("- Deprivation raises diabetes risk without making IMD dominate the whole dataset. Final type 2 diabetes prevalence difference between IMD quintile 5 and 1: ", fetch_value("imd_diabetes_difference"), "."),
    paste0("- Ethnicity is linked to glycaemic risk in a broad UK-consistent direction. Final prediabetes prevalence ratio for Asian or Black participants vs White, Mixed, or Other participants: ", fetch_value("ethnic_prediabetes_ratio"), "."),
    paste0("- Blood group was deliberately kept close to null for glycaemic outcomes. Final blood group vs prediabetes p-value: ", fetch_value("blood_group_vs_prediabetes_pvalue"), "."),
    paste0("- Mortality risk increases with age and multimorbidity. Final age vs predicted five-year mortality risk correlation: ", fetch_value("corr_age_mortality_risk"), "; multimorbidity vs predicted mortality risk correlation: ", fetch_value("corr_multimorbidity_mortality_risk"), "."),
    "",
    "## Main sources used for calibration",
    "- NHS Health Check age band and programme context: <https://www.nhs.uk/conditions/nhs-health-check/nhs-health-check/>",
    "- Health Survey for England 2024 overview: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024>",
    "- Health Survey for England 2024 adults' health-related behaviours: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-health-related-behaviours>",
    "- Health Survey for England 2024 adults' health: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-health>",
    "- Health Survey for England 2024 adults' overweight and obesity: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2024/adults-overweight-and-obesity>",
    "- Health Survey for England 2022 adults' health-related behaviours for the smoking-by-deprivation pattern: <https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england/2022-part-1/adults-health-related-behaviours>",
    "- Quality and Outcomes Framework 2024-25 for GP-recorded hypertension and obesity prevalence: <https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2024-25>",
    "- Diabetes profile statistical commentary, March 2025, for England type 2 diabetes prevalence: <https://www.gov.uk/government/statistics/diabetes-profile-update-march-2025/diabetes-profile-statistical-commentary-march-2025>",
    "- NHS England release on non-diabetic hyperglycaemia: <https://www.england.nhs.uk/2024/06/nhs-identifies-over-half-a-million-more-people-at-risk-of-type-2-diabetes-in-a-year/>",
    "- NHS Blood and Transplant donor blood group frequencies: <https://www.blood.co.uk/why-give-blood/blood-types/>",
    "- Exercise and resting heart rate meta-analysis (Reimers et al., 2018): <https://pubmed.ncbi.nlm.nih.gov/30513777/>",
    "- Obesity and prediabetes meta-analysis (Amani-Beni et al., 2026): <https://pubmed.ncbi.nlm.nih.gov/41492061/>",
    "- Family history and type 2 diabetes risk in EPIC-InterAct: <https://pubmed.ncbi.nlm.nih.gov/23052052/>",
    "- Waist-to-height ratio and cardiometabolic risk meta-analysis: <https://pubmed.ncbi.nlm.nih.gov/24179379/>",
    "- UK evidence on ethnic differences in type 2 diabetes diagnosis profiles: <https://pubmed.ncbi.nlm.nih.gov/31923438/>",
    "- QRISK3 risk calculator fields, including total cholesterol:HDL ratio: <https://www.qrisk.org/index.php>",
    "- Office for National Statistics life tables and mortality publications for age-patterned mortality: <https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/lifeexpectancies>",
    "- NHS England frailty and older people resources: <https://www.england.nhs.uk/ourwork/clinical-policy/older-people/frailty/>",
    "",
    "## Teaching caveat",
    "- This is teaching data, not a synthetic copy of a protected NHS dataset. The goal is plausible structure, not exact prevalence reproduction for any single survey year or local authority."
  )
  writeLines(lines, con = file.path(output_dir, "uk_calibration_notes.md"))
}

write_cleaning_documentation <- function(output_dir, issues, baseline, visits, mortality_table) {
  utils::write.csv(
    issues,
    file = file.path(output_dir, "data_cleaning_issue_key.csv"),
    row.names = FALSE,
    na = ""
  )

  student_lines <- c(
    "# Data Cleaning Practical: Student Brief",
    "",
    "The three cohort CSV files are deliberately raw and contain a small number of planted data-quality problems.",
    "Your task is to detect, document, and repair them reproducibly before carrying out statistical analysis.",
    "Do not edit the CSVs manually: import them, preserve the raw objects, and create cleaned objects in R.",
    "",
    "## Files To Audit",
    "- `bioinformatics_msc_stats_baseline.csv`: one row should represent one participant.",
    "- `bioinformatics_msc_stats_visits.csv`: one row should represent one participant at one visit.",
    "- `bioinformatics_msc_stats_mortality_comorbidity.csv`: one row should represent one participant.",
    "- `bioinformatics_msc_stats_codebook.csv`: use the documented levels, units, ranges, and meanings as validation rules.",
    "",
    "## Minimum Checks",
    "1. Confirm the number of rows and columns and inspect inferred data types.",
    "2. Test the expected keys for missing values and duplicates.",
    "3. List every distinct value and frequency for categorical variables.",
    "4. Repeat categorical checks after trimming whitespace and converting text to a common case.",
    "5. Compare numeric minima and maxima with the codebook and with subject-matter plausibility.",
    "6. Cross-check redundant information, such as visit number versus visit label and months since baseline.",
    "7. Check that variables repeated across linked tables agree for the same participant.",
    "8. Produce a cleaning log containing table, row/key, variable, original value, cleaned value, and rule.",
    "",
    "## Suggested R Tools",
    "- Base R: `unique()`, `table()`, `duplicated()`, `trimws()`, `tolower()`, `range()`, and `merge()`.",
    "- Tidyverse alternatives: `count()`, `distinct()`, `str_trim()`, `str_to_lower()`, `case_when()`, `anti_join()`, and `pivot_wider()`.",
    "",
    "## Expected Deliverables",
    "- Cleaned versions of all three data tables.",
    "- A reproducible cleaning script.",
    "- A cleaning log and a short paragraph explaining which checks found each class of problem.",
    "- A final validation showing unique keys, intended categorical levels, and plausible numeric ranges.",
    "",
    "## Important Note",
    "The ordinary missing values in selected laboratory and questionnaire variables are part of the cohort design, not necessarily data-entry mistakes. Distinguish missing-data handling from correction of invalid entries."
  )
  writeLines(student_lines, con = file.path(output_dir, "data_cleaning_student_brief.md"))

  file_name <- c(
    baseline = "bioinformatics_msc_stats_baseline.csv",
    visits = "bioinformatics_msc_stats_visits.csv",
    mortality_comorbidity = "bioinformatics_msc_stats_mortality_comorbidity.csv"
  )
  issue_counts <- as.data.frame(table(issues$table_name, issues$issue_type), stringsAsFactors = FALSE)
  issue_counts <- issue_counts[issue_counts$Freq > 0, ]
  count_lines <- apply(issue_counts, 1, function(row) {
    paste0("- `", file_name[[row[[1]]]], "`: ", as.integer(row[[3]]), " × ", row[[2]])
  })

  location_lines <- vapply(seq_len(nrow(issues)), function(i) {
    visit_text <- if (is.na(issues$visit_number[[i]])) "—" else as.character(issues$visit_number[[i]])
    paste0(
      "| ", issues$issue_id[[i]],
      " | `", file_name[[issues$table_name[[i]]]], "`",
      " | ", issues$csv_row[[i]],
      " | `", issues$participant_id[[i]], "`",
      " | ", visit_text,
      " | `", issues$variable_name[[i]], "`",
      " | ", issues$issue_type[[i]],
      " | `", issues$messy_value_visible[[i]], "`",
      " | `", visible_value(issues$intended_value[[i]]), "` |"
    )
  }, character(1))

  instructor_lines <- c(
    "# Data Cleaning Practical: Instructor Key",
    "",
    "This document is the complete answer key for the deliberately planted mess.",
    "CSV row numbers include the header as row 1, matching spreadsheet-style row numbering.",
    "The middle-dot character (`·`) in the display column represents an ordinary space, making leading or trailing whitespace visible.",
    "The machine-readable `data_cleaning_issue_key.csv` retains the exact raw and intended strings.",
    "",
    "## Scope",
    paste0("- Planted issue records: ", nrow(issues), "."),
    paste0("- Baseline rows after mess: ", nrow(baseline), "."),
    paste0("- Visit rows after mess: ", nrow(visits), " (includes ", sum(issues$issue_type == "exact duplicate row"), " deliberately duplicated rows)."),
    paste0("- Mortality/comorbidity rows after mess: ", nrow(mortality_table), "."),
    "- Ordinary simulated missingness is not listed as a planted error.",
    "",
    "## Issue Counts",
    count_lines,
    "",
    "## Exact Locations And Corrections",
    "| Issue | File | CSV row | Participant | Visit | Variable | Type | Messy value (spaces shown as ·) | Intended value |",
    "| --- | --- | ---: | --- | ---: | --- | --- | --- | --- |",
    location_lines,
    "",
    "## Recommended Debrief",
    "- Start with frequency tables to reveal misspellings and inconsistent case.",
    "- Show why `trimws()` should precede recoding: a trailing space can create a visually deceptive extra factor level.",
    "- Use codebook-driven assertions for numeric ranges rather than deleting all statistical outliers automatically.",
    "- Identify duplicate visit records with both `duplicated()` on full rows and duplicated `participant_id` + `visit_number` keys.",
    "- Preserve a raw object, apply transformations in code, and finish with assertions that fail if dirty values remain.",
    "- Discuss the difference between a true but extreme value, an impossible value, and a value that is merely unusual."
  )
  writeLines(instructor_lines, con = file.path(output_dir, "data_cleaning_instructor_key.md"))
}

simulate_candidate <- function(n, seed) {
  baseline <- simulate_baseline_complete(n = n, seed = seed)
  visits <- simulate_visits(baseline$complete, seed = seed)
  diagnostics <- evaluate_dataset(baseline$observed, visits)
  list(
    baseline = baseline$observed,
    visits = visits,
    diagnostics = diagnostics
  )
}

select_dataset <- function(n, master_seed, max_attempts = 40) {
  best <- NULL
  best_penalty <- Inf
  best_seed <- NA_integer_

  for (attempt in seq_len(max_attempts)) {
    candidate_seed <- master_seed + attempt - 1L
    candidate <- simulate_candidate(n = n, seed = candidate_seed)
    total_penalty <- sum(candidate$diagnostics$penalty, na.rm = TRUE)

    if (total_penalty < best_penalty) {
      best <- candidate
      best_penalty <- total_penalty
      best_seed <- candidate_seed
    }

    if (best_penalty <= 0.10) {
      break
    }
  }

  list(
    baseline = best$baseline,
    visits = best$visits,
    diagnostics = best$diagnostics,
    selected_seed = best_seed,
    total_penalty = best_penalty
  )
}

resolve_script_path <- function() {
  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", cmd_args, value = TRUE)
  if (length(file_arg) > 0) {
    raw_path <- sub("^--file=", "", file_arg[[1]])
    raw_path <- gsub("~\\+~", " ", raw_path)
    return(normalizePath(raw_path, winslash = "/", mustWork = FALSE))
  }

  frame_paths <- Filter(
    Negate(is.null),
    lapply(sys.frames(), function(frame) frame$ofile)
  )
  if (length(frame_paths) > 0) {
    return(normalizePath(frame_paths[[length(frame_paths)]], winslash = "/", mustWork = FALSE))
  }

  NA_character_
}

write_outputs <- function(output_dir, selected, master_seed, script_path = NA_character_) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }

  mortality_clean <- build_mortality_comorbidity_table(selected$baseline)
  messy <- apply_teaching_mess(
    baseline = selected$baseline,
    visits = selected$visits,
    mortality = mortality_clean
  )
  baseline <- messy$baseline
  visits <- messy$visits
  mortality_comorbidity <- messy$mortality_comorbidity
  issues <- messy$issues

  utils::write.csv(
    baseline,
    file = file.path(output_dir, "bioinformatics_msc_stats_baseline.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    visits,
    file = file.path(output_dir, "bioinformatics_msc_stats_visits.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    mortality_comorbidity,
    file = file.path(output_dir, "bioinformatics_msc_stats_mortality_comorbidity.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    build_codebook(),
    file = file.path(output_dir, "bioinformatics_msc_stats_codebook.csv"),
    row.names = FALSE
  )
  utils::write.csv(
    selected$diagnostics,
    file = file.path(output_dir, "bioinformatics_msc_stats_diagnostics.csv"),
    row.names = FALSE
  )

  metadata <- data.frame(
    master_seed = master_seed,
    selected_seed = selected$selected_seed,
    total_penalty = selected$total_penalty,
    participants = nrow(baseline),
    visit_rows = nrow(visits),
    visit_rows_before_planted_duplicates = nrow(selected$visits),
    visit_rows_distributed = nrow(visits),
    planted_issue_records = nrow(issues),
    planted_duplicate_visit_rows = sum(issues$issue_type == "exact duplicate row"),
    stringsAsFactors = FALSE
  )
  utils::write.csv(
    metadata,
    file = file.path(output_dir, "generation_metadata.csv"),
    row.names = FALSE
  )
  output_script_path <- file.path(output_dir, "simulate_intro_stats_dataset.R")
  same_script_path <- !is.na(script_path) &&
    normalizePath(script_path, winslash = "/", mustWork = FALSE) ==
      normalizePath(output_script_path, winslash = "/", mustWork = FALSE)
  if (!is.na(script_path) && file.exists(script_path) && !same_script_path) {
    copy_ok <- file.copy(
      from = script_path,
      to = output_script_path,
      overwrite = TRUE
    )
    if (!isTRUE(copy_ok)) {
      stop(paste("Could not copy the generator script to", output_script_path))
    }
  } else if (is.na(script_path) || !file.exists(script_path)) {
    warning("The generator script path could not be resolved, so no script copy was written.")
  }

  write_readme(
    output_dir = output_dir,
    baseline = baseline,
    visits = visits,
    diagnostics = selected$diagnostics,
    selected_seed = selected$selected_seed,
    master_seed = master_seed,
    issue_count = nrow(issues)
  )
  write_validation_summary(
    output_dir = output_dir,
    baseline = baseline,
    visits = visits,
    mortality_table = mortality_comorbidity,
    diagnostics = selected$diagnostics
  )
  write_mortality_comorbidity_report(
    output_dir = output_dir,
    mortality_table = mortality_comorbidity,
    diagnostics = selected$diagnostics
  )
  write_uk_calibration_notes(output_dir = output_dir, diagnostics = selected$diagnostics)
  write_cleaning_documentation(
    output_dir = output_dir,
    issues = issues,
    baseline = baseline,
    visits = visits,
    mortality_table = mortality_comorbidity
  )
  invisible(list(
    participants = nrow(baseline),
    visit_rows = nrow(visits),
    issue_count = nrow(issues)
  ))
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  output_dir <- if (length(args) >= 1) args[[1]] else file.path(getwd(), "intro_stats_simulated_dataset")
  n <- if (length(args) >= 2) as.integer(args[[2]]) else 2400L
  master_seed <- if (length(args) >= 3) as.integer(args[[3]]) else 20260420L
  script_path <- resolve_script_path()

  selected <- select_dataset(n = n, master_seed = master_seed, max_attempts = 60)
  written <- write_outputs(
    output_dir = output_dir,
    selected = selected,
    master_seed = master_seed,
    script_path = script_path
  )

  cat("Output directory:", normalizePath(output_dir, winslash = "/", mustWork = FALSE), "\n")
  cat("Participants:", written$participants, "\n")
  cat("Visit rows distributed:", written$visit_rows, "\n")
  cat("Planted issue records:", written$issue_count, "\n")
  cat("Selected seed:", selected$selected_seed, "\n")
  cat("Total penalty:", sprintf("%.4f", selected$total_penalty), "\n")
}

if (sys.nframe() == 0) {
  main()
}
