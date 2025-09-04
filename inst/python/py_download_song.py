# https://pypi.org/project/lyricsgenius/
def py_download_song(name_artist, name_song):

  # Dependencies Installation
  # reticulate::py_install("lyricsgenius", method = "virtualenv")
  
  import lyricsgenius
  import os
  token = os.environ['GENIUS_TOKEN']
  genius = lyricsgenius.Genius(token, retries=2)
  
  print("Downloading '" + str(name_song) + " - " + str(name_artist) + "'")
  song = genius.search_song(name_song, name_artist)

  print("Saving '" + str(name_song) + " - " + str(name_artist) + "'")
  song.save_lyrics()
