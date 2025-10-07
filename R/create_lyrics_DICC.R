create_lyrics_DICC <- function(DF_lyrics_clean) {

  # targets::tar_load("DF_lyrics_clean")
  # targets::tar_load_globals()

  if (is.null(DF_lyrics_clean)) return(NULL)

  DF_lyrics_DICC = DF_lyrics_clean |>

    # TODO: Should this be done when reading the file?
    dplyr::rename(song = title) |>
    # --
    dplyr::mutate(clean_songs = create_clean_names(song),
                  clean_artist = create_clean_names(artist, eliminate_parenthesis = TRUE),
                  ID = paste0(clean_songs, "_", clean_artist)
                  # ID2 = paste0(clean_songs, "_", year)
    ) |>
    dplyr::select(id, ID, year, song, artist)

  return(DF_lyrics_DICC)

}
