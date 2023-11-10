# =============================================================================
# "Literature Review CSV Editor" using Shiny and shinyjs
# 
# Overview:
# This application enables users to interactively edit CSV files, specifically 
# geared towards literature review. The primary goal is to facilitate easier 
# data review and modifications with shortcut functionalities.
# 
# Key Features:
# 1. File Input: Users upload a CSV file containing literature data.
# 2. Dynamic Field Selection: Users can select which columns (fields) they want to edit.
# 3. Interactive Editing: Selected fields can be edited for each paper.
# 4. Keyboard Shortcuts: Enhances user experience by using:
#    - Enter: To save changes.
#    - 2: To navigate to the next paper.
#    - 3: To go back to the previous paper.
# 5. Navigation: Users can move to the next or previous paper and save changes.
# 6. Download: Allows users to download the modified CSV file.
# 
# Technical Aspects:
# - The application integrates 'shiny' for web app creation and 'shinyjs' for additional JavaScript functionalities.
# - Custom JavaScript (jsCode) is defined to capture keypress events and trigger corresponding Shiny actions.
# - Reactive values and observers are utilized for application state management based on user interactions.
# 
# Developer Information:
# Developed by Kshitij Dahal at Arizona State University.
# Email: kdahal3@asu.edu
# 
# Note: Always ensure to cite appropriately when using or disseminating apps.
# =============================================================================

# Libraries
library(shiny)
library(shinyjs)
# shiny: Used for building interactive web applications
# shinyjs: Extends shiny by allowing the use of JavaScript functions and events

# Settings
options(shiny.maxRequestSize = 300*1024^2) 
# Increasing the maximum request size will allow larger file uploads

# Custom JavaScript (jsCode) for keypress events and triggering Shiny actions
jsCode <- "
shinyjs.triggerClick = function(id) {
  $('#' + id).click();
};

shinyjs.init = function() {
  $(document).on('keydown', function(e) {
    if(e.which == 13) {
      shinyjs.triggerClick('submitChanges'); # Save Changes
    } else if(e.which == 50) {
      shinyjs.triggerClick('nextBtn');       # Next Paper
    } else if(e.which == 51) {
      shinyjs.triggerClick('prevBtn');       # Previous Paper
    }
  });
}"

# UI definition
litReviewUI <- fluidPage(
  useShinyjs(),
  extendShinyjs(text = jsCode, functions = c("triggerClick")),
  
  titlePanel("Literature Review CSV Editor"),
  tags$div(
    style = "margin-bottom: 20px;",
    tags$strong("Developed by: Kshitij Dahal, Arizona State University"),
    tags$br(),
    tags$strong("Email: "), tags$a(href = "mailto:kdahal3@asu.edu", "kdahal3@asu.edu"),
    tags$br(),
    tags$strong("Shortcuts: Save Changes - Enter, Next - 2, Previous - 3")
  ),
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose CSV File", accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      uiOutput("fieldCheckboxes"),
      actionButton("submitChanges", "Submit Changes"),
      actionButton("nextBtn", "Next Paper"),
      actionButton("prevBtn", "Previous Paper"),
      downloadButton("downloadData", "Download CSV"),
      textOutput("paperCounter")
    ),
    mainPanel(
      uiOutput("paperDetails")
    )
  )
)

# Server function definition
litReviewServer <- function(input, output, session) {
  
  data <- reactiveVal(NULL)
  current_index <- reactiveVal(1)
  # Reactive values to store the dataset and the current index of the paper being edited
  alwaysShownColumns <- c("Title", "Abstract")
  
  # Update dataset upon file upload
  observeEvent(input$file1, {
    df <- read.csv(input$file1$datapath)
    data(df)
    availableFields <- setdiff(names(df), alwaysShownColumns)
    output$fieldCheckboxes <- renderUI({
      checkboxGroupInput("selectedFields", "Select fields to edit:", choices = availableFields)
    })
  })
  
  # Update dataset with submitted changes
  observeEvent(input$submitChanges, {
    df <- data()
    for (field in input$selectedFields) {
      df[current_index(), field] <- input[[paste0("input_", field)]]
    }
    data(df)
    showModal(modalDialog(title = "Confirmation", "Changes saved successfully!", easyClose = TRUE))
  })
  
  # Render UI for paper details
  output$paperDetails <- renderUI({
    df <- data()
    if(is.null(df)) return(NULL)
    paper_data <- df[current_index(),]
    fieldsToShow <- c(alwaysShownColumns, input$selectedFields)
    
    fieldInputs <- lapply(fieldsToShow, function(field) {
      if(field == "Title") return(tags$h3(paper_data[[field]]))
      if(field == "Abstract") return(tags$textarea(paper_data[[field]], rows = 10, readonly = TRUE, style = "width:100%;"))
      textInput(inputId = paste0("input_", field), label = field, value = paper_data[[field]], width = "100%")
    })
    do.call(tagList, fieldInputs)
  })
  
  # Move to next paper
  observeEvent(input$nextBtn, {
    if (current_index() < nrow(data())) {
      current_index(current_index() + 1)
    } else {
      showModal(modalDialog(title = "End of Papers", "You have reached the last paper.", easyClose = TRUE))
    }
  })
  
  # Display current paper counter
  output$paperCounter <- renderText({ paste("Paper:", current_index(), "/", nrow(data())) })
  
  # Move to previous paper
  observeEvent(input$prevBtn, { if (current_index() > 1) current_index(current_index() - 1) })
  
  # Handle data download
  output$downloadData <- downloadHandler(
    filename = function() { "updated_data.csv" },
    content = function(con) { write.csv(data(), con, row.names = FALSE) }
  )
}

shinyApp(litReviewUI, litReviewServer)
# This line launches the Shiny app with the defined UI and server functionality
