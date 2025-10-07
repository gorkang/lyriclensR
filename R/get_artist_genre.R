#' get_artist_genre
#'
#' @param DF data frame with artist column
#'
#' @importFrom spotifyr get_spotify_access_token get_artists
#' @importFrom purrr map_df
#' @importFrom tidyr separate_longer_delim
#' @importFrom dplyr select count tibble
#'
#' @returns
#' @export
#'
#'
#' @examples
get_artist_genre <- function(DF) {


  access_token <- spotifyr::get_spotify_access_token()

  ARTISTS = DF |>
    dplyr::select(artist, links_artist) |>
    tidyr::separate_longer_delim(c(artist, links_artist), delim = " || ")

  # La API solo permite de 50 en 50
  ARTISTS_chunks = split(ARTISTS$links_artist, ceiling(seq_along(ARTISTS$links_artist)/50))

  # TODO: find a way to get Spotify id for artists
  DF_genres = purrr::map_df(ARTISTS_chunks, spotifyr::get_artists)


  # Wordcloud ---------------------------------------------------------------

  # DF_genres = dplyr::tibble(word = DF_genres$genres |> unlist()) |>
  #   dplyr::count(word, name = "freq")
  # https://r-graph-gallery.com/196-the-wordcloud2-library.html
  # set.seed(1)
  # PLOT = wordcloud2::wordcloud2(DF_plot, size=1.6, color='random-dark')


  return(DF_genres)
}
