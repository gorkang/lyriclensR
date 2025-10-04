process_html <- function(spotify_list_URL, location_html = "outputs/www/") {

  # spotify_list_URL = "https://open.spotify.com/playlist/37i9dQZEVXbMDoHDwVN2tF"
  # FILES = "outputs/zips/2025-09-27_37i9dQZEVXbNFJfN1Vw8d9/outputs/www/2025-09-27 08:25:55 37i9dQZEVXbNFJfN1Vw8d9.html"

  part_URL = gsub("/en/|/", "_", gsub("https://open.spotify.com/playlist/", "", spotify_list_URL))

  FILES = list.files(location_html,
                     pattern = part_URL,
                     full.names = TRUE)


  cli::cli_alert_info("{FILES[1]}")
  DATE = gsub("([0-9]{4}-[0-9]{2}-[0-9]{2}).*", "\\1", basename(FILES[1]))
  page_source_rvest <- rvest::read_html(FILES[1])

  # Extract information from links
  LINKS <-
    page_source_rvest |>
    rvest::html_nodes('a') |>
    rvest::html_attr('href')

  CONTENT <-
    page_source_rvest |>
    rvest::html_nodes('a') |>
    rvest::html_text2()

  # Prepare data
  DF_output =
    tibble::tibble(links_raw = LINKS,
                   content = CONTENT) |>
    dplyr::mutate(what =
                    dplyr::case_when(
                      grepl("/track/", links_raw) ~ "track",
                      grepl("/artist/", links_raw) ~ "artist",
                      grepl("/album/", links_raw) ~ "album",
                      TRUE ~ NA
                    )) |>
    tidyr::drop_na(what) |>
    dplyr::mutate(song_id = cumsum(what == "track"),
                  links = gsub("/[a-z]{5,10}/(.*)", "\\1", links_raw)) |>

    tidyr::pivot_wider(
      id_cols = song_id,
      names_from = what,
      values_from = c(content, links),
      # collapse multiple artists into one string
      values_fn = function(x) paste(x, collapse = " || ")) |>
    dplyr::rename(
      song = content_track,
      artist = content_artist,
      album = content_album
    )

  # Unique artists
  ARTISTS = DF_output |> dplyr::select(artist, links_artist) |>
    tidyr::separate_longer_delim(c(artist, links_artist), delim = " || ") |>
    dplyr::distinct(artist) |>
    dplyr::arrange(artist) |>
    dplyr::pull(artist)


  # Save DF
  folder_DFs = paste0("outputs/DF/", part_URL, "/")
  if (!dir.exists(folder_DFs)) dir.create(folder_DFs, recursive = TRUE)
  readr::write_csv(DF_output, paste0(folder_DFs, Sys.Date(), " ", part_URL, ".csv"))

  # Compress html files to zip and delete individual files
  folder_ZIPs = paste0("outputs/zips/", part_URL, "/")
  if (!dir.exists(folder_ZIPs)) dir.create(folder_ZIPs, recursive = TRUE)

  FILES_today = list.files(path = location_html, pattern = paste0(Sys.Date()), full.names = TRUE)
  ALL_FILES = FILES_today[grepl(part_URL, FILES_today)]

  ALL_FILES = FILES[1]

  zip(zipfile = paste0(folder_ZIPs, Sys.Date(), " ", part_URL, ".zip"), files = ALL_FILES,
      flags = "--junk-paths") # Do not save the folders where the file is
  file.remove(ALL_FILES)

  OUTPUT = list(
    DF_output = DF_output,
    ARTISTS = ARTISTS
  )

  return(OUTPUT)

}
