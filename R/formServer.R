
#' Create server for shiny checklist
#'
#' @param formInfo form info list
#' @export
#'
formServer <- function(formInfo) {
  callModule(formServerHelper, formInfo$id, formInfo)
}

formServerHelper <- function(input, output, session, formInfo) {
  if (grepl("\\s", formInfo$id)) {
    stop("Form id cannot have any spaces", call. = FALSE)
  }

  if (formInfo$storage$type == STORAGE_TYPES$FLATFILE) {
    if (!dir.exists(formInfo$storage$path)) {
      dir.create(formInfo$storage$path, showWarnings = FALSE)
    }
  }

  questions <- formInfo$questions

  fieldsMandatory <- Filter(function(x) {!is.null(x$mandatory) && x$mandatory }, questions)
  fieldsMandatory <- unlist(lapply(fieldsMandatory, function(x) { x$id }))
  fieldsAll <- unlist(lapply(questions, function(x) { x$id }))

  observe({
    mandatoryFilled <-
      vapply(fieldsMandatory,
             function(x) {
               !is.null(input[[x]]) && input[[x]] != ""
             },
             logical(1))
    mandatoryFilled <- all(mandatoryFilled)

    shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
  })

  observeEvent(input$reset, {
    shinyjs::reset("form")
    shinyjs::hide("error")
  })

  # When the Submit button is clicked, submit the response
  observeEvent(input$submit, {

    # User-experience stuff
    shinyjs::disable("submit")
    shinyjs::show("submit_msg")
    shinyjs::hide("error")
    on.exit({
      shinyjs::enable("submit")
      shinyjs::hide("submit_msg")
    })

    if (!is.null(formInfo$validations)) {
      errors <- unlist(lapply(
        formInfo$validations, function(validation) {
          if (!eval(parse(text = validation$condition))) {
            return(validation$message)
          } else {
            return()
          }
        }
      ))
      if (length(errors) > 0) {
        shinyjs::show(id = "error", anim = TRUE, animType = "fade")
        if (length(errors) == 1) {
          shinyjs::html("error_msg", errors[1])
        } else {
          errors <- c("", errors)
          shinyjs::html("error_msg", paste(errors, collapse = "<br>&bull; "))
        }
        return()
      }
    }

    # Save the data (show an error message in case of error)
    tryCatch({
      saveData(formData(), formInfo$storage)
      shinyjs::reset("form")
      shinyjs::hide("form")
      shinyjs::show("thankyou_msg")
    },
    error = function(err) {
      shinyjs::logjs(err)
      shinyjs::html("error_msg", err$message)
      shinyjs::show(id = "error", anim = TRUE, animType = "fade")
    })

  })

  if (!is.null(formInfo$multiple) && !formInfo$multiple) {
    submitMultiple <- FALSE
    shinyjs::hide("submit_another")
  } else {
    submitMultiple <- TRUE
  }
  observeEvent(input$submit_another, {
    if (!submitMultiple) {
      return()
    }
    shinyjs::show("form")
    shinyjs::hide("thankyou_msg")
  })

  # Gather all the form inputs (and add timestamp)
  formData <- reactive({
    data <- sapply(fieldsAll, function(x) input[[x]])
    data <- c(data, timestamp = as.integer(Sys.time()))
    data <- t(data)
    data
  })

  output$responsesTable <- DT::renderDataTable({
    DT::datatable(
      loadData(formInfo$storage), rownames = FALSE,
      options = list(searching = FALSE, lengthChange = FALSE, scrollX = TRUE)
    )
  })

}
