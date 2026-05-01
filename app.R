library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)

# ---------------- LOAD DATA ----------------
data <- read.csv("DIAGNOSIS_RESULTS_CLEANED_ready.csv", stringsAsFactors = FALSE)

# ---------------- DATA CLEANING ----------------
data$REGN_DT <- as.POSIXct(data$REGN_DT, format = "%d-%b-%Y %H.%M.%S", tz = "UTC")
data$YearMonth <- floor_date(data$REGN_DT, "month")
data$GENDER <- factor(data$GENDER, labels = c("Male", "Female"))

data <- data %>% drop_na(VIRAL_LOAD_LOG, ALT_LEVEL, AGE)

# Clinical thresholds
high_viral_threshold <- log10(20000)
alt_threshold <- 40

# ---------------- UI ----------------
ui <- dashboardPage(
  
  dashboardHeader(title = "Hepatitis B Clinical Dashboard"),
  
  dashboardSidebar(
    selectInput("gender_filter", "Select Gender:",
                choices = c("All", "Male", "Female")),
    
    dateRangeInput("date_filter", "Select Date Range:",
                   start = min(data$REGN_DT),
                   end = max(data$REGN_DT))
  ),
  
  dashboardBody(
    
    fluidRow(
      valueBoxOutput("totalPatients"),
      valueBoxOutput("meanAge"),
      valueBoxOutput("highViral")
    ),
    
    tabsetPanel(
      
      tabPanel("Demographics",
               plotOutput("ageHist"),
               plotOutput("genderBar")),
      
      tabPanel("Viral Load",
               plotOutput("viralHist"),
               plotOutput("viralBox")),
      
      tabPanel("ALT Levels",
               plotOutput("altHist"),
               plotOutput("altBox")),
      
      tabPanel("Relationships",
               plotOutput("scatter1"),
               plotOutput("scatter2")),
      
      tabPanel("Temporal Trends",
               plotOutput("timeSeries"))
    )
  )
)

# ---------------- SERVER ----------------
server <- function(input, output) {
  
  # -------- FILTERED DATA --------
  filtered_data <- reactive({
    df <- data
    
    if (input$gender_filter != "All") {
      df <- df %>% filter(GENDER == input$gender_filter)
    }
    
    df <- df %>%
      filter(REGN_DT >= input$date_filter[1],
             REGN_DT <= input$date_filter[2])
    
    df
  })
  
  # -------- KPI BOXES --------
  output$totalPatients <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Patients", icon = icon("users"))
  })
  
  output$meanAge <- renderValueBox({
    valueBox(round(mean(filtered_data()$AGE), 1), "Mean Age", icon = icon("chart-bar"))
  })
  
  output$highViral <- renderValueBox({
    pct <- mean(filtered_data()$VIRAL_LOAD_LOG > high_viral_threshold) * 100
    valueBox(paste0(round(pct, 1), "%"), "High Viral Load", icon = icon("exclamation"))
  })
  
  # -------- DEMOGRAPHICS --------
  output$ageHist <- renderPlot({
    ggplot(filtered_data(), aes(x = AGE)) +
      geom_histogram(bins = 20, fill = "steelblue", colour = "white") +
      stat_bin(bins = 20, geom = "text",
               aes(label = ..count..), vjust = -0.5, size = 3) +
      theme_minimal() +
      labs(title = "Age Distribution")
  })
  
  output$genderBar <- renderPlot({
    ggplot(filtered_data(), aes(x = GENDER)) +
      geom_bar(fill = "darkgreen") +
      geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +
      theme_minimal() +
      labs(title = "Gender Distribution")
  })
  
  # -------- VIRAL LOAD --------
  output$viralHist <- renderPlot({
    ggplot(filtered_data(), aes(x = VIRAL_LOAD_LOG)) +
      geom_histogram(bins = 20, fill = "purple", colour = "white") +
      stat_bin(bins = 20, geom = "text",
               aes(label = ..count..), vjust = -0.5, size = 3) +
      geom_vline(xintercept = high_viral_threshold,
                 colour = "red", linetype = "dashed") +
      theme_minimal() +
      labs(title = "Viral Load Distribution (Log)")
  })
  
  output$viralBox <- renderPlot({
    ggplot(filtered_data(), aes(x = GENDER, y = VIRAL_LOAD_LOG)) +
      geom_boxplot(fill = "orange") +
      geom_hline(yintercept = high_viral_threshold,
                 colour = "red", linetype = "dashed") +
      theme_minimal() +
      labs(title = "Viral Load by Gender")
  })
  
  # -------- ALT --------
  output$altHist <- renderPlot({
    ggplot(filtered_data(), aes(x = ALT_LEVEL)) +
      geom_histogram(bins = 20, fill = "red", colour = "white") +
      stat_bin(bins = 20, geom = "text",
               aes(label = ..count..), vjust = -0.5, size = 3) +
      geom_vline(xintercept = alt_threshold,
                 colour = "blue", linetype = "dashed") +
      theme_minimal() +
      labs(title = "ALT Level Distribution")
  })
  
  output$altBox <- renderPlot({
    ggplot(filtered_data(), aes(x = cut(AGE, breaks = 5), y = ALT_LEVEL)) +
      geom_boxplot(fill = "cyan") +
      geom_hline(yintercept = alt_threshold,
                 colour = "blue", linetype = "dashed") +
      theme_minimal() +
      labs(title = "ALT by Age Group")
  })
  
  # -------- RELATIONSHIPS --------
  output$scatter1 <- renderPlot({
    ggplot(filtered_data(), aes(x = VIRAL_LOAD_LOG, y = ALT_LEVEL)) +
      geom_point(alpha = 0.6) +
      geom_smooth(method = "lm", colour = "blue") +
      geom_vline(xintercept = high_viral_threshold, linetype = "dashed", colour = "red") +
      geom_hline(yintercept = alt_threshold, linetype = "dashed", colour = "blue") +
      theme_minimal() +
      labs(title = "Viral Load vs ALT")
  })
  
  output$scatter2 <- renderPlot({
    ggplot(filtered_data(), aes(x = AGE, y = VIRAL_LOAD_LOG)) +
      geom_point(alpha = 0.6) +
      geom_smooth(method = "lm", colour = "green") +
      theme_minimal() +
      labs(title = "Age vs Viral Load")
  })
  
  # -------- TEMPORAL --------
  output$timeSeries <- renderPlot({
    
    trend_data <- filtered_data() %>%
      group_by(YearMonth) %>%
      summarise(count = n(), .groups = "drop")
    
    ggplot(trend_data, aes(x = YearMonth, y = count)) +
      geom_line(colour = "black") +
      geom_point() +
      theme_minimal() +
      labs(title = "Monthly Patient Registrations",
           x = "Time",
           y = "Number of Patients")
  })
}

# Run app
shinyApp(ui = ui, server = server)