#' download_full_discography
#'
#' @param name_artist Name of the artist
#'
#' @returns Downloads a json file
#' @export
#' @importFrom reticulate source_python
#' @examples download_full_discography("Tool")
download_full_discography <- function(name_artist) {

    # Sys.setenv(RETICULATE_PYTHON="/usr/bin/python3.12")
  reticulate::source_python(system.file("python", "py_download_full_discography.py", package = "lyriclensR"))
  py_download_full_discography(name_artist)

}

# Safe version of download_full_discography (won't fail when artist does not exist)
download_full_discography_safely = purrr::safely(download_full_discography)


#' download_song
#'
#' @param name_artist Name of the artist
#' @param name_song Name of the song
#'
#' @returns Downloads a json file
#' @export
#' @importFrom reticulate source_python
#' @examples download_individual_songs("Tool", "46&2")
download_song <- function(name_artist, name_song, min_s_wait = 5, max_s_wait = 10) {

  seconds_pause = round(runif(1, min_s_wait, max_s_wait), 2)
  cli::cli_alert_info("{name_artist} - {name_song} | pause {seconds_pause}s.")

  reticulate::source_python(system.file("python", "py_download_song.py", package = "lyriclensR"))
  py_download_song(name_artist, name_song)

  Sys.sleep(seconds_pause)

}

# Safe version of download_individual_songs (won't fail when artist does not exist)
download_song_safely = purrr::safely(download_song)



#' get_and_process_spotify_list
#' Get and process Spotify list html (create zip)
#'
#' @param spotify_list_URL Spotify list URL
#'
#' @returns A DF
#' @export
#'
#' @examples get_and_process_spotify_list("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9")
get_and_process_spotify_list <- function(spotify_list_URL) {
  # spotify_list_URL = "https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9"

  reticulate::source_python(system.file("python", "py_download_spotify_list.py", package = "lyriclensR"))
  py_download_spotify_list(spotify_list_URL)

  DF = process_html(spotify_list_URL)

  return(DF)
}
