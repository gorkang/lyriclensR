CHECKS <- function(DF_lyrics, DF_paragraphs, DF_lyrics_paragraphs_HITS, low_chars = 1, high_chars = 1000) {

  # targets::tar_load_globals()

  # targets::tar_load(c("DF_lyrics_paragraphs_HITS", "DF_lyrics", "DF_paragraphs"))
  # DF_lyrics_paragraphs_HITS$DF_lyrics_HITS
  # DF_lyrics_paragraphs_HITS$DF_paragraphs_HITS

  # targets::tar_load("DF_lyrics_current")
  # targets::tar_load("DF_paragraphs_current")
  # nrow(DF_lyrics_current)
  # nrow(DF_paragraphs_current)
  # DF_paragraphs = DF_paragraphs_current


# json_files --------------------------------------------------------------

  cli::cli_h1("CHECKS search/found (jsons)")

  DIFFs = suppressWarnings(compare_searched_vs_found_jsons())
  DIFFs_table = DIFFs |> dplyr::count(DIFF_artist, DIFF_parcial_artist, DIFF_distance_artist)
  print(knitr::kable(DIFFs_table))

  # Paragraphs --------------------------------------------------------------

  DF_paragraphs_chars = DF_paragraphs |>
    dplyr::mutate(n_char = nchar(paragraph)) |>
    dplyr::select(id, id_paragraph, n_char)

  DF_paragraphs_chars_1 = DF_paragraphs_chars |>
    dplyr::filter(n_char <= low_chars)

  DF_paragraphs_chars_1000 = DF_paragraphs_chars |>
    dplyr::filter(n_char >= high_chars)
    # dplyr::filter(id == 1979078) |>
    # dplyr::pull(paragraph) |> cat()

  # ALERTS
  cli::cli_h1("CHECKS characters")
  cli::cli_alert_warning("{DF_paragraphs_chars_1 |> nrow()} paragraphs: # characters <= {low_chars}")
  cli::cli_alert_warning("{DF_paragraphs_chars_1000 |> nrow()} paragraphs: # characters >= {high_chars}")



  # Paragraphs per song -----------------------------------------------------
  DF_paragraphs_count = DF_paragraphs |> dplyr::count(id)

  # 17K songs with 1 paragraph
  DF_songs_1_paragraph = DF_paragraphs_count |> dplyr::filter(n == 1)

  # 23 canciones con mas de 100 parrafos
  DF_songs_50_paragraphs = DF_paragraphs_count |> dplyr::filter(n >= 50)

  # ALERTS
  cli::cli_h1("CHECKS paragraphs")
  cli::cli_alert_warning("{DF_songs_1_paragraph |> nrow()} songs: 1 paragraph")
  cli::cli_alert_warning("{DF_songs_50_paragraphs |> nrow()} songs: 50 or more paragraphs")

  # DF_paragraphs |>
  #   # dplyr::filter(n_char > 1000) |>
  #   dplyr::filter(id == 229801) |>
  #   dplyr::pull(paragraph) |> cat()

  BINS = length(unique(DF_paragraphs_count$n))
  # DF_paragraphs_count |> dplyr::count(n) |> View()
  plot_paragraphs = DF_paragraphs_count |>
    ggplot2::ggplot(ggplot2::aes(n)) +
    ggplot2::geom_histogram(bins = BINS) +
    ggplot2::theme_minimal() +
    ggplot2::scale_x_continuous(n.breaks = 15) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(title = "Paragraphs per song",
                  x = "number of paragraphs")

  plot_characters = DF_paragraphs_chars |>
    ggplot2::ggplot(ggplot2::aes(n_char)) +
    ggplot2::geom_histogram() +
    ggplot2::theme_minimal() +
    ggplot2::scale_x_log10() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(title = "Characters per paragraph",
                  x = "number of characters (log)")



# HITS --------------------------------------------------------------------

  BINS = length(unique(DF_lyrics_paragraphs_HITS$DF_lyrics_HITS |> dplyr::filter(year > 1900) |> dplyr::pull(year)))

  plot_HITS_years =
    DF_lyrics_paragraphs_HITS$DF_lyrics_HITS |>
    dplyr::filter(year > 1900) |>
    # dplyr::count(year)
    ggplot2::ggplot(ggplot2::aes(year)) +
    ggplot2::geom_histogram(bins = BINS) +
    ggplot2::scale_x_continuous(n.breaks = 20) +
    ggplot2::scale_y_continuous(n.breaks = 20) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Hit songs per year")


# Output ------------------------------------------------------------------


  OUT =
    list(
      DF_paragraphs_chars = DF_paragraphs_chars,
      DF_paragraphs_chars_1 = DF_paragraphs_chars_1,
      DF_paragraphs_chars_1000 = DF_paragraphs_chars_1000,
      DF_paragraphs_count = DF_paragraphs_count,
      DF_songs_1_paragraph = DF_songs_1_paragraph,
      DF_songs_50_paragraphs = DF_songs_50_paragraphs,
      plot_paragraphs = plot_paragraphs,
      plot_characters = plot_characters,
      plot_HITS_years = plot_HITS_years
    )

}
