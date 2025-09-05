#' separate_paragraphs
#' Separates a DF created with process_all_lyrics() into individual paragraphs
#' and cleans the paragraphs
#'
#' @param DF_lyrics DF_lyrics dataframe
#' @param daemons a DF created with process_all_lyrics()
#' @param write_output TRUE/FALSE
#' @param filename_output Name of the output file
#' @param language es, en, ...
#'
#' @returns A DF with paragraphs
#' @export
#'
#' @examples DF_paragraphs = separate_paragraphs(DF_ALL_es)
separate_paragraphs <- function(DF_lyrics, daemons = 5, write_output = FALSE, filename_output = NULL, language = NULL) {

  if (nrow(DF_lyrics) == 0) return(tibble::tibble())

  if (is.null(filename_output)) {
    filename_output = "outputs/DF_lyrics/DF_paragraphs.gz"
  } else {
    # If we input a filename_output is because we want it to be written
    write_output = TRUE
  }

  if (!is.null(language)) filename_output = gsub("DF_paragraphs\\.gz", paste0("DF_paragraphs", language, "\\.gz"), filename_output)



  # Separate into paragraphs ---------------------------------------------

  DF_paragraphs_temp = DF_lyrics |>
    dplyr::select(id, lyrics) |>
    tidyr::separate_longer_delim(lyrics, "\n\n") |>
    dplyr::rename(paragraph_raw = lyrics) |>

    # Clean up
    dplyr::mutate(paragraph = gsub("\\[.*\\]", "", paragraph_raw)) |>
    dplyr::mutate(paragraph = gsub("^\\n\\n", "", paragraph)) |> #1s
    dplyr::mutate(paragraph = gsub("^\\n", "", paragraph)) |>

    # Add paragraph_id
    dplyr::group_by(id) |>
    dplyr::mutate(id_paragraph = 1:dplyr::n()) |>
    dplyr::ungroup() |>
    dplyr::select(id, id_paragraph, dplyr::everything()) |>
    dplyr::mutate(id_song_paragraph = paste0(id, paragraph))



  # TODO: DELETE paragraphs ... Read More
  # dplyr::filter(grepl("... Read More", lyrics)) |> View()



  # Clean up ----------------------------------------------------------------

  # DELETE bad paragraphs
  DICC_bad_paragraphs = tibble::tibble(
    paragraph = c("¡La letra completa estará disponible pronto!",
                  "",
                  "Adelanto")
  )

  DF_paragraphs_nobad = DF_paragraphs_temp |>
    dplyr::anti_join(DICC_bad_paragraphs,
                     by = dplyr::join_by(paragraph))

  # How many paragraphs we have duplicated in each song
  DF_dulicated_paragraphs = DF_paragraphs_nobad |>
    # dplyr::group_by(id, id_song_paragraph) |>
    dplyr::summarise(N = dplyr::n(),
                     ids = paste(id_paragraph, collapse = ","),
                     .by = c(id, id_song_paragraph)) |>
    dplyr::filter(N > 1)
  # count(id_song_paragraph) |>
  # filter(n > 1)

  # Delete duplicated paragraphs in songs
  DF_paragraphs = DF_paragraphs_nobad |>
    dplyr::distinct(id_song_paragraph, .keep_all = TRUE) |>
    dplyr::select(-id_song_paragraph, -paragraph_raw)

  # cli::cli_alert_info("Deleted {nrow(DF_paragraphs_temp) - nrow(DF_paragraphs)} paragraphs")


  # Save --------------------------------------------------------------------

  # Write
  if (write_output) {
    if (!dir.exists(dirname(filename_output))) dir.create(dirname(filename_output))
    data.table::fwrite(DF_paragraphs, file = filename_output, nThread = daemons)
    # write_csv(DF_paragraphs, "DF_paragraphs_es.csv")
    # write_csv(DF_paragraphs |> select(-paragraph_raw) |> dplyr::sample_n(10), "DF_paragraphs_10_es.csv")

  }

  return(DF_paragraphs)

}
