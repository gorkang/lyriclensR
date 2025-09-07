#' process_new_lyrics
#' Read lyrics in  "outputs/lyrics_to_process/" and combine them with full lyrics
#'
#' @param folder_lyrics Location of json files
#' @param daemons cores to process json lyrics
#' @param write_output TRUE/FALSE
#' @param filename_output Name of output file
#' @param language Filter by language? Most common: en, es, fr, pt, ko
#'
#' @returns A DF with all artits and individual songs
#' @export
#'
#' @examples process_new_lyrics(write_output = TRUE)
process_new_lyrics <- function(folder_lyrics = "outputs/lyrics_to_process/",
                               daemons = 10,
                               write_output = FALSE, filename_output = NULL,
                               language = NULL) {

  if (is.null(filename_output)) {
    filename_output = "outputs/DF_lyrics/DF_lyrics_ALL.gz"
  } else {
    # If we input a filename_output is because we want it to be written
    write_output = TRUE
  }

  # Location of json files
  lyrics_files = list.files(folder_lyrics, pattern = "json", full.names = TRUE)


  cli::cli_alert_info("Processing {length(lyrics_files)} files. This  will take a minute.")

  # Current full DF
  DF_current = data.table::fread("outputs/DF_lyrics/DF_lyrics_ALL.gz")

  # Read all files
  DF_new = read_all_lyrics(lyrics_files = lyrics_files, write_output = FALSE, daemons = daemons)

  # Combine only new songs and output unique songs
  DF_ALL = combine_new_songs(DF_main = DF_current, DF_new = DF_new, what = "lyrics")


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
    data.table::fwrite(DF, file = filename_output, nThread = daemons)
  }

  return(DF)

}
