process_spotify_HITS <- function(HITS_files) {
  # targets::tar_load("HITS_files")

  # Listamos los archivos a leer
  # HITS_files = list.files("outputs/DF", full.names = TRUE, recursive = TRUE)

  # Leemos todos los archivos de uno en uno, combinándolos en un data frame
  DF_all = readr::read_csv(HITS_files, id = "file", show_col_types = FALSE) |>
    dplyr::mutate(file = basename(tools::file_path_sans_ext(file))) |>
    tidyr::separate(file, into = c("date", "list"), sep = " ")

  # DF_all |> dplyr::count(list)

  DF_LABELS =
    tibble::tibble(
      source = c("Top50_Spain", "Top50_Global", "Billboard_100"),
      list = c("37i9dQZEVXbNFJfN1Vw8d9",
               "37i9dQZEVXbMDoHDwVN2tF",
               "6UeSakyzhiEt4NB3UAd6NQ")
      )


  DF_out = DF_all |>
    # Only keep songs in the TOP HITs we have in DF_LABELS$list
    dplyr::filter(list %in% DF_LABELS$list) |>
    dplyr::left_join(DF_LABELS, by = dplyr::join_by(list)) |>
    dplyr::select(date, song, artist, source) |>
    dplyr::rename(artists = artist) |>
    # Get rid of the E in Explicit songs.
      # Issues: DÓNDE -> DÓND
      #         BAILE INoLVIDABLE -> BAILE INoLVIDABL
    # dplyr::mutate(song_Explicit = gsub("^(.*)E$", "\\1", song, ignore.case = FALSE)) |>
    dplyr::mutate(year = lubridate::year(date)) |>
    dplyr::mutate(artist = gsub("(.*?) \\|\\|.*", "\\1", artists)) |>
    dplyr::select(year, song, artist, artists, source)

  # DF_out |> dplyr::distinct(song, .keep_all = TRUE) |> View()

  # DF_not_E = DF_out |>
  #   dplyr::distinct(song, .keep_all = TRUE) |>
  #   dplyr::filter(song != song_Explicit) |>
  #   dplyr::mutate(song = song_Explicit) |>
  #   dplyr::select(-song_Explicit) |>
  #   dplyr::mutate(source = paste0(source, " | Explicit"))
  #
  # DF_out_extra_E = DF_out |>
  #   dplyr::bind_rows(DF_not_E) |>
  #   dplyr::select(year, song, artists, source) |>
  #   dplyr::distinct(.keep_all = TRUE)

  return(DF_out)

}
