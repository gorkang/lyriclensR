#' get_songs
#'
#' @param name_artist Name of the artist
#'
#' @returns Downloads a json file
#' @export
#' @importFrom reticulate source_python
#' @examples get_songs("Tool")
get_songs <- function(name_artist) {
  # Sys.setenv(RETICULATE_PYTHON="/usr/bin/python3.12")
  reticulate::source_python(system.file("python", "get_songs.py", package = "lyriclensR"))
  get_songs(name_artist)


}

# Safe version of get_songs (won't fail when artist does not exist)
get_songs_safely = purrr::safely(get_songs)


#' get_individual_songs
#'
#' @param name_artist Name of the artist
#' @param name_song Name of the song
#'
#' @returns Downloads a json file
#' @export
#' @importFrom reticulate source_python
#' @examples get_individual_songs("Tool", "46&2")
get_individual_songs <- function(name_artist, name_song) {
  reticulate::source_python(system.file("python", "get_individual_songs.py", package = "lyriclensR"))
  get_individual_songs(name_artist, name_song)


}

# Safe version of get_songs (won't fail when artist does not exist)
get_individual_songs_safely = purrr::safely(get_individual_songs)



#' get_and_process
#' Get and process Spotify list html (create zip)
#'
#' @param WEB Spotify list URL
#'
#' @returns A DF
#' @export
#'
#' @examples get_and_process("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9")
get_and_process <- function(WEB) {
  # WEB = "https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9"

  reticulate::source_python(system.file("python", "download_spotify_list.py", package = "lyriclensR"))
  get_spotify_list(WEB)

  DF = process_html(WEB)

  return(DF)
}
