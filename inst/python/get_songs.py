# https://pypi.org/project/lyricsgenius/
def get_songs(name_artist):

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
  artist = genius.search_artist(name_artist, max_songs=1000, sort="popularity", get_full_info=True, include_features=True)
  
  print("Saving: " + str(name_artist))
  artist.save_lyrics()
  
# # Get all songs of La Pantera
# artist = genius.search_artist("La Pantera", max_songs=1000, sort="title")
# artist.save_lyrics()


# song = genius.search_song("To You", artist.name)
# print(song.lyrics)
# album = genius.search_album("Una semana increible", "La pantera")
# album.save_lyrics()
