library(targets)
library(tarchetypes)

tar_option_set(packages = c("tibble", "qs2", "lyriclensR"))

# Run the R scripts in R/
tar_source()

# TODO: Create them if not present
# WE NEED empty placeholder files in:
# - inputs/README
# - outputs/DF_lyrics//DF_lyrics_ALL.placeholder
# - outputs/DF_paragraph//DF_paragraph_ALL.placeholder

list(

  # Process NEW FILES --------------------------------------------------------

    # Input json files
    tar_files_input(lyrics_jsons, list.files("inputs/", full.names = TRUE)),

    # Create TEMP files with ALL input files
    tar_target(
      DF_lyrics_new, read_all_lyrics(
        lyrics_files = lyrics_jsons,
        daemons = 10
        # filename_output = "outputs/DF_lyrics/DF_lyrics_NEW_temp.gz"
        )
      ),



  # CURRENT FILES -----------------------------------------------------------

  # Main processed lyrics file
  tar_files_input(filename_current_lyrics, list.files("outputs/DF_lyrics/", pattern = "DF_lyrics_ALL\\.", full.names = TRUE)),
  tar_target(DF_lyrics_current, read_DF_ALL(filename_current = filename_current_lyrics, what = "lyrics")),

  # Main processed paragraphs file
  tar_files_input(filename_current_paragraphs, list.files("outputs/DF_paragraphs/", pattern = "DF_paragraphs_ALL\\.", full.names = TRUE)),
  tar_target(DF_paragraphs_current, read_DF_ALL(filename_current = filename_current_paragraphs, what = "paragraphs")),



  # UPDATE ------------------------------------------------------------------

  # Update main file if there are new lyrics
  tar_target(DF_updated, update_main_DB(DF_lyrics_new = DF_lyrics_new,
                                        DF_lyrics_current = DF_lyrics_current,
                                        # Hardcoded because filename_current_DF is NULL the first time
                                        filename_current_lyrics = "outputs/DF_lyrics/DF_lyrics_ALL.gz")
  ),

  # Clean up json files
  tar_target(MOVED_jsons, move_lyrics_to_processed(lyrics_jsons,
                                                   move_lyrics_file_to = "outputs/processed_lyrics/",
                                                   DF_updated))

)
