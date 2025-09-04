#' create_wordcloud
#'
#' @param lyrics JSON file with lyrics of DF_lyrics
#' @param ngram Show n continuous words
#' @importFrom dplyr filter
#' @importFrom ggplot2 ggplot aes geom_histogram scale_x_continuous theme_minimal
#' @importFrom wordcloud2 wordcloud2
#'
#' @returns A wordcloud image
#' @export
#'
#' @examples create_wordcloud(lyrics = "outputs/lyrics/Lyrics_TaylorSwift.json")
create_wordcloud <- function(lyrics, ngram = 1) {

  # Read json or use DF
  if (is.data.frame(lyrics)) {
    DF_all = lyrics
  } else if (grepl("json", lyrics)) {
    DF_all = read_lyrics(lyrics)
  } else {
    cli::cli_abort("lyrics should be either a DF created by 'read_lyrics' or a json file")
  }

  DF_ngram = extract_words(DF_all, ngram)

  DF_plot = clean_words(DF_ngram) |>
    dplyr::filter(freq > 5)

  # https://r-graph-gallery.com/196-the-wordcloud2-library.html
  set.seed(1)
  PLOT = wordcloud2::wordcloud2(DF_plot, size=1.6, color='random-dark')

  return(PLOT)

}
