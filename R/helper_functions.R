read_lyrics <- function(lyrics_file) {
  # lyrics_file = lyrics_jsons[1]

  if (!tools::file_ext(lyrics_file) == "json") return(NULL)

  DF_temp_lyric = jsonlite::read_json(lyrics_file)
  # cat(DF$songs[[1]]$lyrics)

  # Transforms DF_temp of single songs so it is similar to the one from an artist
  if (is.null(DF_temp_lyric$songs)) {
    DF = tibble::tibble(songs = list(DF_temp_lyric))
  } else if (length(DF_temp_lyric$songs) > 0) {
    DF = DF_temp_lyric
  } else {
    cli::cli_alert_info("Empty file: {lyrics_file}")
    DF = tibble::tibble(songs = list(list(id = 0)))
  }

  DF_ALL =
    seq_along(DF$songs) |>
    purrr::map_df(
      ~ {
        # DF$songs[[.x]]$primary_artist_names
        # DF$songs[[.x]]$full_title
        # DF$songs[[.x]]$relationships_index_url
        # DF$songs[[.x]]$writer_artists
        # DF$songs[[.x]]$media

        tibble::tibble(
          id = DF$songs[[.x]]$id,
          language = DF$songs[[.x]]$language,
          release_date = DF$songs[[.x]]$release_date,
          pageviews = DF$songs[[.x]]$stats$pageviews,
          lyrics_state = DF$songs[[.x]]$lyrics_state,
          artist = DF$songs[[.x]]$artist,
          artists = DF$songs[[.x]]$artist_names,
          title =  DF$songs[[.x]]$title,
          lyrics_raw = as.character(DF$songs[[.x]]$lyrics),
          lyrics = gsub(".*?Lyrics.*?\\n(.*)", "\\1", lyrics_raw),
          link = paste0("https://genius.com", DF$songs[[.x]]$path)
        )

      }) |>

    # Add source
    dplyr::mutate(json_file = basename(lyrics_file)) |>

    # Clean
    dplyr::mutate(lyrics = gsub("La letra estará completa cuando salga la canción", "", lyrics))


  return(DF_ALL)

}


read_all_lyrics <- function(lyrics_files, write_output = FALSE, filename_output = NULL, language = NULL, daemons = 5) {

  if (is.null(filename_output)) {
    filename_output = "outputs/DF_lyrics/DF_lyrics_temp.gz"
  } else {
    # If we input a filename_output is because we want it to be written
    write_output = TRUE
  }

  # Read in parallel with n daemons
  mirai::daemons(0)
  mirai::daemons(daemons)
  DF_temp = lyrics_files |> purrr::map_df(purrr::in_parallel(\(x) read_lyrics(x), read_lyrics = read_lyrics)) # If we add parameters, need to include parameter = parameter at the end
  mirai::daemons(0)

  # When language is set, check it exists, filter for that language, and change output name
  if (!is.null(language)) {

    # Avoid using same name as column
    language_str = language

    DF = DF_temp |> dplyr::filter(language %in% language_str)
    Available_langs = DF_temp |> dplyr::count(language) |> tidyr::drop_na(language) |> dplyr::arrange(dplyr::desc(n)) |> head(5) |> dplyr::pull(language)

    # If we set filename_output, this replacement won't be done
    filename_output = gsub("DF_lyrics_temp\\.gz", paste0("DF_lyrics_", language, "\\.gz"), filename_output)

    if (nrow(DF) == 0) cli::cli_alert_info(paste0(language, " not found. The most common languages are: ", paste0(Available_langs, collapse = ", ")))

  } else {
    DF = DF_temp
  }


  if (write_output & nrow(DF) > 0) {
    if (!dir.exists(dirname(filename_output))) dir.create(dirname(filename_output))
    data.table::fwrite(DF, file = filename_output, nThread = daemons)
  }

  return(DF)

}


extract_words <- function(DF_lyrics, ngram = 1) {

  DF_words =
    DF_lyrics |>
    dplyr::select(lyrics) |>
    tidytext::unnest_tokens(word, lyrics, token = "ngrams", n = ngram) |>
    dplyr::filter(!grepl("^contributor", word))

  return(DF_words)
}

clean_words <- function(DF_words) {

  # Create DF of stop words
  custom_stop_words <-
    dplyr::bind_rows(tidytext::stop_words,
                     tibble::tibble(word = tm::stopwords("spanish"), lexicon = "custom"),
                     tibble::tibble(word = tm::stopwords("english"), lexicon = "custom"),

                     # Custom stopwords
                     tibble::tibble(word = c(
                       "intro", "outro", "coro", "estribillo", "verso", "lyrics",
                       "chorus", "verse", "bridge",
                       "si", "pa", "na", "yeah", "yeh", "ey", "ah", "prr", "da", "va", "eh", "uh")
                     )
    )


  # Clean, get rid of stopwords, and filter
  DF_clean = DF_words |>

    # Delete everything between []
    # gsub("\\s*\\[[^\\)]+\\]", "", as.character(DF$songs[[.x]]$lyrics))

    # Trim white space
    dplyr::mutate(word = trimws(word)) |>

    # Ged rid of accents (Can't do it as we lose "ñ", and other important chars)
    dplyr::mutate(word = stringi::stri_trans_general(str = word, id = "Latin-ASCII")) |>

    # filter numbers
    dplyr::filter(!word %in% c(1:10000)) |>

    dplyr::count(word, name = "freq") |>

    dplyr::anti_join(custom_stop_words, by = dplyr::join_by(word)) |>

    dplyr::arrange(dplyr::desc(freq))

  return(DF_clean)

}


list_not_downloaded_artists <- function(input, location_jsons = "outputs/lyrics/") {
  # input = "outputs/DF/2025-07-30 07:18:27.301064 37i9dQZEVXbMDoHDwVN2tF.csv"

  if (grepl("\\.csv", input[1])) {

    DF = readr::read_csv(input, show_col_types = FALSE)

    DF_temp = DF|>

      # Fixes "Tyler, The Creator", SHOULD create a function to deal with a list of artists with a "," in their name
      dplyr::mutate(Artista =
                      dplyr::case_when(
                        grepl("^Tyler, The Creator, .*", Artista, ignore.case = TRUE) ~ gsub("(^Tyler, The Creator), (.*)", "Tyler The Creator, \\2", Artista),
                        grepl(".*, Tyler, The Creator, .*", Artista, ignore.case = TRUE) ~ gsub("(.*), (Tyler, The Creator), (.*)", "\\1, Tyler The Creator, \\3", Artista),
                        grepl(".*, Tyler, The Creator$", Artista, ignore.case = TRUE) ~ gsub("(.*), (Tyler, The Creator$)", "\\1, Tyler The Creator", Artista),
                        TRUE ~ Artista
                      )) |>
      tidyr::separate_longer_delim(Artista, delim = ", ") |>
      dplyr::count(Artista) |>
      dplyr::arrange(Artista)

  } else {
    DF_temp = tibble::tibble(Artista = input)
  }

  DF_Artistas = DF_temp |>
    dplyr::mutate(Artista_clean = gsub(" ", "", Artista) |> tolower() |> iconv(from = 'UTF-8', to = 'ASCII//TRANSLIT'),
                  Artista_clean = gsub("/", "", Artista_clean))

  ARTISTAS = DF_Artistas |> dplyr::pull(Artista_clean)

  JSONs = gsub("Lyrics_(.*?)\\.json", "\\1", list.files(location_jsons, pattern = "json")) |>
    tolower() |>
    iconv(from = 'UTF-8', to = 'ASCII//TRANSLIT')

  Artistas_missing =
    DF_Artistas |>
    dplyr::filter(Artista_clean %in% ARTISTAS[!ARTISTAS %in% JSONs]) |>
    dplyr::pull(Artista)

  return(Artistas_missing)
}


download_all_artists <- function(artists, min_s_wait = 5, max_s_wait = 20) {

  seq_along(artists) |>
    purrr::walk(~{
      cli::cli_alert_info("{.x}/{length(artists)}: {artists[.x]}")
      OUT = download_full_discography_safely(artists[.x])
      Sys.sleep(runif(1, min_s_wait, max_s_wait))
      return(OUT)
    })

  move_downloaded_lyrics()

}




song_is_in_lyrics <- function(name_song, filename = "outputs/DF_lyrics/DF_lyrics_ALL.gz") {

  # name_song = "amor"

  filename = here::here(filename)
  DF_ALL = data.table::fread(filename)

  # Fuzzy matching
  FOUND = agrep(
    name_song,
    DF_ALL$title,
    max.distance = 0.1,
    value = TRUE,
    ignore.case = TRUE,
    fixed = TRUE,
    costs = list(insertions = 0.2,
                 deletions = .5,
                 substitutions = 0))

  # Search for song in DF
  DF_out = DF_ALL[title %in% FOUND] |>
    dplyr::select(id, artists, title)

  return(DF_out)

}

move_downloaded_lyrics <- function() {

  downloaded = list.files(".", pattern = "json", full.names = TRUE)

  NUM = stringr::str_count(downloaded, pattern = "_")

  if (length(NUM) == 0) return(NULL)


  # 1 "_" is a full artist, 2 "_" is a specific song
  if (all(NUM == 1)) {
    destination = paste0("outputs/lyrics/", basename(downloaded))
  } else if (all(NUM == 2)) {
    destination = paste0("outputs/lyrics_individual_songs/", basename(downloaded))
  } else {
    cli::cli_abort("The number of '_' is not 1 or 2: {downloaded}")
  }

  file.rename(from = downloaded,
              to = destination)

}



save_experiment_materials <- function(DF_paragraphs, sample_n, filename_output = "stimuli.js") {
  # sample_n = 10

  # Create materials for experiment
  X1 = DF_paragraphs |>
    dplyr::sample_n(sample_n) |>
    dplyr::mutate(paragraph = gsub("\\n", "<BR>", paragraph))

  # Add js var and write
  paste0("var test_stimuli = ", jsonlite::toJSON(X1, POSIXt = "ISO8601")) |>
    readr::write_lines(filename_output)

}


combine_new_songs <- function(DF_main, DF_new, what) {

  # REVIEW: Not sure if we should return main or null
  if(nrow(DF_new) == 0) return(DF_main)

  # First time, only new songs
  if (is.null(DF_main)) {

    return(DF_new)

  } else {

    # Combine only new songs
    NEW_songs = DF_new |> dplyr::anti_join(DF_main, by = dplyr::join_by(id))


    if (what == "lyrics") {

      DF_ALL = DF_main |>
        # REVIEW as.character(release_date) SHOULD not be there. We loose the date format at some point
        # dplyr::mutate(release_date = as.character(release_date)) |>

        dplyr::bind_rows(NEW_songs) |>
        dplyr::distinct(id, .keep_all = TRUE) # Remove duplicates by id

    } else {

      DF_ALL = DF_main |>
        dplyr::bind_rows(NEW_songs) |>
        dplyr::mutate(id_temp = paste0(id, id_paragraph)) |>
        dplyr::distinct(id_temp, .keep_all = TRUE) |>  # Remove duplicates by id_temp
        dplyr::select(-id_temp)

    }

  }

return(DF_ALL)
}


update_main_DB <- function(DF_new, DF_current, filename_current, what) {

  if (!what %in% c("lyrics", "paragraphs")) cli::cli_abort("what SHOULD be either `lyrics` or `paragraphs`")


  if (!is.null(DF_new)) {

    DF_updated = combine_new_songs(DF_main = DF_current,
                                   DF_new = DF_new,
                                   what = what)

    if (!identical(DF_current, DF_updated)) {

      # Save new current file
      data.table::fwrite(DF_updated, file = filename_current)
      cli::cli_alert_info("{nrow(DF_updated)} new {what}")

      paste0(nrow(DF_new), " new lyrics")

    }

    # Delete temp file
    # temp_file = "outputs/DF_lyrics/DF_lyrics_NEW_temp.gz"
    # if (file.exists(temp_file)) file.remove(temp_file)


  } else {
    cli::cli_alert_info("NO {what} found")
    DF_updated = NULL
  }

  return(DF_updated)

}


move_lyrics_to_processed <- function(lyrics_jsons, move_lyrics_file_to = NULL, ...) {

  if (length(lyrics_jsons) == 1 & lyrics_jsons[1] == "inputs//README") return(NULL)

  # If not null, move json file to destination
  if (!is.null(move_lyrics_file_to) & !is.null(lyrics_jsons)) {

    lyrics_jsons = lyrics_jsons[!lyrics_jsons == "inputs//README"]

    if (!dir.exists(move_lyrics_file_to)) cli::cli_abort("{here::here(move_lyrics_file_to)} does not exist")
    zip(zipfile = paste0(move_lyrics_file_to, "/processed_lyrics.zip"),
        files = fs::as_fs_path(lyrics_jsons))



    # OUT = paste0(move_lyrics_file_to, "/", basename(lyrics_jsons))
    # fs::file_move(lyrics_jsons, OUT)

    file.remove(lyrics_jsons)

  }
}


read_DF_ALL <- function(filename_current, what) {

  if (!what %in% c("lyrics", "paragraphs")) cli::cli_abort("what SHOULD be either `lyrics` or `paragraphs`")

  # Actual filename and path will depend of `what`
  file_current = paste0("outputs/DF_", what, "/DF_", what, "_ALL.gz")

  if (file.exists(file_current)) { # Hardcoded above because filename_current is NULL the first time

    placeholder_file = paste0(tools::file_path_sans_ext(filename_current), ".placeholder")

    # Get rid of the template file. We needed so tar_files_input(filename_current,... does not fail
    filename_clean = filename_current[filename_current != placeholder_file]#"outputs/DF_lyrics//DF_lyrics_ALL.template"]

    #### REVIEW ####

    if (what == "paragraphs") {
      DF_ALL_current = data.table::fread(filename_clean) |>
        # as.integer(id) SHOULD not be there. fread reads it as character?
        dplyr::mutate(id = as.integer(id),
                      id_paragraph = as.integer(id_paragraph))
    } else {
      DF_ALL_current = data.table::fread(filename_clean) |>
        # as.character(release_date) SHOULD not be there. We loose the date format at some point
        dplyr::mutate(release_date = as.character(release_date))
    }

  } else {
    NULL
  }

  return(DF_ALL_current)
}



check_placeholder_files <- function() {

  # WE NEED empty placeholder files in inputs, outputs/DF_lyrics and
  # outputs/DF_paragraphs for tar_files_input() to work

  if (!file.exists("inputs/README")) file.create("inputs/README")
  if (!file.exists("outputs/DF_lyrics/DF_lyrics_ALL.placeholder")) file.create("outputs/DF_lyrics/DF_lyrics_ALL.placeholder")
  if (!file.exists("outputs/DF_paragraphs/DF_paragraphs_ALL.placeholder")) file.create("outputs/DF_paragraphs/DF_paragraph_ALL.placeholder")

  return("All placeholder files in place")

}

