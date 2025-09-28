clean_hits <- function(DF_HITS_raw) {

  # targets::tar_load("DF_HITS_raw")
  # targets::tar_load_globals()

  DF_HITS_clean = DF_HITS_raw |>
    # Some margin for errors ( y , con , ...)
    dplyr::mutate(artist = gsub("(.*?)([|/&]| y |, |feat.| con ).*", "\\1", artists, ignore.case = TRUE)) |>

    # Create unique ID
    dplyr::mutate(clean_songs = create_clean_names(song),
                  clean_artist = create_clean_names(artist, eliminate_parenthesis = TRUE),
                  ID = paste0(clean_songs, "_", clean_artist)) |>
    dplyr::distinct(ID, .keep_all = TRUE) |>
    dplyr::select(ID, year, song, artist, source)

  return(DF_HITS_clean)

}
