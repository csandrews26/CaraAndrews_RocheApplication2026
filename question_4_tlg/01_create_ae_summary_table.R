# -------------------------------------------------------------------------
# Program: 01_create_ae_summary_table.R
# Name: AE Summary Table
# Description: Create Adverse Events Summary Table
# Inputs: pharmaverseadam::adsl, pharmaverseadam:: adae
# Output: ae_summary_table.html
# Creator: Cara Andrews

# r setup -----------------------------------------------------------------
## load libraries
library(pharmaverseadam)
library(dplyr)
library(gtsummary)

## load data
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# Pre-processing --------------------------------------------
adae <- adae |>
  filter(
    ## safety population
    SAFFL == "Y",
    ## filter for treatment emergent adverse events
    TRTEMFL == "Y"
  ) 

# Define table layout -----------------------------------------------------
tbl <- adae |>
  tbl_hierarchical(
    ## split rows by AESOC and AETERM
    variables = c(AESOC, AETERM),
    ## Split colomns by ACTARM
    by = ACTARM,
    id = USUBJID,
    denominator = adsl,
    overall_row = TRUE,
    label = "..ard_hierarchical_overall.." ~ "Treatment Emergent AEs"
  ) |>
    ## Sort by descending frequency
  sort_hierarchical(
    sort = everything() ~ "descending"
  )

# View table -------------------------------------------------------------
tbl

# Export table as html file -----------------------------------------------
library(gt)

tbl |>
  as_gt() |>
  gtsave("ae_summary_table.html",
         path = "~/CaraAndrews_RocheApplication2026/question_4_tlg/")
