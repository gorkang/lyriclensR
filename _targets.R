library(targets)
library(tarchetypes)

targets::tar_option_set(packages = c("tibble", "qs2", "lyriclensR"))

# Run the R scripts in R/
targets::tar_source()

# WE NEED empty placeholder files in outputs/lyrics_to_process, outputs/DF_lyrics and
# outputs/DF_paragraphs for tar_files_input() to work
check_placeholder_files()

# Targets list
list(

  # Process NEW FILES --------------------------------------------------------

  # Input json files
  tar_files_input(lyrics_jsons, list.files("outputs/lyrics_to_process/", full.names = TRUE)),

  # Create TEMP files with ALL input files
  tar_target(DF_lyrics_new, read_all_lyrics(lyrics_files = lyrics_jsons,
                                            daemons = 10)),

  tar_target(DF_paragraphs_new, separate_paragraphs(DF_lyrics = DF_lyrics_new,
                                                    filename_output = "outputs/DF_paragraphs/DF_paragraphs_ALL.gz")),


  # CURRENT FILES -----------------------------------------------------------

  # Main processed lyrics file
  # REVIEW: This way of getting filename_current_lyrics is a bit flimsy
  tar_files_input(filename_current_lyrics, list.files("outputs/DF_lyrics/", pattern = "DF_lyrics_ALL\\.", full.names = TRUE)),
  tar_target(DF_lyrics_current, read_DF_ALL(filename_current = filename_current_lyrics, what = "lyrics")),

  # Main processed paragraphs file
  # REVIEW: This way of getting filename_current_paragraphs is a bit flimsy
  tar_files_input(filename_current_paragraphs, list.files("outputs/DF_paragraphs/", pattern = "DF_paragraphs_ALL\\.", full.names = TRUE)),
  tar_target(DF_paragraphs_current, read_DF_ALL(filename_current = filename_current_paragraphs, what = "paragraphs")),



  # HITS --------------------------------------------------------------------
  tar_files_input(HITS_files, list.files("outputs/DF/", full.names = TRUE)),
  tar_target(raw_HITS_spotify, process_spotify_HITS(HITS_files)),

  tar_target(DF_HITS_raw, read_raw_hits(raw_HITS_spotify)),
  tar_target(DF_HITS_clean, clean_hits(DF_HITS_raw)),
  tar_target(DF_lyrics_current_CLEAN, clean_lyrics_current(DF_lyrics_current)),

  tar_target(DF_HITS_combined, combine_HITS_lyrics(DF_lyrics_current_CLEAN, DF_HITS_clean, DF_HITS_raw)),



  # UPDATE ------------------------------------------------------------------

  # Update main lyrics file if there are new lyrics
  tar_target(DF_lyrics_updated, update_main_DB(DF_new = DF_lyrics_new,
                                               DF_current = DF_lyrics_current,
                                               # Hardcoded because filename_current_DF is NULL the first time
                                               filename_current = "outputs/DF_lyrics/DF_lyrics_ALL.gz",
                                               what = "lyrics")),

  # Update main paragraphs file if there are new lyrics
  tar_target(DF_paragraphs_updated, update_main_DB(DF_new = DF_paragraphs_new,
                                                   DF_current = DF_paragraphs_current,
                                                   # Hardcoded because filename_current_DF is NULL the first time
                                                   filename_current = "outputs/DF_paragraphs/DF_paragraphs_ALL.gz",
                                                   what = "paragraphs")),
  # Clean up json files
  tar_target(MOVED_jsons, move_lyrics_to_processed(lyrics_jsons,
                                                   move_lyrics_file_to = "outputs/lyrics_processed/",
                                                   DF_lyrics_updated))

)
