# Hepatitis B Clinical Dashboard (R Shiny)

## Live Demo
Access the deployed dashboard here: https://buriro.shinyapps.io/dashboard

## Overview
This project transforms raw clinical data into an interactive, cloud-hosted R Shiny dashboard to support evidence-based decision-making in Hepatitis B care. The dashboard presents patient demographics, viral load patterns, liver function indicators, temporal trends, and correlation analyses to help clinicians and health program managers rapidly assess patient distributions and risk profiles.

## Key Features
- Interactive filters by gender and date range for dynamic exploration
- Patient demographics and registration trends over time
- Viral load and ALT (alanine aminotransferase) visualization with clinically relevant thresholds
- Log-transformation of skewed clinical variables to improve modelling and interpretability
- Correlation analysis between viral load and ALT
- Key Performance Indicators (KPIs) and risk stratification visualizations
- Deployed to shinyapps.io for cloud access

## Data Processing & Modelling
- Data cleaning and validation (date parsing, missing-value handling, de-duplication)
- Feature engineering for clinical metrics and temporal variables
- Log-transformation applied to right-skewed variables (e.g., viral load) to stabilise variance and make visual comparisons clearer
- Clinically informed thresholds (e.g., viral load cutoffs, ALT reference ranges) are overlaid in plots to support interpretation
- Correlation analysis (Pearson/Spearman as appropriate) between viral load and ALT to explore clinical associations

## Interactive UI & UX
- Filters: gender, registration / measurement date ranges, and other cohort selectors
- Time-series plots for registration and lab trends
- Distribution plots (histograms, density plots) and boxplots with log-scale options
- Scatter plots with regression/smoothing lines and correlation statistics
- KPIs displayed prominently (counts, proportions, median viral load, % above clinical thresholds)
- Tooltips and hover details for granular inspection

## Technical Stack
- R (>= 4.0)
- Shiny
- tidyverse (dplyr, tidyr, ggplot2)
- lubridate, scales
- plotly (interactive graphics) or ggplot2 + plotly bridging
- DT for interactive tables
- shinythemes / shinydashboard (UI layout)
- Deployment: shinyapps.io (cloud hosting)

## Installation (Run locally)
Prerequisites:
- R (recommended >= 4.0)
- RStudio (recommended)

Install required packages (example):
```r
install.packages(c(
  "shiny", "tidyverse", "lubridate", "plotly", "DT", "scales", "shinydashboard"
))
```

Run the app locally (from project root):
```r
# if the app is app.R
shiny::runApp("app.R", launch.browser = TRUE)

# or if server and ui are in an app folder
shiny::runApp("shiny-app/")
```

## Usage Notes & Interpretation
- Many clinical lab values are right-skewed; the dashboard offers log-scale transforms and displays back-transformed summaries where helpful.
- Thresholds used in visuals reflect commonly used clinical cutoffs—consult the code or data dictionary for exact values and modify to match local guidelines.
- Correlation plots provide Pearson or Spearman coefficients depending on data distribution; consider stratified analyses for subgroups.

## Deployment & Environment
- The app is deployed on shinyapps.io. Deployment considerations included:
  - Explicit package/version management
  - Environment variable handling for credentials
  - Resource limits (memory/CPU) on the shinyapps.io plan
- For reproducible deployments consider containerisation (Docker) or renv for package management.

## Project Structure
- /data/            # raw and processed (do not commit PHI)
- /R/ or /scripts/  # data cleaning and analysis scripts
- app.R             # main Shiny app (or ui.R + server.R)
- README.md

## License
MIT License — see LICENSE file for details.

## Contact
Project lead: buriro-ezekia | ezekia.buriro1810@gmail.com  
Live demo: https://buriro.shinyapps.io/dashboard

---

#DataScience #RStats #Shiny #HealthcareAnalytics #MachineLearning #DataVisualization #PublicHealth #Analytics #DigitalHealth #EvidenceBased
