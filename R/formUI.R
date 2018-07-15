inlineInput <- function(tag) {
  stopifnot(inherits(tag, "shiny.tag"))
  tagAppendAttributes(tag, style = "display: inline-block;")
}

#' Create UI for shiny checklist
#'
#' @param formInfo list with required information
#'
#' @export
formUI <- function(formInfo) {

  ns <- NS(formInfo$id)

  questions <- formInfo$questions

  fieldsMandatory <- Filter(function(x) { !is.null(x$mandatory) && x$mandatory }, questions)
  fieldsMandatory <- unlist(lapply(fieldsMandatory, function(x) { x$id }))

  titleElement <- NULL
  if (!is.null(formInfo$name)) {
    titleElement <- h3(formInfo$name)
  }

  responseText <- "Thank you, your response was submitted successfully."
  if (!is.null(formInfo$responseText)) {
    responseText <- formInfo$responseText
  }
  appCSS <- getappCSS()
  div(
    shinyjs::useShinyjs(),
    shinyjs::inlineCSS(appCSS),
    class = "shinyforms-ui",
    div(
      id = ns("form"),
      titleElement,
      div(
        class = "sf-questions",
        lapply(
          questions,
          function(question) {
            label <- question$title
            if (question$id %in% fieldsMandatory) {
              label <- labelMandatory(label)
            }

            if (question$type == "text") {
              input <- textInput(ns(question$id), NULL, "")
            } else if (question$type == "numeric") {
              input <- numericInput(ns(question$id), NULL, 0)
            } else if (question$type == "checkbox") {
              if (!(is.null(question$bold)) & question$bold == TRUE) {
                input <- checkboxInput(ns(question$id),
                                       div(class = "sf-question-bold", label),
                                       FALSE, width = "80%")
              } else {
                input <- checkboxInput(ns(question$id),
                                       div(class = "sf-question", label),
                                       FALSE, width = "80%")
              }

            }

            div(
              class = "sf-question",
              if (question$type != "checkbox") {
                tags$label(
                  `for` = ns(question$id),
                  class = "sf-input-label",
                  label,
                  if (!is.null(question$hint)) {
                    div(class = "question-hint", question$hint)
                  }
                )
              },
              input
            )
          }
        )
      ),
      actionButton(ns("submit"), "Submit", class = "btn-primary"),
      if (!is.null(formInfo$reset) && formInfo$reset) {
        actionButton(ns("reset"), "Reset")
      },
      shinyjs::hidden(
        span(id = ns("submit_msg"),
             class = "sf_submit_msg",
             "Submitting..."),
        div(class = "sf_error", id = ns("error"),
            div(tags$b(icon("exclamation-circle"), "Error: "),
                span(id = ns("error_msg")))
        )
      )
    ),
    shinyjs::hidden(
      div(
        id = ns("thankyou_msg"),
        class = "thankyou_msg",
        strong(responseText), br(),
        actionLink(ns("submit_another"), "Submit another response")
      )
    ),
    shinyjs::hidden(
      actionLink(ns("showhide"),
                 class = "showhide",
                 "Show responses")
    ),

    shinyjs::hidden(div(
      id = ns("answers"),
      class = "answers",
      div(
        class = "pw-box", id = ns("pw-box"),
        inlineInput(
          passwordInput(ns("adminpw"), NULL, placeholder = "Password")
        ),
        actionButton(ns("submitPw"), "Log in")
      ),
      shinyjs::hidden(div(id = ns("showAnswers"),
                          downloadButton(ns("downloadBtn"), "Download responses"),
                          DT::dataTableOutput(ns("responsesTable"))
      ))
    )),

    div(class = "created-by",
        "Created with",
        a(href = "https://github.com/vivekbhr/shinychecklist", "shinychecklist")
    )
  )
}
