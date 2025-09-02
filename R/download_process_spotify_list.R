#' download_process_spotify_list
#' Will download the FULL discography for the artists found in the Spotify list
#'
#' @param spotify_list_URL URL of Spotify list. For example: https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9
#' @param only_new Download only authors we don't have?
#' @param continue_after_error Will dowload authors not in the main folder
#' @param end_message Send message using {ntfy}
#'
#' @returns A DF with the full processed data
#' @export
#'
#' @examples download_process_spotify_list("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9")
download_process_spotify_list <- function(spotify_list_URL, only_new = FALSE, continue_after_error = FALSE, end_message = FALSE) {

  # 1) Download Spotify website and process it
  cli::cli_h1("Downloading Spotify playlist")
  OUT = get_and_process(WEB = spotify_list_URL)


  # 2) List not already downloaded artists
  cli::cli_h1("Filtering artists")
  LastFile = tibble::tibble(filename = list.files("outputs/DF/", full.names = TRUE)) |>
    dplyr::mutate(ctime = file.info(filename, extra_cols = TRUE)$ctime) |>
    dplyr::filter(ctime == max(ctime)) |> dplyr::pull(filename)

  # LastFile = "outputs/DF/2025-07-30 15:44:50.544527 6UeSakyzhiEt4NB3UAd6NQ.csv"

  if (continue_after_error) {
    # IF DOWNLOAD fails, restart here
    Artistas_clean = list_not_downloaded_artists(input = LastFile,
                                                 location_jsons = ".")
  } else {
    # Download only artists not in outputs/lyrics
    Artistas_clean = list_not_downloaded_artists(input = LastFile)
  }


  # 3) Download all artists Lyrics
  cli::cli_h1("Download artists")
  if (only_new) {
    download_all_artists(c(Artistas_clean))
  } else {
    # OR download all!
    download_all_artists(c(OUT$ARTISTAS))
  }

  # 4) Move to lyrics folder
  cli::cli_h1("Move json files to output/lyrics")
  move_downloaded_lyrics()

  # 5) Process
  cli::cli_h1("Process all lyrics")
  lyrics = list.files("outputs/lyrics/", pattern = "json", full.names = TRUE)

  DF_ALL = read_all_lyrics(lyrics, write_output = TRUE)

  if (end_message) {
    if (!require('ntfy')) remotes::install_github("jonocarroll/ntfy"); library('ntfy')
    ntfy::ntfy_send(paste0(Sys.Date(), ": All artists downloaded!"))
  }

  return(DF_ALL)

}
