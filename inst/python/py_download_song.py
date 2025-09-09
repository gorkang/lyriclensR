# SHOULD store name_artist and NAME_DOWNLOADED! 
# - Can have a DB with name_artist, NAME_DOWNLOADED, number_songs, date_downloaded
# - CHECK this DB before downloading (parameter: check_first)

# https://pypi.org/project/lyricsgenius/
def py_download_song(name_artist, name_song):

  # Dependencies Installation
  # reticulate::py_install("lyricsgenius", method = "virtualenv")
  
  import lyricsgenius
  import os
  from datetime import datetime

  token = os.environ['GENIUS_TOKEN']
  genius = lyricsgenius.Genius(token, retries=2)
  
  print("Downloading '" + str(name_song) + " - " + str(name_artist) + "'")
  song = genius.search_song(name_song, name_artist)

  # Create output name
  name_output = str("outputs/lyrics_to_process/") + str(name_artist) + "_" + str(name_song) + " - " + str(song.artist) + "_" + str(song.title) + "_" + str(song.id) + "_" + str(1) + "_" + datetime.today().strftime('%Y-%m-%d') + ".json"

  # Save
  print("Saving '" + str(name_song) + " - " + str(name_artist) + "'" + " in " + str(name_output))
  song.save_lyrics(name_output, sanitize = False, overwrite=True) # sanitize FALSE so does not delete "/"
