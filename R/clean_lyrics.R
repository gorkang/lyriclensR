lyrics_clean <- function(DF_lyrics_updated) {

  # targets::tar_load("DF_lyrics_updated")
  # nrow(DF_lyrics_updated)
  # names(DF_lyrics_updated)

  if (is.null(DF_lyrics_updated)) return(NULL)

  DF_lyrics_clean =
    DF_lyrics_updated |>
    dplyr::mutate(year = lubridate::year(release_date)) |>
    dplyr::select(-lyrics_raw, -lyrics_state, -json_file, -release_date)

  # names(DF_lyrics_clean)

  return(DF_lyrics_clean)

}
