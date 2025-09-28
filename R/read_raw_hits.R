read_raw_hits <- function(raw_HITS_spotify) {
  # targets::tar_load("raw_HITS_spotify")

  # El portal de la musica
  MORE = readr::read_csv("outputs/song_lists/DF_elportaldemusica_2009-2024.csv",
                         show_col_types = FALSE) |>
    dplyr::mutate(source = "elportaldemusica") |>
    dplyr::rename(artists = artist) |>
    dplyr::select(year, song, artists, source)

  # Original paper
  LAURA = readr::read_csv("admin/DOING/laura_original_list_Hits/complete_dataset_information_songs.csv",
                          show_col_types = FALSE) |>
    dplyr::rename(
      year = `Hit Year`,
      # number = ,
      song = `Song Name`,
      artists = `Song Artist`,
      source = Source
      # semanas
    ) |>
    dplyr::select(year, song, artists, source)

  # names(MORE)
  # names(LAURA)
  # LAURA |> dplyr::count(`Hit Year`) |> View()

# Spotify

  DF_HITS = MORE |>
    dplyr::bind_rows(LAURA) |>
    dplyr::bind_rows(raw_HITS_spotify)

}
