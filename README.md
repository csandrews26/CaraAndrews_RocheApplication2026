# CaraAndrews_RocheApplication2026

This repository contains solutions to the tasks assigned in DSX_Data_Scientist_Coding_Assessment. <br />
**Click on each dropdown to view the corresponding repository folder, files, and implementation details.** <br />

> *Note: Each dropdown also details the approach taken and challenges faced for each task.* <br />

# 

<details>
  <summary>Question 1: Descriptive Statistics</summary>

  ## question_1_descriptive_stats/descriptiveStats

  This folder contains the source code and documentation for the <code>{descriptiveStats}</code> R package.

**Files:**

- <code>R/</code> : R source files for each exported function in the package and non-exported (<code>utils.R</code>), used to validate input data, integrated across multiple functions.
- <code>man/</code> : Documentation files for each exported function, created using <code>devtools::document()</code> and <code>{roxygen2}</code>.
- <code>tests/testthat/</code> : Unit tests created with <code>{testthat}</code> and executed via <code>devtools::test()</code>. 
- <code>DESCRIPTION</code> : Package metadata (title, authors, dependencies, license)
- <code>NAMESPACE</code> : States exported functions and any dependency packages, controlled via <code>{roxygen2}</code>. 

### Installation
```ruby
# Install devtools
install.packages("devtools")

# Install the package from GitHub
devtools::install_github(
  "csandrews26/CaraAndrews_RocheApplication2026",
  subdir = "question_1_descriptive_stats/descriptiveStats"
)

# Load library
library(descriptiveStats)

# Example data
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Calculate measures of central tendency
calc_mean(data) # 4.3
calc_median(data) # 4.5
calc_mode(data) # 5

# Calculate measures of spread
calc_q1(data) # 2.25
calc_q3(data) # 5
calc_iqr(data) # 2.75
```
### Approach

1) Installed required development packages: <code>{devtools}</code>, <code>{roxygen2}</code>, <code>{testthat}</code> and <code>{usethis}</code>
2) Created base package structure by running <code>usethis::createpackage("descriptiveStats")</code>. This created the framework below:
  ```ruby
descriptiveStats/
  ├── DESCRIPTION       # package metadata
├── NAMESPACE         # export/import declarations (managed by roxygen2)
├── R/                # R source files 
  └── descriptiveStats.Rproj
```
3) Modified the <code>DESCRIPTION</code> file to include key package metadata.
4) Added MIT license with <code>usethis::use_mit_license()</code>.
5) Created R scripts for each of the specified functions, using <code>{roxygen2}</code>.
    * Created <code>utils.R</code> helper function that could apply standard data input checks for all functions
    * Six statistical functions created with <code>na.rm</code> parameter for handling <code>NA</code> values
7) Generated <code>.Rd</code> files for each function and updated <code>NAMESPACE</code> using <code>devtools::document</code>.
8) Set up testing with <code>usethis::use_testthat()</code> and wrote test scripts to verify functions operated correctly, this included:
    * Correct outputs for valid inputs
    * <code>NA</code> handling
    * Correctly flagging erros for invalid inputs 
9) Executed tests with <code>devtools::test()</code>.
10) Executed <code>devtools::check()</code> to run R CMD check and resolve all errors and warnings.
11) Performed user testing - installing the package in from the GitHub and executing manual tests.

### Challenges

* **Nested package structure:** The package was nested within an existing Git repository, causing <code>usethis</code> to issue warnings. Resolved by specifying the full target path in <code>usethis::create_package()</code>.

* **Working directory mismatch:** <code>devtools::document()</code> failed with "could not find package root" because the working directory was set to the repository root. Fixed by specifying the package path to all <code>devtools</code> functions (e.g., <code>devtools::document("question_1_descriptive_stats/descriptiveStats")</code>).

* **License file validation:** <code>R CMD check</code> flagged "Invalid license file pointers" because the <code>LICENSE</code> file location was incorrect. Resolved by moving the <code>LICENSE</code> file manually.

* **<code>calc_mode()</code> ignoring NAs:** Manual testing revealed initial implementation used <code>table(x)</code>, which silently drops <code>NA</code> values even when <code>na.rm = FALSE</code>. Fixed by adding <code>useNA = "ifany"</code> to include <code>NA</code> in frequency counts, then checking if <code>NA</code> is the modal value.

* **Function conflicts:** Functions existed in both the global environment and the package namespace, causing conflicts. Resolved by clearing global functions and only using functions from <code>devtools::load_all()</code>.

* **User-friendly error messages:** Implemented error handling in quartile functions to provide clear guidance when <code>NA</code> values are present with <code>na.rm = FALSE</code>, rather than relying on generic R errors.

* **Incorrect package name in tests:** <code>tests/testthat.R</code> auto-generated with the repository name instead of the package name, causing test failures. Fixed by manually editing to <code>library(descriptiveStats)</code> and <code>test_check("descriptiveStats")</code>.

<br />
</details>
  
  <details>
  <summary>Quesion 2: SDTM DS Domain Creation using `{sdtm.oak}`</summary>
  
  ## question_2_sdtm

This folder contains the R script and metadata for creating the Subject Disposition (DS) SDTM domain.
  
 **Files:**
  
- <code>02_create_ds_domain.R</code> : R script for producing the DS domain using <code>{pharmaverseraw}</code>, <code>{pharmaversesdtm}</code>, <code>{sdtm.oak}</code> and <code>{dplyr}</code>.
- <code>sdtm_ct.csv</code> : Controlled terminology file for CDISC variable mapping.

### Approach

1) Installed and loaded required packages: <code>{sdtm.oak}</code>, <code>{pharmaverseraw}</code>, <code>{pharmaversesdtm}</code> and <code>{dplyr}</code>
2) Loaded input datasets: <code>pharmaverseraw::ds_raw</code> (raw DS data) and <code>pharmaversesdtm::dm</code> (Demographics data for study day derivations)
3) Read in controlled terminology csv downloaded from [GitHub](https://github.com/pharmaverse/examples/blob/main/metadata/sdtm_ct.csv)
4) Generated oak ID variables with <code>generate_oak_id_vars()</code> to link raw and SDTM records, for traceability.
5) Mapped SDTM variables using <code>{sdtm.oak}</code> functions:
    * <code>assign_ct()</code> for controlled terminology mappings (DSDECOD)
    * <code>assign_no_ct()</code> for direct mappings (DSTERM)
    * <code>hardcode_no_cut()</code> hardcode consistent values (DSCAT based on DSDECOD)
    * <code>assign_datetime()</code> for ISO 8601 datetime conversion (DSSTDTC, DSDTC)
6) Mapping "Other Specify" records sepearately, with reference to [aCRF](https://github.com/pharmaverse/pharmaverseraw/blob/main/vignettes/articles/aCRFs/Subject_Disposition_aCRF.pdf), before combining with standard values.
7) Derived <code>DSSEQ</code> (sequence numbers) and <code>DSDY</code> (study days relative to <code>RFXSTDTC</code>)
8) Selected final DS variables from SDTMIG specifications.

### Challenges

* **Limited <code>{sdtm.oak}</code> experience:** This was my first time using <code>{sdtm.oak}</code>, which required studying the package documentation and pharmaverse examples to understand the <code>condition_add()</code>, <code>assign_ct()</code>, and <code>oak_id_vars()</code> workflow.

* **Conditional logic for DSCAT:** Implemented multi-step logic where DSCAT depends on DSDECOD value ("Randomized" → "PROTOCOL MILESTONE", otherwise → "DISPOSITION EVENT", unless OTHERSP populated → "OTHER EVENT"). Solved by using separate processing for each condition and combining with <code>bind_rows()</code>.

* **OTHERSP handling:** "Other specify" records required different mappings (DSDECOD ← OTHERSP rather than controlled terminology). Addressed by deriving in multuple steps - <code>condition_add(ds_raw, !is.na(OTHERSP))</code> and merging results.

* **Datetime assembly:** DSDTC required combining date (DSDTCOL) and time (DSTMCOL) columns. Solved using <code>assign_datetime()</code> with concatenation before conversion.

<br />
</details>
  
  <details>
  <summary>Question 3: ADaM ADSL Dataset Creation</summary>
  
  ## question_3_adam

  This folder contains the R script and output dataset for creating an ADaM Subject-Level Analysis Dataset (ADSL).
  
  **Files:**
  
- <code>create_adsl.R</code> : R script for producing ADSL using <code>{admiral}</code>, <code>{pharmaversesdtm}</code>, <code>{lubridate}</code>, <code>{dplyr}</code> and <code>{stringr}</code> packages. 
- <code>adsl.rda</code> : The final exported ADSL dataset.

### Approach

1) Loaded <code>{admiral}</code> ADSL template with <code>admiral::use_ad_template("ADSL")</code>.
2) Modified template following provided specifications. Modifications included:
    - Created age groups (i.e. AGEGR9, AGEGR9N)
    - Imputed treatment start datetime (TRTSDTM)
    - Derived supine systolic blood pressure flag (ABNSBPFL)
    - Derived last documented known alive date (LSTALVDT)
    - Derived cardiac disorder flag (CARPOPFL)
    - Added intent-to-treat population flag (ITTFL)
3) Exported final ADSL as an R data file (<code>adsl.rda</code>)

### Challenges

* **Datetime imputation rules:** Specification required imputing missing time components to <code>00:00:00</code> but suppressing the imputation flag when only seconds were missing. Implemented using <code>highest_imputation = "h"</code> and relying on <code>admiral >= 1.4.0</code> default <code>ignore_seconds_flag = TRUE</code>.

* **TRTSTMF flag derivation:** Needed to map imputation flags from <code>derive_vars_dtm()</code> to the TRTSTMF variable while correctly handling partially missing times. Resolved using <code>derive_vars_merged()</code> to merge the imputation flag from the exposure dataset.

* **Age group categorical derivation:** Explored <code>derive_vars_cat()</code> from <code>{admiral}</code> for simultaneous derivation of AGEGR9 and AGEGR9N, but ultimately used a custom functions with embedded <code>case_when()</code> to derive both AGEGR9 and AGEGR9N from AGE.

* **Lack of Metadata Specification:** Without a DAP M3 specification file to verify final variable attributes, the final ADSL lacks descriptive labels and formats. Manual labelling was bypassed as it is inefficient and notn scalable. In a standard workflow, these attributes would be applied in the progam using <code>{metatools}</code>.

<br />
</details>
  
  <details>
  <summary>Quesion 4: TLG - Adverse Events Reporting</summary>
  
  ## question_4_tlg
  
  This folder contains R scripts and outputs for adverse event reporting tables and visualisation.

  **Files:**
  
- <code>01_create_ae_summary_table.R</code> : R script for producing the AE summary table, using <code>{pharmaverseadam}</code>, <code>{dplyr}</code>, <code>{gtsummary}</code> and <code>{gt}</code>.
- <code>ae_summary_table.html</code> : Summary table output for <code>01_create_ae_summary_table.R</code> (AESOC > AETERM hierarchy with frequencies by treatment arm).

- <code>02_create_visualisations.R</code> : R script for producing three different outputs, using <code>{pharmaverseadam}</code>, <code>{dplyr}</code>, <code>{ggplot2}</code> and <code>{gt}</code>.
- <code>plot_1.png</code> : Stacked bar chart for AE severity distribution by treatment arm.
- <code>plot_2.png</code> : Forest plot for top 10 most frequent AEs with 95% Clopper-Pearson confidence intervals for incidence rates.
- <code>ae_listings.html</code> : Patient-level AE listing created using <code>{gt}</code>.

### Approach

**AE Summary Table:**
1. Filtered ADAE to safety population (SAFFL == "Y") and treatment-emergent AEs (TRTEMFL == "Y")
2. Created hierarchical table with <code>gtsummary::tbl_hierarchical()</code> using AESOC > AETERM structure
3. Sorted by descending frequency using <code>sort_hierarchical()</code>
4. Split the columns by treatment arm (ACTARM) and added overall row 
5. Exported to HTML with <code>gt::gtsave()</code>

**Visualisations:**
1. **AE Severity Distribution:**
   - Created stacked bar chart with <code>geom_bar(aes(fill = "AESEV"))</code>, showing proportions of MILD/MODERATE/SEVERE by treatment arm
   - Exported plot as PNG using <code>ggsave()</code>
3. **Top 10 AEs Forest Plot:**
   - Calculated incidence rates using <code>distinct(USUBJID, AETERM)</code> to ensure unique subjects per term
   - Computed Clopper-Pearson exact 95% CIs using <code>stats::qbeta()</code>
   - Ordered by frequency using <code>fct_reorder()</code>
   - Created forest plot with <code>geom_point()</code> and <code>geom_errorbarh()</code>
   - Exported plot as PNG using <code>ggsave()</code>
4. **AE Listing:**
   - Preprocessed ADAE data
       * Filtered ADAE to safety population (SAFFL == "Y") and treatment-emergent AEs (TRTEMFL == "Y")
       * Selected required variables for listing
       * Sorted data by subject and adverse event start date
   - Used <code>gt::gt()</code> with <code>groupname_col</code> for subject-level grouping
   - Exported plot as html using <code>gtsave()</code>

### Challenges

- **Hierarchical table sorting:** Initially attempted manual factor manipulation, but discovered <code>gtsummary::sort_hierarchical()</code> provides cleaner automatic sorting by frequency within each AESOC.

- **Unique subject counting:** Needed to ensure each subject was counted only once per AE term despite multiple occurrences. Solved with <code>distinct(USUBJID, AETERM)</code>.

- **Population denominator selection:** (re: Top 10 AEs Forect Plot) Followed task instructions and example outputs by using ADAE to define the total subject count (n_total); however, recognised that using <code>n_distinct(adsl$USUBJID)</code> would be the standard approach to represent the full study population rather than only those who experienced advsere events.

- **Listing tool selection:** Discovered <code>gtsummary::tbl_listing()</code> exists in the <code>{gtreg}</code> package (not base <code>{gtsummary}</code>), which provides better listing functionality than <code>gt::gt()</code> alone for patient-level data.

<br />
</details>
  
  <details>
  <summary>Question 5: Clinical Data API (FastAPI)</summary>
  
  ## question_5_api
  
  This folder contains the Python script for an API for querying adverse event data and calculating patient risk scores.
  
  **Files:**
  
- <code>main.py</code> : Python script for the generation of FastAPI 
- <code>adae.csv</code> : Adverse events dataset exported from <code>{pharmaverseadam}</code> in R

### Approach

1) Set up virtual environment in python by running terminal command <code>python3 -m venv venv</code>
2) Installed dependencies: <code>fastapi</code>, <code>uvicorn</code>, <code>pandas</code>
3) Exported <code>adae.csv</code> from R using <code>write_csv(pharmaverseadam::adae, "adae.csv")</code>
4) Implemented input validation (uppercase normalisation, valid column/value checks and error handling missing data)
6) Created API endpoints:
    - **GET /** - Returns welcome message, confirming API is running
    - **POST /** - Defines criteria for filtering AE records 
    - **GET /** - Calculates weighted risk score and assigns risk category for specified patient ID
7) Added error handling for missing subjects (404 response)
8) Tested using FastAPI's UI at <code>/docs</code>

### Challenges

- **Case sensitivity:** User inputs could be any case while dataset was uppercase. Solved by normalising both user input and dataset columns to uppercase.
  
- **Pydantic model validation:** Learned to use <code>Optional[List[str]]</code> for optional query parameters, defaults to <code>None</code>.

- **Input validation:** Added validation to check that treatment arms and severity values exist in the dataset before filtering, returning 400 errors with helpful messages for invalid inputs.

- **Risk score unique cases:** Handled subjects with no AEs (should return 0 score) and subjects not in dataset (404 error with clear message).

<br />
</details>

<details>
  <summary>Question 6: GenAI Clinical Data Assistant (Mock LLM)</summary>
  
  ## question_6_llm_agent

  This folder contains a mock LLM-powered agent that translates natural language questions into structured database queries.

**Files:**

- <code>agent.py</code> : Python script implementing <code>ClinicalTrialDataAgent</code> class with mock LLM
- <code>adae.csv</code> : Adverse events dataset (same as Question 5)
- <code>requirements.txt</code> : Python package dependencies

### Approach

> Note:
> This implementation uses a mock LLM (keyword matching) rather than OpenAI due to not having an API key. The code supports OpenAI integration by uncommenting imports and setting <code>use_real_llm=True</code>. A <code>.env</code> file containing the associated Open AI key is also required for successful implementation. 

1. Set up Python virtual environment and installed <code>pandas</code>
2. Copied <code>adae.csv</code> from Question 5
3. Implemented <code>ClinicalTrialDataAgent</code> class with:
   - **Schema Definition** - Documentation describing dataset columns (AESEV, AETERM, AESOC) for LLM context (only used by OpenAI)
   - **<code>__init__()</code>** - Initialises OpenAI if <code>use_real_llm=True</code> 
   - **<code>parse_question()</code>** - Routes to real LLM or mock based on parameter input
   - **<code>_call_real_llm()</code>** - Sends prompt to OpenAI API with schema + user question, forcing JSON response (not executed in current mock LLM implementation)
   - **<code>_mock_llm_response()</code>** - Searches question for dataset values using case-insensitive matching:
     - Checks if any AESEV value appears in question - returns <code>{"target_column": "AESEV", "filter_value": value}</code>
     - Checks if "severity" keyword present - defaults to MODERATE
     - Checks if any AETERM value appears - returns AETERM mapping
     - Checks if any AESOC keywords appear - returns AESOC mapping
     - Returns error if no match found, prompting user to rephrase
   - **<code>execute_query()</code>** - Filters <code>adae.csv</code> using parsed LLM output, returns subject count and IDs (unique USUBJID values)
   - **<code>ask()</code>** - Orchestrates full workflow: parse > execute > print results
4. Tested with three example questions covering severity, specific terms, and body systems

### Challenges

* **Mock LLM limitations:** Hard-coded keyword matching cannot handle synonyms, complex phrasing, or multi-condition queries. For example, a real LLM would be able to process "moderate intensity cardiac events" that requires both AESEV and AESOC filtering, which the mock cannot handle.

* **Mock LLM approach:** Improved initial mock LLM implementation from hard-coded keywords to searching actual dataset values, making the mock more realistic and maintainable. Now works with any AETERM/AESOC in the data without code changes.

* **Error handling:** Added fallback response when no match is found, returning an error message rather than silently returning incorrect results. 

* **Case normalisation:** Needed to normalise both user questions (to lowercase) and dataset values (to uppercase) while returning uppercase values for filtering. This involved temporary case change for cross-matching question to data.

* **Architecture design:** Structured code so real LLM and mock LLM share identical interfaces (<code>parse_question()</code> returns same JSON structure), enabling real AI implementation by changing one parameter.

<br />
</details>

# 

### Technical Reflection and Repository Evaluation

#### Project Management & Traceability

While this repository demonstrates technical execution (logical structure, comprehensive documentation, clear code comments, and descriptive commit histories), in future, I would implement the following industry-standard practices: 
- **Issue Tracking:** Utilising GitHub Issues to define specific task requirements, track progress, and document resolutions for each output.
- **Feature Branching Strategy:** Employing a branch-per-question model to isolate development for individual questions. This facilitates simplifies the peer-review (QC) process, and prevents the risk of code regression.

These practices align with workflows in the clinical environment where there is multi-programmer collaboration. Proper branch management and issue documentation minimise merge conflicts and ensure traceability for regulatory submissions.

#### Git & Infrastructure Challenges
- **OS Environment:** Managing OS-specific metadata (e.g., <code>.DS_Store</code>), highlighted the importance of maintaining a comprehensive <code>.gitignore</code>.
- **Package Architecture:** Integrating a formal R package structure within a nested repository required careful consideration of <code>.Rbuildignore</code> and <code>.gitignore</code> files, to ensure the wasn't unneccessary duplication of parent-directory metadata in the package.

#

> [!IMPORTANT]
> **AI Disclosure & Usage Statement** <br /> <br />
This technical assessment was completed with the support of Claude (Anthropic). This specific LLM was selected for its advanced proficiency in R programming, debugging, and interpreting complex error messages.
> The AI was utilised for metholodical purposes such as providing guides for approaching unfamiliar tasks (e.g. development of a GenAI assistant), code optimisation and assistance deciphering R-specific console errors.
> While AI was used to support the development process, all logic, statistical methods, and final outputs were independently verified, reviewed, and validated to ensure they meet CDISC standards and the specific requirements of the assessment. The final code reflects my own understanding and technical ability.
