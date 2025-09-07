get_detais_elportaldemusica <- function(WEB) {

  # WEB = paste0("https://www.elportaldemusica.es/lists/top-100-canciones/2020")

  html_WEBS = rvest::read_html(WEB)
  number = html_WEBS|> rvest::html_elements(".publication_relevant") |> rvest::html_text2()
  song = html_WEBS|> rvest::html_elements(".name") |> rvest::html_text2()
  artist = html_WEBS|> rvest::html_elements(".related") |> rvest::html_text2()
  semanas = html_WEBS|> rvest::html_elements(".publication_details") |> rvest::html_text2()
  year = gsub(".*?([0-9]{4})$", "\\1", WEB)

  DF = tibble::tibble(year, number, song, artist, semanas)
  return(DF)
}
