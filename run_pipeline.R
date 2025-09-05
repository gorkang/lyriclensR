# Visualize pipeline
targets::tar_visnetwork(label = "time", targets_only = TRUE)

# Needs to run 2 times because all the inputs are moved to processed and the change in inputs is detected
# We could change move_lyrics_to_processed() to avoid removing the input (?)
targets::tar_make()
targets::tar_make()

# Load all objects (takes a while!)
targets::tar_load_everything()

# Check size of DFs
nrow(DF_lyrics_new)
nrow(DF_lyrics_current)
nrow(DF_lyrics_updated)

nrow(DF_paragraphs_new)
nrow(DF_paragraphs_current)
nrow(DF_paragraphs_updated)


# Invalidate
# targets::tar_invalidate(DF_paragraphs_current)
