# CaraAndrews_RocheApplication2026

This repository is organised by the question tasks stated below.
* Question 1 : Descriptive Statistics
* Quesion 2 : SDTM DS Domain Creation using `{sdtm.oak}`
* Question 3 : ADaM ADSL Dataset Creation
* Quesion 4 :  TLG - Adverse Events Reporting

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

#### Approach

</details>

<details>
<summary>Question 2</summary>

### question_2_sdtm

This folder contains 2 files:

- <code>02_create_ds_domain.R</code> : The R script for producing a Subject Disposition (DS) SDTM dataset using <code>{pharmaverseraw}</code>, <code>{pharmaversesdtm}</code>, <code>{sdtm.oak}</code> and <code>{dplyr}</code> packages.
- <code>sdtm_ct.csv</code> : Controlled terminology for this study, used to map variables correctly.

#### Approach

</details>

<details>
<summary>Question 3</summary>

### question_3_adam

This folder contains 2 files:

- <code>create_adsl.R</code> : The R script for producing a Subject Level Analysis Dataset (ADSL) ADaM using <code>{admiral}</code>, <code>{pharmaversesdtm}</code>, <code>{lubridate}</code>, <code>{dplyr}</code> and <code>{stringr}</code> packages. For this script, I began by loading an admiral template (<code>admiral::use_ad_template("ADSL")</code>) which I then modified according to the specification provided.
- <code>adsl.rda</code> : The final exported ADSL dataset — output from <code>create_adsl.R</code>.

#### Approach

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

</details>
