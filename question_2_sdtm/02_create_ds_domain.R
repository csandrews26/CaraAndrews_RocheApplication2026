# -------------------------------------------------------------------------
# Program: 02_create_ds_domain.R
# Name: DS
# Label: Subject Disposition
# Description: Create Subject Disposition (DS) SDTM domain
# Inputs:pharmaverseraw::ds_raw, pharmaversesdtm::dm
# Output: ds
# Creator: Cara Andrews

# r setup -----------------------------------------------------------------
# Load libraries
library(sdtm.oak)
library(pharmaverseraw)
library(pharmaversesdtm)
library(dplyr)

# Read in input data
ds_raw <- pharmaverseraw::ds_raw
dm <- pharmaversesdtm::dm

# Create oak_id vars ------------------------------------------------------
ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

# Read in study ct --------------------------------------------------------
study_ct <- read.csv("~/CaraAndrews_RocheApplication2026/Question_2/sdtm_ct.csv")

# Derive topic variable -----------------------------------------------------
ds_mapped <-
  # Map DSDECOD to IT.DSDECOD via CT codelist C66727, when OTHERSP is null
  assign_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP) | OTHERSP == ""),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727"
  ) %>%
  # Retain only records where DSDECOD was collected and CT-mapped
  dplyr::filter(!is.na(.data$DSDECOD))

# Map DSTERM --------------------------------------------------------------
# DSTERM mapped to IT.DSTERM when OTHERSP is null 
ds_mapped <- ds_mapped %>%
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP) | OTHERSP == ""),
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

# Map DSCAT ---------------------------------------------------------------
ds_mapped <- ds_mapped %>%
  # DSCAT = "PROTOCOL MILESTONE" when IT.DSDECOD == "Randomized" 
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw,
                            (is.na(OTHERSP) | OTHERSP == "") & IT.DSDECOD == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  ) %>% 
  # Map DSCAT = "DISPOSITION EVENT" when IT.DSDECOD != "Randomized"
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw,
                            (is.na(OTHERSP) | OTHERSP == "") & IT.DSDECOD != "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  )

# Mapping "Other Event" ---------------------------------------------------
ds_other <-
  # If OTHERSP is not null, map value in OTHERSP to DSDECOD
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP) & OTHERSP != ""),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD"
  ) %>%
  # Retain only records where the topic variable was collected
  dplyr::filter(!is.na(.data$DSDECOD)) %>% 
  # Map value in OTHERSP to DSTERM, when OTHERSP is not null
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP) & OTHERSP != ""),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>% 
  # DSCAT = "OTHER EVENT" when OTHERSP is not null
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP) & OTHERSP != ""),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  )

# Combine both dataframes -------------------------------------------------
ds_combined <- bind_rows(ds_mapped, ds_other)

# Map Datetimes in correct format -------------------------------------------
ds_combined <- ds_combined %>%
  # Map DSSTDTC <- IT.DSSDAT in ISO 8601 format
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("IT.DSSTDAT"),
    tgt_var = "DSSTDTC",
    raw_fmt = c(list(c("d-m-y", "dd-mmm-yyyy")))  
  ) %>% 
  # Map DSDTC from DSDTCOL (data) + DSTMCOL (time)
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c(list("dd-mmm-yyyy", "H:M"))
  )

# Map VISIT and VISITNUM --------------------------------------------------
# Map variables using 'INSTANCE' and study_ct and 
ds_combined <- ds_combined %>%
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )

# Derive remaining variables ----------------------------------------------
ds <- ds_combined %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,                          
    DOMAIN  = "DS",
    USUBJID = paste0("01-", ds_raw$patient_number),    
  ) %>%
  # Sort before sequence derivation: subject, then start date, then term
  dplyr::arrange(USUBJID, DSSTDTC, DSTERM) %>%
  # Derive DSSEQ: unique sequence number within each USUBJID
  derive_seq(
    tgt_var  = "DSSEQ",
    rec_vars = c("USUBJID")
  ) %>%
  # Derive DSSTDY: study day of DSSTDTC relative to first dose (RFSTDTC in DM)
  derive_study_day(
    sdtm_in       = .,
    dm_domain     = dm,
    tgdt          = "DSSTDTC",
    refdt         = "RFSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  # Select and order final DS variables per SDTMIG v3.4 DS specification
  dplyr::select(
    "STUDYID","DOMAIN", "USUBJID","DSSEQ", "DSTERM", "DSDECOD","DSCAT",  
    "VISITNUM","VISIT",  "DSDTC",  "DSSTDTC","DSSTDY")  
