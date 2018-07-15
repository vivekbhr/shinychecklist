#' @export
STORAGE_TYPES <- list(
  FLATFILE = "flatfile",
  SQLITE = "sqlite",
  MYSQL = "mysql",
  MONGO = "mongo",
  GOOGLE_SHEETS = "gsheets",
  DROPBOX = "dropbox",
  AMAZON_S3 = "s3"
)


## render questions from yaml
#' @export

getquestions <- function(yaml) {
  questions <- yaml::read_yaml(yaml)
  questions <- lapply(seq_along(questions), function(x) {
                  if (is.null(questions[[x]]$type)) questions[[x]]$type = "checkbox"
                  questions[[x]]$id = paste0("question",x)
                  return(questions[[x]])
  })
  qtitles <- sapply(questions, function(x) return(x$qtitle))
  return(list(questions = questions, qtitles = qtitles))
}


labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

getappCSS <- function(){
  appCSS = "
.shinyforms-ui .mandatory_star { color: #db4437; font-size: 20px; line-height: 0; }
  .shinyforms-ui .sf-questions { margin-bottom: 30px; }
  .shinyforms-ui .sf-question { margin-top: 25px; font-size: 16px}
  .shinyforms-ui .sf-question-shifted { margin-top: 25px; font-size: 16px; margin-left: 25px;}
  .shinyforms-ui .sf-question-bold { margin-top: 25px; font-size: 16px; font-weight: bold; }
  .shinyforms-ui .question-hint { font-size: 14px; color: #737373; font-weight: normal; }
  .shinyforms-ui .action-button.btn { font-size: 16px; margin-right: 10px; }
  .shinyforms-ui .thankyou_msg { margin-top: 10px; }
  .shinyforms-ui .showhide { margin-top: 10px; display: inline-block; }
  .shinyforms-ui .sf_submit_msg { font-weight: bold; }
  .shinyforms-ui .sf_error { margin-top: 15px; color: red; }
  .shinyforms-ui .answers { margin-top: 25px; }
  .shinyforms-ui .pw-box { margin-top: -20px; }
  .shinyforms-ui .created-by { font-size: 12px; font-style: italic; color: #777; margin: 25px auto 10px;}
  "
  return(appCSS)

}


