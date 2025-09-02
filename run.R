
# Load all ----------------------------------------------------------------

# pak::local_install()
# library(lyriclensR)
devtools::load_all()



# GET Top50 songs ---------------------------------------------------------

  Top50 = get_and_process(WEB = "https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9")
  download_all_songs(Top50)


# Process all lyrics ------------------------------------------------------

  DF_ALL_es = process_all_lyrics(write_output = TRUE, language = "es")
  DF_ALL_es = process_all_lyrics(write_output = TRUE)



# Read data and save subset -----------------------------------------------

  n_subset = 100

  filename = here::here("outputs/DF_lyrics/DF_lyrics_ALL_es.gz")
  DF_ALL_es = data.table::fread(filename) |> tibble::as_tibble()

  set.seed(17)
  DF_ALL_es |>
    dplyr::slice_sample(n = n_subset) |>
    data.table::fwrite("outputs/DF_lyrics/DF_lyrics_es.gz")



# Get ALL songs from ALL artists ----------------------------------------------

  # Use this function with caution
  # Top50 Spain
  download_process_spotify_list("https://open.spotify.com/playlist/37i9dQZEVXbNFJfN1Vw8d9",
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

# Need to use DF_lyrics_ALL.gz" to have all the lyrics

rsconnect::deployApp(
  appFiles = c(
    "app.R",
    "R/search words.R",
    "R/helper_functions.R",
    "outputs/DF_lyrics/DF_lyrics_es.gz"
  ),
  appName = "lyriclensR"
)
