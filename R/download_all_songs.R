#' download_all_songs
#' Download all songs from a processed spotify list
#'
#' @param processed_spotify_list A spotify list from get_spotify_list()
#' @param min_s_wait Min seconds to wait between requests
#' @param max_s_wait Max seconds to wait between requests
#'
#' @returns .json files downloaded using the Genius API
#' @export
#'
#' @examples download_all_songs(processed_spotify_list)
download_all_songs <- function(processed_spotify_list, min_s_wait = 5, max_s_wait = 10) {

  DF_canciones = processed_spotify_list$DF_output

  1:nrow(DF_canciones) |>
    purrr::walk(~{

      cli::cli_alert_info("{.x}/{nrow(DF_canciones)}: {DF_canciones$Cancion[.x]} - {DF_canciones$Artista[.x]}")

      OUT = get_individual_songs_safely(
        name_artist = DF_canciones$Artista[.x],
        name_song = DF_canciones$Cancion[.x]
      )

      Sys.sleep(runif(1, min_s_wait, max_s_wait))
      return(OUT)
    })

  move_downloaded_lyrics()

}
