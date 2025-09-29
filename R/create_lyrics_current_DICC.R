create_lyrics_current_DICC <- function(DF_lyrics_current) {

  # targets::tar_load("DF_lyrics_current")
  # targets::tar_load_globals()

  DF_lyrics_current_DICC = DF_lyrics_current |>

    # TODO: Should these 2 be done when reading the file?
    dplyr::mutate(year = lubridate::year(release_date)) |>
    dplyr::rename(song = title) |>
    # --
    dplyr::mutate(clean_songs = create_clean_names(song),
                  clean_artist = create_clean_names(artist, eliminate_parenthesis = TRUE),
                  ID = paste0(clean_songs, "_", clean_artist)
                  # ID2 = paste0(clean_songs, "_", year)
    ) |>
    dplyr::select(id, ID, year, release_date, song, artist)


  return(DF_lyrics_current_DICC)

}
