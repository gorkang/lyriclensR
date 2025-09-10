if (!require('shiny')) install.packages('shiny'); library('shiny')
if (!require('dplyr')) install.packages('dplyr'); library('dplyr')
if (!require('DT')) install.packages('DT'); library('DT')
if (!require('stringr')) install.packages('stringr'); library('stringr')
if (!require('tidyr')) install.packages('tidyr'); library('tidyr')
if (!require('here')) install.packages('here'); library('here')
if (!require('data.table')) install.packages('data.table'); library('data.table')
if (!require('R.utils')) install.packages('R.utils'); library('R.utils')


invisible(lapply(list.files("./R", full.names = TRUE, pattern = ".R"), source))
filename = here::here("outputs/DF_lyrics/DF_lyrics_ALL.gz")
# filename = here::here("outputs/DF_lyrics/DF_lyrics_es.gz")

DF_ALL = data.table::fread(filename) |>
  dplyr::distinct(id, .keep_all = TRUE)

ALL_artists = DF_ALL |>
  dplyr::count(artist) |>
  dplyr::arrange(dplyr::desc(n)) |>
  head(100) |>
  # dplyr::filter(n > 20) |>
  dplyr::arrange(artist) |>
  dplyr::pull(artist)


ui <-
  fluidPage(
      fluidRow(
        column(2, align="left"),
        column(8, align="center",
               titlePanel("Lyriclens"))),

        br(),


      fluidRow(
        column(2, align="left"),
        column(8, align="center",
        textInput(inputId = "word",
                  label = "",
                  width = "50%",
                  placeholder = "Input words to search here / Introduce palabras para buscar aquí"))
        ),

      fluidRow(
        column(2, align="left"),
        column(8, align="center",

        # TODO: This should be dynamic (based on words search)
        # https://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices
        selectInput(
          inputId = "artists",
          label = "Artists/Artistas:",
          choices = ALL_artists,
          selected = "",
          width = "33%",
          selectize = TRUE,
          multiple = TRUE)
        )),

      fluidRow(
        column(2, align="left"),
        column(8, align="center",
        sliderInput(inputId = "n_sentences_around",
                    label = "Lines context/Líneas contexto",
                    min = 0, max = 10, step = 1, value = 0,
                    ticks = TRUE,
                    width = "20%"))),

      column(2, align="left"),
      br(),

      column(12, align="center",
      textOutput("songs")),

    fluidRow(
      column(2, align="left"),
      column(8, align="center",
          DT::dataTableOutput("mytable"))
    )
)

server <- function(input, output) {

  # Ahora se crea DF a partir de artists.
  # Se usa ese DF para search_words(), donde se buscan palabras.

  DATAFRAME <- reactive({

    if (is.null(input$artists)) {
      DF_DATA = DF_ALL
    } else {
      DF_DATA = DF_ALL |> dplyr::filter(artist %in% input$artists)
    }

  })

  TABLE <- reactive({

      search_words(
        lyrics = DATAFRAME(),
        highlight_words = input$word,
        n_sentences_around = input$n_sentences_around)

  })


  output$songs = renderText({

    paste("Number of songs:", formatC(nrow(TABLE()$TABLE$x$data), big.mark = ","))

  })

  output$mytable = DT::renderDataTable({

    if (input$word == "" && is.null(input$artists)) {

      NULL

    } else {

      TABLE()$TABLE

    }

  })

}

# Run the application
shinyApp(ui = ui, server = server)
