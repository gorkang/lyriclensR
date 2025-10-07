# WIP: Would be nice to know how many songs before downloading
# Also, genius.search_artists(name_artist) gives list of similar named artists.
# SHOULD store name_artist and NAME_DOWNLOADED! 
# - Can have a DB with name_artist, NAME_DOWNLOADED, number_songs, date_downloaded
# - CHECK this DB before downloading (parameter: check_first)

# https://pypi.org/project/lyricsgenius/
def py_number_songs_artist(name_artist):

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
  # artist = genius.search_artist(name_artist, max_songs=3000, sort="popularity", get_full_info=True, include_features=True)

  # Finds lists of artists similar to string
  # name_artist = "Malu"
  ARTISTS = genius.search_artists(name_artist, page=1)
  ID = ARTISTS["sections"][0]["hits"][0]["result"]["id"]
  SONGS = genius.artist_songs(ID, per_page=50, page = 1)
  SONGS = genius.artist_songs(ID, per_page=50, page = 2)
  print(SONGS)
  print(ARTISTS)
  
  # ARTISTS["sections"][0]["hits"][5]["result"]["id"]
  # len(  ARTISTS["sections"][0]["hits"])
  # ARTISTS["sections"][0]["hits"][5]["result"]["name"]
  

  
  #Save
  # print("Saving: " + str(name_artist))
  # artist.save_lyrics()
