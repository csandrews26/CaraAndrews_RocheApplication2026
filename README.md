# CaraAndrews_RocheApplication2026

This repository is organised by the question tasks stated below.
* Question 1 : Descriptive Statistics
* Quesion 2 : SDTM DS Domain Creation using `{sdtm.oak}`
* Question 3 : ADaM ADSL Dataset Creation
* Quesion 4 :  TLG - Adverse Events Reporting
* Question 5: Clinical Data API (FastAPI)

## Questions

Click on the drop down by each question to find out which repository folder corresponds to this task and what files it contains.

<details>
  <summary>Question 1</summary>
  
  ### question_1_descriptive_stats/descriptiveStats
  
  This folder consists of the documents and files used to build the R package <code>{descriptiveStats}</code>.

- <code>R/</code> contains the .R files for each function in the package. There is an additional function in this folder that is not exported (<code>utils.R</code>), used to screen invalid input data and integrated into multiple functions.
- <code>man/</code> contains the corresponding markdown files explaining each of the exported functions. These were created using <code>devtools::document()</code> and <code>{roxygen2}</code> notation in the .R files.
- <code>tests/testthat/</code> contains the code that tested the limitations of the functions, checking that they performed as expected. This was created using the <code>{testthat}</code> package and tests were run using <code>devtools::test()</code>.
- <code>DESCRIPTION</code> file contains key information about the package, including the title, authors, description, license files and Roxygen version.
- <code>NAMESPACE</code> lists all the exported functions from this package and any dependent packages (i.e. <code>stats::median</code> and <code>stats::quantile</code> were both used in functions within this package).

#### Installation
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

# Test data
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Calculate mean, median and mode
calc_mean(data) # 4.3
calc_median(data) # 4.5
calc_mode(data) # 5

# Calculate quartiles and interquartile range
calc_q1(data) # 2.25
calc_q3(data) # 5
calc_iqr(data) # 2.75
```
#### Approach

1) Installed and loaded the packages required: <code>{devtools}</code>, <code>{roxygen2}</code>, <code>{testthat}</code> and <code>{usethis}</code>
  2) Created the basic package structure by running <code>usethis::createpackage("descriptiveStats")</code>. This created the framework below:
  ```ruby
descriptiveStats/
  ├── DESCRIPTION       # package metadata
├── NAMESPACE         # export/import declarations (managed by roxygen2)
├── R/                # R source files 
  └── descriptiveStats.Rproj
```
3) Modified the <code>DESCRIPTION</code> file to include key package metadata.
4) Created a MIT <code>LICENSE</code> file with <code>usethis::use_mit_license()</code>.
5) Created the R scripts for each of the specified functions, using <code>{roxygen2}</code> formatting. Started with a helper function (not-exported) that could apply standard data input checks for all functions. 
6) Generated .md files for each function using <code>devtools::document</code>. This also rewrote the <code>NAMESPACE</code> file to include all exported and required functions.
7) Set up testthat with <code>usethis::use_testthat()</code> and created test scripts to verify functions operated correctly.
8) Executed tests with <code>devtools::test()</code>.
9) After all tests were completed successfully, <code>devtools::check()</code> was run to complete CMD checks.
10) User testing - loading the package in from the GitHub repository and executing manual tests.

#### Challenges

* Encountered errors in relation to the package being nested within an existing repository:
  *  To override an error, the exact target path had to be specified in <code>usethis::create_package()</code>.
*  There were issues with running <code>devtools::document()</code>, as the package root was not the same as the working directory and could not be found. This was also resolved by specifying the target path.
*  CMD checks flagged issues with incorrect location of the <code>LICENSE</code> in the repository, and could not be found until it was moved manually.
*  Manual testing identified issues with the <code>calc_mode()</code> function ignoring <code>NA</code> values in the input vector. This was rectified by adding the argument <code>useNA = "ifany"</code> into the frequency count table within the function.
* Conflict betwen different versions of functions in the R session at the same time - the global environment and <code>devtools::load_all()</code>. This was resolved by clearing the environment.
* Incorporating error handling within the quartile functions that accounted for when NA values were present in the vector input when <code>na.rm = FALSE</code>. A user-friendly error was incorporated into the function to help identify input issues instead of a generic system error.
* CMD checks indicated that the <code>testthat.R</code> file was loading an incorrect package name (the repository <code>'CaraAndrews_RocheApplication2026'</code>) instead of <code>'descriptiveStats'</code>.

</details>
  
  <details>
  <summary>Question 2</summary>
  
  ### question_2_sdtm
  
  This folder contains 2 files:
  
  - <code>02_create_ds_domain.R</code> : The R script for producing a Subject Disposition (DS) SDTM dataset using <code>{pharmaverseraw}</code>, <code>{pharmaversesdtm}</code>, <code>{sdtm.oak}</code> and <code>{dplyr}</code> packages.
- <code>sdtm_ct.csv</code> : Controlled terminology for this study, used to map variables correctly.

#### Approach
1) Installed and loaded the packages required: <code>{sdtm.oak}</code>, <code>{pharmaverseraw}</code>, <code>{pharmaversesdtm}</code> and <code>{dplyr}</code>
2) Loaded input data <code>pharmaverseraw::ds_raw</code> and <code>pharmaversesdtm::dm</code>
3) Read in controlled terminology csv downloaded from [GitHub](https://github.com/pharmaverse/examples/blob/main/metadata/sdtm_ct.csv)
4) Generated oak_id, topic and remaining variables with reference to the [aCRF](https://github.com/pharmaverse/pharmaverseraw/blob/main/vignettes/articles/aCRFs/Subject_Disposition_aCRF.pdf) and [CDISC SDTM Implementation Guide](https://www.cdisc.org/standards/foundational/sdtmig/sdtmig-v3-4)

#### Challenges
* The main challenge with this task was inexperience using <code>{sdtm.oak}</code>

</details>
  
  <details>
  <summary>Question 3</summary>
  
  ### question_3_adam
  
  This folder contains 2 files:
  
  - <code>create_adsl.R</code> : The R script for producing a Subject Level Analysis Dataset (ADSL) ADaM using <code>{admiral}</code>, <code>{pharmaversesdtm}</code>, <code>{lubridate}</code>, <code>{dplyr}</code> and <code>{stringr}</code> packages. For this script, I began by loading an admiral template (<code>admiral::use_ad_template("ADSL")</code>) which I then modified according to the specification provided.
- <code>adsl.rda</code> : The final exported ADSL dataset — output from <code>create_adsl.R</code>.

#### Approach

#### Challenges

</details>
  
  <details>
  <summary>Question 4</summary>
  
  ### question_4_tlg
  
  This folder contains 2 R scripts and 4 outputs produced by them:
  
  - <code>01_create_ae_summary_table.R</code> : R script for producing the AE summary table, using the packages <code>{pharmaverseadam}</code>, <code>{dplyr}</code>, <code>{gtsummary}</code> and <code>{gt}</code>.
- <code>ae_summary_table.html</code> : Output from <code>01_create_ae_summary_table.R</code> — a gtsummary table saved as an HTML file.

- <code>02_create_visualisations.R</code> : R script for producing 3 different outputs, using the packages <code>{pharmaverseadam}</code>, <code>{dplyr}</code>, <code>{ggplot2}</code> and <code>{gt}</code>.
- <code>plot_1.png</code> : AE severity distribution by treatment (bar chart), created using <code>{ggplot2}</code>, saved as a PNG.
- <code>plot_2.png</code> : Top 10 most frequent AEs with 95% CI for incidence rates, created using <code>{ggplot2}</code>, saved as a PNG.
- <code>ae_listings.html</code> : AE listing created using <code>{gt}</code>, saved as an HTML file.

#### Approach

#### Challenges

</details>
  
  <details>
  <summary>Question 5</summary>
  
  ### question_5_api
  
  This folder contains 3 files:
  
  - <code>main.py</code> : Python script for the generation of FastAPI 
- <code>adae.csv</code> : .csv file containing the ADAE dataset from the <code>{pharmaverseadam}</code> R package. This file was exported as a .csv file by running a separate R script.
- <code>_pycashe_</code> : unkown

#### Approach

#### Challenges

</details>
  
