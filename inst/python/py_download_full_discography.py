# https://pypi.org/project/lyricsgenius/
def py_download_full_discography(name_artist):

  # Dependencies Installation
  # reticulate::py_install("lyricsgenius", method = "virtualenv")
  
  import lyricsgenius
  import os
  token = os.environ['GENIUS_TOKEN']
  genius = lyricsgenius.Genius(token, retries=2)
  
  print("Downloading: " + str(name_artist))
  # Other parameters
  # allow_name_change=True
  # remove_section_headers=False # If `True`, removes [Chorus], [Bridge], etc. headers from lyrics.
  artist = genius.search_artist(name_artist, max_songs=3000, sort="popularity", get_full_info=True, include_features=True)
  
  #Save
  print("Saving: " + str(name_artist))
  artist.save_lyrics()
