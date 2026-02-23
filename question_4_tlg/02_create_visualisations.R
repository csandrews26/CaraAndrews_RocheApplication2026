# -------------------------------------------------------------------------
# Program: 02_create_visualizations.R
# Name: AE Summary Table
# Description: Create Visualizations using ggplot2
# Inputs: pharmaverseadam:: adae
# Output: PNG files (plot_1.png, plot_2.png) and ae_listings.html
# Creator: Cara Andrews

# r setup -----------------------------------------------------------------
## load libraries
library(pharmaverseadam)
library(dplyr)
library(ggplot2)
library(gtsummary)
library(gt)

## load data
adae <- pharmaverseadam::adae

# PLOT 1 ------------------------------------------------------------------
## AE severity distribution by treatment (bar chart or heatmap)
plot1 <- ggplot(adae, aes(ACTARM)) +
    # bar chart, fill colour indicates severity/intensity
    geom_bar(aes(fill=AESEV)) +
    # change colours
    scale_fill_brewer(palette="Set2") +
    # label axis and title
    labs(x = "Treatment Arm",
         y = "Count of AEs",
         title = "AE severity distribution by treatment")
  
## Export plot as png ----
ggsave(filename = "plot_1.png",
       plot = plot1,
       path = "~/CaraAndrews_RocheApplication2026/question_4_tlg/")

# PLOT 2 ------------------------------------------------------------------
# Top 10 most frequent AEs (with 95% CI for incidence rates)

## Pre-processing ----
### Number of Subjects
n_total <- n_distinct(adae$USUBJID)

ae_summary <- adae %>%
  # Unique subjects per AETERM
  distinct(USUBJID, AETERM) %>%
  count(AETERM, name = "n_subjects") %>%
  # Select top 10 by subject count
  slice_max(n_subjects, n = 10) %>%
  mutate(
    # Proportion of subjects with AETERM
    pct = n_subjects / n_total,
    # Clopper-Pearson exact 95% CI using the beta distribution
    ## Lower bound: qbeta(0.025, x, n - x + 1)
    ci_low  = qbeta(0.025, n_subjects, n_total - n_subjects + 1),
    ## Upper bound: qbeta(0.975, x + 1, n - x)
    ci_high = qbeta(0.975, n_subjects + 1, n_total - n_subjects),
    ## Convert to percentages for display
    pct     = pct     * 100,
    ci_low  = ci_low  * 100,
    ci_high = ci_high * 100,
    # Order AETERMs so highest frequency plots at the top
    AETERM  = forcats::fct_reorder(AETERM, pct)
  )

## Plot -----
plot2 <- ggplot(ae_summary, aes(x = pct, y = AETERM)) +
  geom_point(size = 3) +
  # Error bars for CIs
  geom_errorbarh(
    aes(xmin = ci_low, xmax = ci_high),
    height  = 0.3
  ) +
  # Labels for title and axis
  labs(
    title    = "Top 10 Most Frequent Adverse Events",
    subtitle = glue::glue("n = {n_total} subjects; 95% Clopper-Pearson CIs"),
    x        = "Percentage of Patients (%)",
    y        = NULL
  ) 

## Export plot as png ----
ggsave(filename = "plot_2.png",
       plot = plot2,
       path = "~/CaraAndrews_RocheApplication2026/question_4_tlg/")

# PLOT 3 ------------------------------------------------------------------
# AE listing using {gtsummary}
# USUBJID, ACTARM, AETERM, AESEV, AEREL, AESTDM, AENDTM

# Pre-processing -----
adae_listing <- adae %>%
  filter(
    SAFFL   == "Y",
    TRTEMFL == "Y"
  ) %>%
  # select required variables
  select(USUBJID, ACTARM, AETERM, AESEV, AEREL, AESTDTC, AEENDTC) %>%
  # sort by subject and event start date
  arrange(USUBJID, AESTDTC)

# Create listing ----
plot3 <- adae_listing %>% 
  gt(groupname_col = "USUBJID") %>%
  cols_label(
    USUBJID = "Unique Subject Identifier",
    ACTARM  = "Description of Actual Arm",
    AETERM  = "Reported Term for the Adverse Event",
    AESEV   = "Severity/Intensity",
    AEREL   = "Casuality",
    AESTDTC = "Start Date/Time of Adverse Event",
    AEENDTC = "End Date/Time of Adverse Event"
  ) %>%
  tab_stubhead(label = "Unique Subject Identifier") %>% 
  tab_header(title = "Listing of Treatment-Emergent Adverse Events by Subject",
             subtitle = "Excluding Screen Failue Patients") %>%
  tab_options(row_group.as_column = TRUE) 

# Export plot 3 as html
plot3 |>
  gtsave("ae_listings.html",
         path = "~/CaraAndrews_RocheApplication2026/question_4_tlg/")

