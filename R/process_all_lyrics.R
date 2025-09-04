#' process_all_lyrics
#'
#' @param folder_lyrics_artists Location of json files for full artists
#' @param folder_lyrics_songs Location of json files for songs
#' @param daemons_artists cores to process artists json lyrics
#' @param daemons_songs cores to process songs json lyrics
#' @param write_output TRUE/FALSE
#' @param filename_output Name of output file
#' @param language Filter by language? Most common: en, es, fr, pt, ko
#'
#' @returns A DF with all artits and individual songs
#' @export
#'
#' @examples process_all_lyrics(write_output = TRUE)
process_all_lyrics <- function(folder_lyrics_artists = "outputs/lyrics/",
                               folder_lyrics_songs = "outputs/lyrics_individual_songs/",
                               daemons_artists = 10, daemons_songs = 5,
                               write_output = FALSE, filename_output = NULL,
                               language = NULL) {

  if (is.null(filename_output)) {
    filename_output = "outputs/DF_lyrics/DF_lyrics_ALL.gz"
  } else {
    # If we input a filename_output is because we want it to be written
    write_output = TRUE
  }

  # Location of json files
  lyrics_artists = list.files(folder_lyrics_artists, pattern = "json", full.names = TRUE)
  lyrics_songs   = list.files(folder_lyrics_songs, pattern = "json", full.names = TRUE)


  cli::cli_alert_info("Processing {length(lyrics_artists)} artists and {length(lyrics_songs)} songs. This  will take a minute.")


  # Read all files
  DF_ALL_artists = read_all_lyrics(lyrics_files = lyrics_artists, write_output = FALSE, daemons = daemons_artists)
  DF_ALL_songs = read_all_lyrics(lyrics_files = lyrics_songs, write_output = FALSE, daemons = daemons_songs)

  # Combine only new songs
  NEW_songs = DF_ALL_songs |> dplyr::anti_join(DF_ALL_artists, by = join_by(id))
  DF_ALL = DF_ALL_artists |>
    dplyr::bind_rows(NEW_songs) |>
    dplyr::distinct(id, .keep_all = TRUE) # Remove duplicates by id


  # When language is set, check it exists, filter for that language, and change output name
  if (!is.null(language)) {

    # Avoid using same name as column
    language_str = language

    DF = DF_ALL |> dplyr::filter(language %in% language_str)
    Available_langs = DF_ALL |> dplyr::count(language) |> tidyr::drop_na(language) |> dplyr::arrange(dplyr::desc(n)) |> head(5) |> dplyr::pull(language)

    filename_output = gsub("DF_lyrics_ALL\\.gz", paste0("DF_lyrics_ALL_", language, "\\.gz"), filename_output)

    if (nrow(DF) == 0) cli::cli_alert_info(paste0(language, " not found. The most common languages are: ", paste0(Available_langs, collapse = ", ")))

  } else {
    DF = DF_ALL
  }

  # Write
  if (write_output) {
    if (!dir.exists(dirname(filename_output))) dir.create(dirname(filename_output))
    data.table::fwrite(DF, file = filename_output, nThread = daemons_songs)
  }

  return(DF)

}
