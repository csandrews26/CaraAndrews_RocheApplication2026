# -------------------------------------------------------------------------
# Program: create_adsl.R
# Name: ADSL
# Label: Subject Level Analysis Dataset
# Description: Create ADSL (Subject Level) dataset
# Inputs: pharmaverse::dm, ds, ex, ae, vs
# Output: adsl
# Creator: Cara Andrews
# Template Script: admiral::use_ad_template("ADSL")

# r setup -----------------------------------------------------------------
## Load libraries
library(admiral)
library(dplyr, warn.conflicts = FALSE)
library(pharmaversesdtm)
library(lubridate)
library(stringr)

## Load SDTM data
dm <- pharmaversesdtm::dm
ds <- pharmaversesdtm::ds
ex <- pharmaversesdtm::ex
ae <- pharmaversesdtm::ae
vs <- pharmaversesdtm::vs

# Assign base ADSL as DM --------------------------------------------------
adsl <- dm %>%
  select(-DOMAIN)

# Define functions --------------------------------------------------------
## Age group 9 - AGEGR9 
format_agegr9 <- function(x) {
  case_when(
    x < 18 ~ "<18",
    between(x, 18, 50) ~ "18-50",
    x > 50 ~ ">50",
    TRUE ~ "Missing"
  )
}

## Age group 9 no. - AGEGR9N 
format_agegr9n <- function(x) {
  case_when(
    x < 18 ~ 1,
    between(x, 18, 50) ~ 2,
    x > 50 ~ 3,
    TRUE ~ NA_integer_
  )
}

## Race group 1 - RACEGR1
format_racegr1 <- function(x) {
  case_when(
    x == "WHITE" ~ "White",
    x != "WHITE" ~ "Non-white",
    TRUE ~ "Missing"
  )
}

## Age group 1 - AGEGR1
format_agegr1 <- function(x) {
  case_when(
    x < 18 ~ "<18",
    between(x, 18, 64) ~ "18-64",
    x > 64 ~ ">64",
    TRUE ~ "Missing"
  )
}

## Region grouping - REGION1
format_region1 <- function(x) {
  case_when(
    x %in% c("CAN", "USA") ~ "NA",
    !is.na(x) ~ "RoW",
    TRUE ~ "Missing"
  )
}

## Number of days from last dose grouping - LDDTHGR1
format_lddthgr1 <- function(x) {
  case_when(
    x <= 30 ~ "<= 30",
    x > 30 ~ "> 30",
    TRUE ~ NA_character_
  )
}

## End of study status mapping - EOSSTT 
format_eosstt <- function(x) {
  case_when(
    x %in% c("COMPLETED") ~ "COMPLETED",
    x %in% c("SCREEN FAILURE") ~ NA_character_,
    !is.na(x) ~ "DISCONTINUED",
    TRUE ~ "ONGOING"
  )
}

# Treatment start date and end date variables -----------------------------
# Start and end datetime of exposure using EX
ex_ext <- ex %>%
  # Start date/time
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST"
  ) %>%
  # End date/time
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

# Add treatment start date and end date variables to adsl
adsl <- adsl %>%
  ## derive treatment variables (TRT01P, TRT01A) 
  mutate(TRT01P = ARM, TRT01A = ACTARM) %>%
  ## derive treatment start date (TRTSDTM) 
  derive_vars_merged(
    dataset_add = ex_ext,
    # filter for only valid dose
    filter_add = (EXDOSE > 0 |
                    (EXDOSE == 0 &
                       str_detect(EXTRT, "PLACEBO"))) &
      !is.na(EXSTDTM),
    # rename variables to TRTSDTM and TRTSTMF
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  ## derive treatment end date (TRTEDTM) 
  derive_vars_merged(
    dataset_add = ex_ext,
    # filter for valid dose
    filter_add = (EXDOSE > 0 |
                    (EXDOSE == 0 &
                       str_detect(EXTRT, "PLACEBO"))) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  ## Derive treatment end/start date TRTSDT/TRTEDT 
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>% 
  ## derive treatment duration (TRTDURD) ----
  derive_var_trtdurd()


# Disposition dates, status -----------------------------------------------
# Convert character date to numeric date without imputation
ds_ext <- derive_vars_dt(
  ds,
  dtc = DSSTDTC,
  new_vars_prefix = "DSST"
)

adsl <- adsl %>%
  ## Screen fail date - SCRFDT
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(SCRFDT = DSSTDT),
    filter_add = DSCAT == "DISPOSITION EVENT" & DSDECOD == "SCREEN FAILURE"
  ) %>%
  ## End of study date - EOSDT
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(EOSDT = DSSTDT),
    filter_add = DSCAT == "DISPOSITION EVENT" & DSDECOD != "SCREEN FAILURE"
  ) %>%
  ## End of study status - EOSSTT
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = DSCAT == "DISPOSITION EVENT",
    new_vars = exprs(EOSSTT = format_eosstt(DSDECOD)),
    missing_values = exprs(EOSSTT = "ONGOING")
  ) %>%
  ## Last retrieval date- FRVDT
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(FRVDT = DSSTDT),
    filter_add = DSCAT == "OTHER EVENT" & DSDECOD == "FINAL RETRIEVAL VISIT"
  ) %>%
  ## Randomization Date - RANDDT
  derive_vars_merged(
    dataset_add = ds_ext,
    filter_add = DSDECOD == "RANDOMIZED",
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(RANDDT = DSSTDT)
  ) %>%
  ## Death date - DTHDTC
  derive_vars_dt(
    new_vars_prefix = "DTH",
    dtc = DTHDTC,
    highest_imputation = "M",
    date_imputation = "first"
  ) %>%
  ## Relative Day of Death - DTHADY
  derive_vars_duration(
    new_var = DTHADY,
    start_date = TRTSDT,
    end_date = DTHDT
  ) %>%
  ## Elapsed Days from Last Dose to Death - LDDTHELD
  derive_vars_duration(
    new_var = LDDTHELD,
    start_date = TRTEDT,
    end_date = DTHDT,
    add_one = FALSE
  ) %>%
  ## Cause of Death (DTHCAUS) and Traceability Variable (DTHDOM)
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      event(
        dataset_name = "ae",
        condition = AEOUT == "FATAL",
        set_values_to = exprs(DTHCAUS = AEDECOD, DTHDOM = DOMAIN),
      ),
      event(
        dataset_name = "ds",
        condition = DSDECOD == "DEATH" & grepl("DEATH DUE TO", DSTERM),
        set_values_to = exprs(DTHCAUS = DSTERM, DTHDOM = DOMAIN),
      )
    ),
    source_datasets = list(ae = ae, ds = ds),
    tmp_event_nr_var = event_nr,
    order = exprs(event_nr),
    mode = "first",
    new_vars = exprs(DTHCAUS = DTHCAUS, DTHDOM = DTHDOM)
  ) %>%
  ## Death Cause Category - DTHCGR1
  mutate(DTHCGR1 = case_when(
    is.na(DTHDOM) ~ NA_character_,
    DTHDOM == "AE" ~ "ADVERSE EVENT",
    str_detect(DTHCAUS, "(PROGRESSIVE DISEASE|DISEASE RELAPSE)") ~ "PROGRESSIVE DISEASE",
    TRUE ~ "OTHER"
  ))

# Derive ABNSBPFL (supine systolic blood pressure <100 or >=140 mm) -------
adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    false_value = "N",
    missing_value = "N",
    condition = ((VSTESTCD == "SYSBP" & VSSTRESU == "mmHg") & 
                   (VSSTRESN >=140 | VSSTRESN < 100))
  )

# Derive remaining variables ----------------------------------------------

adsl <- adsl %>%
  ## Derive last documented known alive date - LSTALVDT ----
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      ### Last complete date of vital assessment with a valid test result
      event(
        dataset_name = "vs",
        order = exprs(VSDTC, VSSEQ),
        condition = !is.na(VSSTRESN) & !is.na(VSSTRESC) & !is.na(VSDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC, highest_imputation = "M"),
          seq = VSSEQ
        ),
      ),
      ### Last complete onset date of AEs - AESTDTC
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC, AESEQ),
        condition = !is.na(AESTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC, highest_imputation = "M"),
          seq = AESEQ
        ),
      ),
      ### Last complete disposition date - DSSTDTC
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC, DSSEQ),
        condition = !is.na(DSSTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC, highest_imputation = "M"),
          seq = DSSEQ
        ),
      ),
      ### Last date of treatment administration (valid dose) - TRTEDTM
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDTM),
        set_values_to = exprs(LSTALVDT = TRTEDTM, seq = NA_integer_),
      )
    ),
    source_datasets = list(vs = vs, ae = ae, ds = ds, adsl = adsl),
    tmp_event_nr_var = event_nr,
    order = exprs(LSTALVDT, seq, event_nr),
    mode = "last",
    new_vars = exprs(LSTALVDT)
  ) %>%
  ## Derive cardiac disorder flag - CARPOPFL ----
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    false_value = NA_character_,
    missing_value = NA_character_,
    condition = (toupper(AESOC) == "CARDIAC DISORDERS")
  ) %>%
  ## Derive safety flag - SAFFL
  derive_var_merged_exist_flag(
    dataset_add = ex,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = SAFFL,
    false_value = "N",
    missing_value = "N",
    condition = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO")))
  ) %>%
  ## Groupings and others variables ----
  mutate(
    RACEGR1 = format_racegr1(RACE),
    AGEGR1 = format_agegr1(AGE),
    AGEGR9 = format_agegr9(AGE), # add AGEGR9 derivation using function
    AGEGR9N = format_agegr9n(AGE), # add AGEGR9N derivation using function
    REGION1 = format_region1(COUNTRY),
    LDDTHGR1 = format_lddthgr1(LDDTHELD),
    DTH30FL = if_else(LDDTHGR1 == "<= 30", "Y", NA_character_),
    DTHA30FL = if_else(LDDTHGR1 == "> 30", "Y", NA_character_),
    DTHB30FL = if_else(DTHDT <= TRTSDT + 30, "Y", NA_character_),
    # Define ITTFL flag
    ITTFL = if_else(!is.na(ARM), "Y", "N")
  )

# Here you could cross reference with the metadata to select the variables needed
# e.g. link to DAP M3

# Save output ----
# Change to whichever directory you want to save the dataset in
dir <- tools::R_user_dir("admiral_templates_data", which = "cache")
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(adsl, file = file.path(dir, "adsl.rda"), compress = "bzip2")

## Save to personal area --------------------------------------------------
# dir <- "~/CaraAndrews_RocheApplication2026/question_3_adam"
# save(adsl, file = file.path(dir, "adsl.rda"), compress = "bzip2")

