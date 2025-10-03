#' process_html
#'
#' @param spotify_list_URL URL for Spotify list
#' @param DEBUG TRUE/FALSE, show songs in Console
#'
#' @returns A list with a DF and a vector of ARTISTS
#' @export
#'
#' @examples process_html("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9")
process_html <- function(spotify_list_URL, DEBUG = FALSE) {

  # spotify_list_URL = "https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9"
  # FILES = "outputs/zips/2025-09-27_37i9dQZEVXbNFJfN1Vw8d9/outputs/www/2025-09-27 08:25:55 37i9dQZEVXbNFJfN1Vw8d9.html"

  # ERRORS:
  # Tyler, The Creator # Is an author. It gets changed to: c("Tyler", "The creator") # DICCIONARY with exceptions?

  part_URL = gsub("/en/|/", "_", gsub("https://open.spotify.com/playlist/", "", spotify_list_URL))

  FILES = list.files("outputs/www/",
                     pattern = part_URL,
                     full.names = TRUE)

  page_source_rvest <- rvest::read_html(FILES[1])

  CAT = page_source_rvest |>
    rvest::html_elements(xpath = paste0('/html/body/div[4]/div/div[2]/div[6]/div/div[2]/div[1]/div/main/section/div[2]/div[3]/div/div[1]/div')) |>
    rvest::html_text2(preserve_nbsp = TRUE)

  TXT = gsub("\\n[0-9]:[0-9]{2}\\n([0-9]{1,3})", "\n\n", CAT)

  if (DEBUG) cat(TXT)

  # OLD method
  # TEMPfile = tempfile()
  # TXT |> readr::write_lines(TEMPfile)
  # XXX = readr::read_lines(TEMPfile, skip = 5) |>

  DF_temp = readr::read_lines(TXT, skip = 5) |>
    dplyr::as_tibble() |>
    dplyr::mutate(line = 1:dplyr::n())

  DF_output =
    DF_temp |>
    dplyr::mutate(X =
             # | line %in% c(1, 2)
               dplyr::case_when(
                 dplyr::lag(value == "") & dplyr::lag(n = 2, value == "") | line == 2 ~ "Cancion",
                 dplyr::lag(n = 2, value == "")  | line == 3  ~ "Artista",
                 dplyr::lag(n = 5, value == "") & dplyr::lag(n = 4, value == "")  | line == 5  ~ "Album",
               # lead(value == "") & lead(n = 2, value == "")  ~ "Album",
               TRUE ~ ""
             )) |>
    dplyr::filter(X != "") |>
    dplyr::select(-line) |>
    dplyr::mutate(N = rep(1:(dplyr::n()/3), each = 3)) |>
    tidyr::pivot_wider(names_from = X, values_from = value) |>

    # We eliminate the E (Explicit) from Cancion
    # REVIEW: This will probably fail in some cases, for example, songs that end with a capital E
    dplyr::mutate(Cancion =
                    dplyr::case_when(
                      # grepl("^E[A-Z0-9].*", Cancion) ~ gsub("E(.*)", "\\1", Cancion),
                      grepl("[A-Z0-9].*E$", Cancion) ~ gsub("(.*)E$", "\\1", Cancion, ignore.case = FALSE),
                      TRUE ~ Cancion
                    ))

  ARTISTAS = DF_output |>
    dplyr::select(Artista) |>
    tidyr::separate_longer_delim(Artista, delim = ",") |>
    dplyr::mutate(Artista = trimws(Artista)) |>
    dplyr::distinct(Artista) |>
    dplyr::arrange(Artista) |>
    dplyr::pull(Artista)

  # Save DF
  readr::write_csv(DF_output, paste0("outputs/DF/", Sys.time(), " ", part_URL, ".csv"))

  # Compress html files to zip and delete individual files
  FILES_today = list.files(path = "outputs/www", pattern = paste0(Sys.Date()), full.names = TRUE)
  ALL_FILES = FILES_today[grepl(part_URL, FILES_today)]
  zip(paste0("outputs/zips/", Sys.Date(), "_", part_URL, ".zip"), ALL_FILES)
  file.remove(ALL_FILES)

  OUTPUT = list(
    DF_output = DF_output,
    ARTISTAS = ARTISTAS
  )

  return(OUTPUT)
}
