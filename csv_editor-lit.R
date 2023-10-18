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


library(shiny)
library(shinyjs)

options(shiny.maxRequestSize = 300*1024^2) 


jsCode <- "
shinyjs.triggerClick = function(id) {
  $('#' + id).click();
};

shinyjs.init = function() {
  $(document).on('keydown', function(e) {
    if(e.which == 13) { // 1 for Save Changes
      shinyjs.triggerClick('submitChanges');
    } else if(e.which == 50) { // 2 for Next Paper
      shinyjs.triggerClick('nextBtn');
    } else if(e.which == 51) { // 3 for Previous Paper
      shinyjs.triggerClick('prevBtn');
    }
  });
}"



ui2 <- fluidPage(
  useShinyjs(), # Initialize shinyjs
  extendShinyjs(text = jsCode, functions = c("triggerClick")), # Load the custom JS
  
  titlePanel("Literature Review CSV Editor"),
  
  # Description and shortcuts
  tags$div(
    style = "margin-bottom: 20px;",
    tags$strong("Developed by:"),
    " Kshitij Dahal, Arizona State University",
    tags$br(),
    tags$strong("Email: "), tags$a(href = "mailto:kdahal3@asu.edu", "kdahal3@asu.edu"),
    tags$br(),
    tags$strong("Shortcuts: Save Changes - Enter, Next - 2, Previous - 3")
  ),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose CSV File",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")),
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

server2 <- function(input, output, session) {
  
  data <- reactiveVal(NULL)
  current_index <- reactiveVal(1)
  alwaysShownColumns <- c("Title", "Abstract")
  
  observeEvent(input$file1, {
    df <- read.csv(input$file1$datapath)
    data(df)
    
    # Update the checkbox group for the user to select which columns to display
    availableFields <- setdiff(names(df), alwaysShownColumns)
    output$fieldCheckboxes <- renderUI({
      checkboxGroupInput("selectedFields", "Select fields to edit:", choices = availableFields)
    })
  })
  
  observeEvent(input$submitChanges, {
    df <- data()
    for (field in input$selectedFields) {
      df[current_index(), field] <- input[[paste0("input_", field)]]
    }
    data(df)
  })
  
  showModal(modalDialog(
    title = "Confirmation",
    "Changes saved successfully!",
    easyClose = TRUE
  ))
  
  output$paperDetails <- renderUI({
    df <- data()
    
    if(is.null(df)) {
      return(NULL)
    }
    
    # Extract the details of the current paper
    paper_data <- df[current_index(),]
    
    # Fields to display
    fieldsToShow <- c(alwaysShownColumns, input$selectedFields)
    
    # Generate UI elements for each of the fields
    fieldInputs <- lapply(fieldsToShow, function(field) {
      if(field == "Title") {
        return(tags$h3(paper_data[[field]]))
      } else if(field == "Abstract") {
        return(tags$textarea(paper_data[[field]], rows = 10, readonly = TRUE, style = "width:100%;"))
      } else {
        #return(textInput(inputId = paste0("input_", field), label = field, value = paper_data[[field]]))
        textInput(inputId = paste0("input_", field), label = field, value = paper_data[[field]], width = "100%")
        
      }
    })
    
    do.call(tagList, fieldInputs)
  })
  
  observeEvent(input$submitChanges, {
    df <- data()
    for (field in input$selectedFields) {
      df[current_index(), field] <- input[[paste0("input_", field)]]
    }
    data(df)
  })
  
  observeEvent(input$nextBtn, {
    if (current_index() < nrow(data())) {
      current_index(current_index() + 1)
    } else {
      showModal(modalDialog(
        title = "End of Papers",
        "You have reached the last paper.",
        easyClose = TRUE
      ))
    }
  })
  
  output$paperCounter <- renderText({
    paste("Paper:", current_index(), "/", nrow(data()))
  })
  
  
  observeEvent(input$prevBtn, {
    if (current_index() > 1) {
      current_index(current_index() - 1)
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "updated_data.csv"
    },
    content = function(con) {
      write.csv(data(), con, row.names = FALSE)
    }
  )
}

shinyApp(ui2, server2)
