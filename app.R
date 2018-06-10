library(shiny)
library(shinychecklist)
library(googlesheets)
## create a google sheet
#checklist_data <- gs_new("checklist", ws_title = "repro-checklist",
 #                   trim = TRUE, verbose = FALSE)

# Define the storage type
store <- list(type = STORAGE_TYPES$GOOGLE_SHEETS,
              path = "responses",
              url = "https://docs.google.com/spreadsheets/d/1bXnkNtxVWcWXzhb-SPTNWP30VKiVydVL9Gre811adAc/edit#gid=0")

## render questions from yaml
questions <- yaml::read_yaml("test.yaml")
lapply(seq_along(questions), function(x) {
  questions[[x]]$type = "checkbox"
  questions[[x]]$id = paste0("question",x)
  return(questions[[x]])
}) -> questions

## create form
basicInfoForm <- list(
  id = "checklist",
  questions = questions,
  storage = store,
  name = "repro-checklist",
  password = "shinychecklist",
  reset = TRUE)



### UI and server
ui <- fluidPage(
  titlePanel("Reproducibility Checklist"),
      tabsetPanel(
        tabPanel("Checklist",
            formUI(formInfo = basicInfoForm)
        ),
        tabPanel("Results",
                 DT::dataTableOutput('table')
        )
      )
)


server <- function(input, output, session) {
  formServer(basicInfoForm)

  output$table <- DT::renderDataTable({
    DT::datatable(
      loadData(basicInfoForm$storage), rownames = FALSE,
      options = list(searching = FALSE, lengthChange = FALSE, scrollX = TRUE)
    )
  })
  }

## App
shinyApp(ui = ui, server = server)
