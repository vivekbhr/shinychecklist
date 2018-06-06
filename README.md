# shinychecklist - Create checklists with shiny

shinychecklist allows you to create a shiny server that hosts a checklist online. The data from the checklist can be stored in the google sheets and can also be downloaded as a pdf file.

#### Fork information

This package has been originally forked from dan attali's github repository called `shinyforms`, distributes with MIT license.

#### How do I use this?

First, install this package from GitHub

```
# install.packages("devtools")
devtools::install_github("vivekbhr/shinychecklist")
```

Then create your list of questions. Each question is a list with an `id`, `type`, `title`, and `mandatory` (`mandatory` is `FALSE` by default)

```
library(shiny)
library(shinychecklist)

questions <- list(
  list(id = "name", type = "text", title = "Name", mandatory = TRUE),
  list(id = "age", type = "numeric", title = "Age"),
  list(id = "favourite_pkg", type = "text", title = "Favourite R package"),
  list(id = "terms", type = "checkbox", title = "I agree to the terms")
)
```

Then create your form information, which has an `id`, the list of `questions`, and the `storage` type (where responses get saved).

```
formInfo <- list(
  id = "basicinfo",
  questions = questions,
  storage = list(
    # Right now, only flat file storage is supported
    type = STORAGE_TYPES$FLATFILE,
    # The path where responses are stored
    path = "responses"
  )
)
```

That's all the information we need. Now we can add the form to a Shiny app by simply calling `formUI()` and `formServer()` from our Shiny apps' UI and server:

```
ui <- fluidPage(
  formUI(formInfo)
)

server <- function(input, output, session) {
  formServer(formInfo)
}

shinyApp(ui = ui, server = server)
```

Of course you could put more stuff in the app, but this is the beauty of it, the form is a "module" that you can just plug into any Shiny app anywhere you want. Every time you submit a response, it will be saved as a file in the `responses` directory. This example is the most basic usage.

#### Current features

- Responses are saved to local files
- Support for mandatory vs optional fields (all questions with `mandatory = TRUE` have to be filled out before the submit button can be clicked)
- Can create a form with only one line in the UI and one line in the server
- Can include multiple different forms in the same app
- Clean and user-friendly way to catch and report errors
- Questions and form data are in the format of R lists
- Supported question types: text, numeric, checkbox
- Ability to submit multiple responses for the same form (use `multiple = FALSE` in the form info list to disallow multiple submissions)
- Admin mode support: if you add `?admin=1` to the URL, you will see buttons for viewing all submitted responses below each form. If you want to see all responses, you'll have to enter a password to verify you're an admin (since anybody can just modify the URL). The password is provided by the `password` in the form info list.
- Support for more complex input validation that gives nice error messages when a field does not meet certain conditions (use the `validations` option in the form info)
- Can have an optional "Reset" button that resets the fields in the form (use the `reset = TRUE` parameter in the form info)
- Questions can have hint text, which is text just below the question title that gives a longer description (use the `hint` parameter of a question)

#### Another example

This example is similar to the previous one, but illustrates a few more features. It shows how to have two forms in one app, and how to use the admin viewing ability.

```
library(shiny)
library(shinychecklist)

# Define the first form: basic information
basicInfoForm <- list(
  id = "basicinfo",
  questions = list(
    list(id = "name", type = "text", title = "Name", mandatory = TRUE,
         hint = "Your name exactly as it is shown on your passport"),
    list(id = "age", type = "numeric", title = "Age", mandatory = FALSE),
    list(id = "favourite_pkg", type = "text", title = "Favourite R package"),
    list(id = "terms", type = "checkbox", title = "I agree to the terms")
  ),
  storage = list(
    type = STORAGE_TYPES$FLATFILE,
    path = "responses"
  ),
  name = "Personal info",
  password = "shinyforms",
  reset = TRUE,
  validations = list(
    list(condition = "nchar(input$name) >= 3",
         message = "Name must be at least 3 characters"),
    list(condition = "input$terms == TRUE",
         message = "You must agree to the terms")
  )
)

# Define the second form: soccer
soccerFormInfo <- list(
  id = "soccerform",
  questions = list(
    list(id = "team", type = "text", title = "Favourite soccer team"),
    list(id = "player", type = "text", title = "Favourite player")
  ),
  storage = list(
    type = STORAGE_TYPES$FLATFILE,
    path = "soccer"
  ),
  multiple = FALSE
)

ui <- fluidPage(
  h1("shinyforms example"),
  tabsetPanel(
    tabPanel(
      "Basic info",
      formUI(basicInfoForm)
    ),
    tabPanel(
      "Soccer",
      formUI(soccerFormInfo)
    )
  )
)

server <- function(input, output, session) {
  formServer(basicInfoForm)
  formServer(soccerFormInfo)
}

shinyApp(ui = ui, server = server)
```

Notice how easy this is? After defining the forms with R lists, it's literally two function calls for each form to get it set up. A couple things to note: first, the soccer form uses the `multiple = FALSE` option, which means a user can only submit once (if you restart the Shiny app, the same user is able to submit the form again). Secondly, the first form uses the `password` option, which means that the admin table will be available IF you add `?admin=1` to the URL. To see the responses from the admin table, click on "Show responses" and type in the password "shinyforms". This app also uses several other features.
