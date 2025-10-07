compare_searched_vs_found_jsons <- function(input = "outputs/lyrics_processed/lyrics_processed.zip") {

  # Input either lyrics_processed.zip or a folder with jsons
  # input = "outputs/lyrics_to_process/"

  input_extension = tools::file_ext(input)

  if (input_extension == "zip") {
    JSONs = zip::zip_list(input) |> dplyr::select(filename)
  } else {
    JSONs = tibble::tibble(filename = list.files(path = input))
  }

  # TODO:
    # a number of filenames contain too many "_" or " - ".
    # FIX in clean_hits and re-download all affected songs
  XX = tibble::tibble(filename = basename(JSONs$filename),
                      NUM_ = stringr::str_count(filename, "_"),
                      NUMmid = stringr::str_count(filename, " - "))

  # XX = tibble::tibble(X = stringr::str_count(basename(JSONs$filename), "_"))
  # processed_JSONs$json_name[c(673, 1086, 1087)]
  # [1] "chimbala_feliz_chimbala" "Emilia _La_Original.mp3" "EMILIA _NO_SE_VE.MP3",  "La Llama del Amor  Riega Este Querer  Rumba"
  # processed_JSONs$json_name[c(512, 1109, 1291, 1310, 1347, 2280, 2281, 2446, 2539, 3437, 3438)]

  processed_JSONs =
    JSONs |>
    # Reads processed.zip and extracts artist name for the old JSON format and the new one
    dplyr::mutate(json_name =
                       dplyr::case_when(
                         grepl("Lyrics_", tools::file_path_sans_ext(basename(filename)), ignore.case = TRUE) ~ gsub("Lyrics_", "", tools::file_path_sans_ext(basename(filename)), ignore.case = TRUE),
                         TRUE ~ gsub("(.*) - .*", "\\1", tools::file_path_sans_ext(basename(filename))))) |>
    dplyr::mutate(file = basename(filename)) |>
    # Avoid individual songs
    dplyr::filter(!grepl("^lyrics", file, ignore.case = TRUE)) |>
    tidyr::separate(file, into = c("search", "found"), sep = " - ") |>
    tidyr::separate(search, into = c("searched_artist", "searched_song"), sep = "_") |>
    tidyr::separate(found, into = c("found_artist", "found_song"), sep = "_") |>
    dplyr::select(filename, json_name, searched_song, found_song, searched_artist, found_artist) |>
    tibble::as_tibble()

  DIFFs = processed_JSONs |>
    tidyr::drop_na(searched_song) |>
    dplyr::mutate(DISTANCE = stringdist::stringdist(found_artist, searched_artist),
           PROP_DIST = DISTANCE/nchar(searched_artist),
           PROP_DIST2 = DISTANCE/nchar(found_artist)) |>
    dplyr::rowwise() |>
    dplyr::mutate(DIFF_artist =
                    dplyr::case_when(
               create_clean_names(searched_artist) == create_clean_names(found_artist) ~ TRUE,
               create_clean_names(searched_artist, TRUE) == create_clean_names(found_artist, TRUE) ~ TRUE,
               TRUE ~ FALSE
             )) |>
    dplyr::mutate(DIFF_parcial_artist =
                dplyr::case_when(
               grepl(found_artist, searched_artist, ignore.case = TRUE) ~ TRUE,
               grepl(searched_artist, found_artist, ignore.case = TRUE) ~ TRUE,
               TRUE ~ FALSE
             )) |>
    dplyr::mutate(DIFF_distance_artist =
                    dplyr::case_when(
               DIFF_artist == TRUE ~ NA,
               DIFF_artist == FALSE & PROP_DIST < 0.5 ~ TRUE,
               DIFF_artist == FALSE & PROP_DIST2 < 0.5 ~ TRUE,
               TRUE ~ FALSE
             ))


  DIFFs |> dplyr::count(DIFF_artist, DIFF_parcial_artist, DIFF_distance_artist)

  # DIFF DFs

  # No match
  DF_very_DIFF = DIFFs |> dplyr::filter(!DIFF_artist  & !DIFF_parcial_artist & !DIFF_distance_artist)

  # Partial match
  DF_partial_DIFF = DIFFs |> dplyr::filter(!DIFF_artist  & DIFF_parcial_artist )

  # Any match
  DF_any_DIFF = DIFFs |> dplyr::filter(DIFF_artist  | DIFF_parcial_artist | DIFF_distance_artist)


  return(DIFFs)

}
