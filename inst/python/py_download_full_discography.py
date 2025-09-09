# https://pypi.org/project/lyricsgenius/
def py_download_full_discography(name_artist):

  # Dependencies Installation
  # reticulate::py_install("lyricsgenius", method = "virtualenv")
  
  import lyricsgenius
  import os
  from datetime import datetime

  token = os.environ['GENIUS_TOKEN']
  genius = lyricsgenius.Genius(token, retries=2)
  
  print("Downloading: " + str(name_artist))
  # Other parameters
  # remove_section_headers=False # If `True`, removes [Chorus], [Bridge], etc. headers from lyrics.
  artist = genius.search_artist(name_artist, max_songs=3000, sort="popularity", get_full_info=True, include_features=True)
  
  # Create output name
  name_output = str("outputs/lyrics_to_process/") + str(name_artist) + " - " + str(artist.name) + "_" + str (artist.id) + "_" + str (artist.num_songs) + "_" + datetime.today().strftime('%Y-%m-%d') + ".json"
  
  #Save
  print("Saving: " + str(name_artist) + " in " + str(name_output))
  artist.save_lyrics(name_output, sanitize = False, overwrite = True) # sanitize FALSE so does not delete "/"
