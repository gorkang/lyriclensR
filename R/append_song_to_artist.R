append_song_to_artist <- function(artist_json, song_json) {

  # https://lyricsgenius.readthedocs.io/en/master/usage.html

  # artist_json = "Lyrics_OvyOnTheDrums.json"
  # song_json = "lyrics_ovyonthedrums_yoytú.json"

  # Read artist
  lyrics_artist_file = paste0("outputs/lyrics/", artist_json)
  LIST_lyrics_artist = jsonlite::read_json(lyrics_artist_file)

  DF_lyrics_artist = lyriclensR:::read_lyrics(lyrics = lyrics_artist_file)

  # length(DF$songs)
  # cat(DF$songs[[1]]$lyrics)
  # seq_along(DF$songs) |> purrr::map(~ DF$songs[[.x]]$title)

  # Read song
  # get_individual_songs_safely("Ovy on the drums", "Yo y Tú")
  # move_downloaded_lyrics()
  lyrics_song_file = paste0("outputs/lyrics_individual_songs/", song_json)
  LIST_lyrics_song = jsonlite::read_json(lyrics_song_file)

  # LIST_lyrics_song$artist
  # LIST_lyrics_song$title

  DF_filtered = DF_lyrics_artist |>
    dplyr::filter(artist == LIST_lyrics_song$artist) |>
    dplyr::filter(title == LIST_lyrics_song$title)

  SONG_EXISTS = nrow(DF_filtered) > 0


  if (!SONG_EXISTS) {

    # Append to songs
    LIST_lyrics_artist_UPDATED_songs = append(LIST_lyrics_artist$songs, list(LIST_lyrics_song))
    # length(LIST_lyrics_artist$songs)
    length(LIST_lyrics_artist_UPDATED_songs)
    # add to original artist DF
    LIST_lyrics_artist$songs = LIST_lyrics_artist_UPDATED_songs

  }


  DF_ALL =
    seq_along(LIST_lyrics_artist_UPDATED) |>
    purrr::map_df(
      ~ {
        # .x = 1
        tibble::tibble(
          id = LIST_lyrics_artist$songs[[.x]]$id,
          language = LIST_lyrics_artist$songs[[.x]]$language,
          release_date = LIST_lyrics_artist$songs[[.x]]$release_date,
          pageviews = LIST_lyrics_artist$songs[[.x]]$stats$pageviews,
          lyrics_state = LIST_lyrics_artist$songs[[.x]]$lyrics_state,
          artist = LIST_lyrics_artist$songs[[.x]]$artist,
          artists = LIST_lyrics_artist$songs[[.x]]$artist_names,
          title =  LIST_lyrics_artist$songs[[.x]]$title,
          lyrics_raw = as.character(LIST_lyrics_artist$songs[[.x]]$lyrics),
          lyrics = gsub(".*?Lyrics.*?\\n(.*)", "\\1", lyrics_raw),
          link = paste0("https://genius.com", LIST_lyrics_artist$songs[[.x]]$path)
        )

      }) |>
    dplyr::mutate(lyrics = gsub("La letra estará completa cuando salga la canción", "", lyrics))

  DF_ALL

}
