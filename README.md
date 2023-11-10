# Literature Review CSV Editor

## Overview
This application, developed using Shiny and shinyjs, is an interactive tool for editing CSV files, particularly tailored for literature reviews. Its primary goal is to make the data review and modification process easier and more efficient, with added functionalities like shortcut keys.

## Key Features
1. **File Input:** Users can upload a CSV file containing literature data.
2. **Dynamic Field Selection:** Enables selection of columns (fields) for editing.
3. **Interactive Editing:** Allows for direct editing of selected fields for each paper.
4. **Keyboard Shortcuts:** For improved user experience:
   - Enter: Save changes.
   - 2: Navigate to the next paper.
   - 3: Go back to the previous paper.
5. **Navigation:** Move between papers and save changes.
6. **Download:** Download the modified CSV file.

## Technical Aspects
- Integrates 'shiny' for web app creation and 'shinyjs' for JavaScript functionalities.
- Custom JavaScript (jsCode) captures keypress events to trigger corresponding Shiny actions.
- Uses reactive values and observers for managing application state based on user interactions.

## Developer Information
- **Developer:** Kshitij Dahal
- **Institution:** Arizona State University
- **Contact:** [kdahal3@asu.edu](mailto:kdahal3@asu.edu)

> **Note:** Ensure to cite appropriately when using or disseminating this application.

## Libraries Required
```R
library(shiny)
library(shinyjs)
