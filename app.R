library(shiny)
library(shinychecklist)

# Define the first form: basic information
store <- list(type = STORAGE_TYPES$FLATFILE, path = "responses")

questions <- yaml::read_yaml("test.yaml")

lapply(seq_along(questions), function(x) {
  questions[[x]]$type = "checkbox"
  questions[[x]]$id = paste0("question",x)
  return(questions[[x]])
}) -> questions

basicInfoForm <- list(
  id = "checklist",
  questions = questions,
  storage = store,
  name = "repro-checklist",
  password = "shinychecklist",
  reset = TRUE)



### UI and server
ui <- fluidPage(
  h1("Reproducibility Checklist"),
  mainPanel(
      "Reproducibility Checklist",
      formUI(basicInfoForm)
    )
  )

server <- function(input, output, session) {
  formServer(basicInfoForm)
  }

shinyApp(ui = ui, server = server)
