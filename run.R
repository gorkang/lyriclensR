
# Load all ----------------------------------------------------------------

# pak::local_install()
# library(lyriclensR)
devtools::load_all()


# Process all lyrics ------------------------------------------------------

lyrics = list.files("outputs/lyrics/", pattern = "json", full.names = TRUE)

# ALL Lyrics # 230 files - 47080 songs - 10 daemons - 31.5s
tictoc::tic()
DF_ALL = read_all_lyrics(lyrics, write_output = TRUE, daemons = 10)
tictoc::toc()

# Only Spanish
tictoc::tic()
DF_ALL = read_all_lyrics(lyrics, language = "es", write_output = TRUE, daemons = 10)
tictoc::toc()


filename = here::here("outputs/DF_lyrics/DF_lyrics.gz")
DF_ALL = data.table::fread(filename) |> tibble::as_tibble()

# Duplicated songs
DF_ALL |> dplyr::count(id) |> dplyr::filter(n>1) |> View()

download_process_spotify_list(spotify_list_URL = "https://open.spotify.com/playlist/3hdkI3sIYMAPTz2aXNgXt4",
                              only_new = FALSE,
                              continue_after_error = FALSE,
                              end_message = TRUE)

# Get all songs ------------------------------------------------------------------

# Top50 Spain
download_process_spotify_list("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9",
                              only_new = FALSE,
                              continue_after_error = FALSE,
                              end_message = TRUE)

# Top50 Global
download_process_spotify_list("https://open.spotify.com/playlist/37i9dQZEVXbMDoHDwVN2tF",
                              only_new = FALSE,
                              continue_after_error = FALSE,
                              end_message = TRUE)

# Billboard Hot 100
download_process_spotify_list("https://open.spotify.com/playlist/6UeSakyzhiEt4NB3UAd6NQ",
                              only_new = FALSE,
                              continue_after_error = FALSE,
                              end_message = TRUE)


# Get songs ---------------------------------------------------------------

  # Using a manual list

  # 1) List of artists
    Artists_manual = c("Tool", "Rosalia")

  # 2) List not already downloaded artists
    Artists_clean = list_not_downloaded_artists(input = Artists_manual)

  # 3) Download all artists Lyrics
    download_all_artists(Artists_clean)

  # 4) Move
    move_downloaded_lyrics()

  # 5) Process
    lyrics = list.files("outputs/lyrics/", pattern = "json", full.names = TRUE)
    DF_ALL = lyriclensR:::read_all_lyrics(lyrics, write_output = TRUE)



# Search words ------------------------------------------------------------

  # Using json of a single Artist created by read_lyrics()
  search_words(data = "outputs/lyrics/Lyrics_Tool.json",
               highlight_word = "love")

  # Using big DF with all lyrics created by read_all_lyrics()
  filename = here::here("outputs/DF_lyrics/DF_lyrics.gz")
  DF_ALL = data.table::fread(filename)
  search_words(data = DF_ALL, highlight_word = "amor")



# Create wordcloud --------------------------------------------------------

  lyrics_file = "outputs/lyrics/Lyrics_Tool.json"
  create_wordcloud(lyrics = lyrics_file)
  create_wordcloud(lyrics = dplyr::slice_sample(DF_ALL, n = 1000))


# STEP BY STEP -------------------------------------------

DF = read_lyrics(lyrics_file)
DF_words = extract_words(DF)
DF_freq = clean_words(DF_words)



DF_words = extract_words(DF_ALL, ngram = 1)
DF_freq = clean_words(DF_words)



search_words(data = DF_ALL,
             highlight_words = "letra")


DF_plot = DF_freq |> dplyr::filter(freq > 1000)

set.seed(1)
PLOT = wordcloud2::wordcloud2(DF_plot, size=1.6, color='random-dark')
PLOT



# Search songs ------------------------------------------------------------

# First steps towards looking for specific songs before downloading
DF_songs_found = song_is_in_lyrics("amor")



# Deploy app --------------------------------------------------------------

rsconnect::deployApp(
  appFiles = c(
    "app.R",
    "R/search words.R",
    "R/helper_functions.R",
    "outputs/DF_lyrics/DF_lyrics.gz"
  ),
  appName = "lyriclensR"
)
