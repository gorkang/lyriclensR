# Get music lists with top Hits

# El portal de musica -----------------------------------------------------

  # Main source 2009-2024
  # https://www.elportaldemusica.es/lists/top-100-canciones/2024

  # Semanales
  # Numero final (semana) 1:52
  # https://www.elportaldemusica.es/lists/top-100-canciones/2009/34
  # https://www.elportaldemusica.es/lists/top-100-canciones/2025/35

  #Anuales
  # 2009:2024
  # WEB = "https://www.elportaldemusica.es/lists/top-100-canciones/2024"


years = c(2009:2024)
WEBS = paste0("https://www.elportaldemusica.es/lists/top-100-canciones/", years)


ALL = seq_along(WEBS) |>
  purrr::map_df(~{
    cli::cli_alert_info("{WEBS[.x]}")
    get_detais_elportaldemusica(WEBS[.x])

  })


# ERRORS
# Billie the vision & the dancers -> Billie the vision , the dancers
# Fito y Los Fitipaldis -> Fito , Los Fitipaldis
# ALL = read.csv("outputs/song_lists/elportaldemusica_artists_2009-2024.csv")
ALL_artists = ALL |>
  # dplyr::select(artist) |>
  dplyr::mutate(
    id = paste0(number, "_", year),
    artist = gsub("[|/&]", ",", artist),
    artist = gsub("featuring|feat\\.|feat|ft.", ", ", artist, ignore.case = TRUE),
    artist = gsub(" y ", ", ", artist)) |>
  tidyr::separate_longer_delim(artist, ",") |>
  dplyr::mutate(artists = trimws(artist)) |>
  dplyr::select(id, dplyr::everything())


ARTISTS = ALL_artists |> dplyr::distinct(artists)


ALL |> readr::write_csv("outputs/song_lists/DF_elportaldemusica_2009-2024.csv")
ARTISTS |> readr::write_csv("outputs/song_lists/elportaldemusica_artists_2009-2024.csv")




# Los 40 principales ------------------------------------------------------

# 2024:
#   - https://open.spotify.com/intl-es/album/0u7U1gJ3AdW9WJLw4Uok41

# 2023:
#   - https://open.spotify.com/intl-es/album/5fl9rZ0t8V1qfgPvQR1Qma

# 2022:
#   - https://open.spotify.com/intl-es/album/1H2TYroUcGOyZpjtfeX3pd?go=1&nd=1&dlsi=73cfabc7dd844ff2

# 2021:
#   - https://open.spotify.com/intl-es/album/5S0axnA4nLMK6Vsc5tlH30

# 2019:
#   - https://open.spotify.com/intl-es/album/579orUP3c1qnjExoqh7Rd5

# 2016:
#   - https://open.spotify.com/intl-es/album/00PkuYKHhLVnislnJUMhKe


