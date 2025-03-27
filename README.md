# COVID-19 Analysis in West Java and West Sumatra

Welcome to  **COVID-19 Analysis Dashboard** ! This project provides an in-depth analysis of COVID-19 data for West Java ( *Jawa Barat* ) and West Sumatra ( *Sumatera Barat* ). Using R, we analyze trends, cases, and other insights to better understand the impact of the pandemic in these regions.

## Project Status

🚧  **Status** : `Completed!`

## Features

Here's a breakdown of the analysis and visualizations included in this project:

* **Daily and Cumulative Case Analysis**
  * **Functionality:** Extract and visualize trends of daily and cumulative COVID-19 cases in both provinces.
  * **Visualization:** Line charts to track case progression over time.
* **Recovery and Death Rate Analysis**
  * **Functionality:** Compare recovery and death rates across different periods.
  * **Visualization:** Bar charts and time series plots showing fluctuations in recovery and fatality rates.
* **Moving Averages for COVID-19 Trends**
  * **Functionality:** Use rolling averages to smooth data trends and better understand long-term patterns.
  * **Visualization:** Moving average plots using *zoo* library.
* **Peak Infection Periods**
  * **Functionality:** Identify peak periods when COVID-19 cases spiked the most in each province.
  * **Visualization:** Highlighted trend lines showing peak periods.
* **Comparative Analysis Between West Java and West Sumatra**
  * **Functionality:** Compare COVID-19 cases, recovery, and death rates between the two regions.
  * **Visualization:** Dual-axis plots and side-by-side bar charts.

## Technologies

This project is built using R and leverages the following libraries:

* **httr** : A package for handling HTTP requests and fetching data from APIs.
* **dplyr** : A grammar of data manipulation for easy and efficient data transformation.
* **lubridate** : Provides functions to work with date-time objects.
* **tidyr** : Helps in data tidying, ensuring a clean dataset for analysis.
* **zoo** : Used for rolling averages and time series analysis.
* **ggplot2** : A powerful visualization library for creating insightful plots.
* **hrbrthemes** : Aesthetic themes for enhanced visualization clarity.

## Setup

To run this project, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/Bayhaqieee/Covid19_Analysis.git
   ```
2. Navigate to the project directory:
   ```bash
   cd covid19_analysis
   ```
3. Open RStudio and install required dependencies:
   ```r
   install.packages(c("httr", "dplyr", "lubridate", "tidyr", "zoo", "ggplot2", "hrbrthemes"))
   ```
4. Run the analysis script:
   ```r
   source("covid19_analysis.R")
   ```
5. Alternatively, you can run specific sections of the script by selecting and executing blocks of code.

## Live Visualization

For a more interactive experience, you can visualize the analysis through an R Shiny dashboard (if applicable) or export the plots as PNGs or PDFs for further use.

---

This project provides crucial insights into COVID-19 trends in West Java and West Sumatra, helping researchers and policymakers understand the pandemic’s impact in these regions. Feel free to contribute or modify the analysis to explore further trends!

📌 **Author:** Bayhaqie
📌 **Repository:** [GitHub](https://github.com/Bayhaqieee/Covid19_Analysis)
