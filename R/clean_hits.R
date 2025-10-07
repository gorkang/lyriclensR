clean_hits <- function(DF_HITS_raw) {

  # TODO: Deal with feat. (see below)

  # targets::tar_load("DF_HITS_raw")
  # targets::tar_load_globals()

  DF_HITS_clean = DF_HITS_raw |>

    # "_" and " - " creates problems in compare_searched_vs_found_jsons()
    dplyr::mutate(song = gsub("_", "", song)) |>
    dplyr::mutate(artists = gsub("_", ", ", artists)) |>
    dplyr::mutate(song = gsub(" - ", "", song)) |>
    dplyr::mutate(artists = gsub(" - ", ", ", artists)) |>

    # Some margin for errors ( y , con , ...)
    # dplyr::mutate(artist = gsub("(.*?)([|/&]| y |, |feat.| con ).*", "\\1", artists, ignore.case = TRUE)) |>

    # TODO: song = (feat. X) & co. Should be either deleted, or go to artists paste0(artists, ", ", \\1)
    # TODO: artists = (feat. X) & co. Should be either deleted, or go to artists paste0(artists, ", ", \\1)
    dplyr::mutate(artist =
                    dplyr::case_when(
                      is.na(artist) ~ gsub("(.*?)([|/&]| y |, |featuring|feat\\.|feat|ft\\.| con ).*", "\\1", artists, ignore.case = TRUE),
                      TRUE ~ artist
                      )

                  ) |>

    # Create unique ID
    dplyr::mutate(clean_songs = create_clean_names(song),
                  clean_artist = create_clean_names(artist, eliminate_parenthesis = TRUE),
                  ID = paste0(clean_songs, "_", clean_artist)) |>
    dplyr::distinct(ID, .keep_all = TRUE) |>
    dplyr::select(ID, year, song, artist, source) |>

    # Manual ammends
    dplyr::mutate(ID = dplyr::case_when(
      ID == "_aitana" ~ "+_aitana",
      ID == "_aitanacali" ~ "+_aitanacali",
      TRUE ~ ID))


  return(DF_HITS_clean)

}
