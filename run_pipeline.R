# Visualize pipeline
targets::tar_visnetwork(exclude = tidyselect::ends_with("_files") ,
                        label = c("time", "size"), targets_only = TRUE)
# targets::tar_meta()
# targets::tar_manifest()$name
# Needs to run 2 times because all the outputs/lyrics_to_process/ are moved to
# outputs/lyrics_processed/ and the change in outputs/lyrics_to_process/ is detected
# We could change move_lyrics_to_processed() to avoid removing the input (?)
targets::tar_make()
targets::tar_make()


# CHECK how maybe we are overlapping ID labels
  # total_HITS is decreasing!

# total_HITS found not_found PCT_found date
# 3689  1807      1882     0.490  2025-09-28
# 3689  1810      1879     0.491  2025-09-28
# 3689  2817       872     0.764  2025-09-30
# 3688  2822       866     0.765 2025-09-30
# 3674  2843       831     0.774 2025-09-30
# 3648  2855       793     0.783 2025-09-30




# Load all objects (takes a while!)
# targets::tar_load_everything()
targets::tar_load("DF_lyrics_current")
targets::tar_load("DF_lyrics_new")

targets::tar_load("DF_HITS_matched")
targets::tar_load("DF_HITS_raw")
targets::tar_load("DF_HITS_clean")
# DF_HITS_raw |> dplyr::count(source)

TOTAL_raw = DF_HITS_clean |> nrow()
EXPLICIT_extra = DF_HITS_raw |> dplyr::filter(grepl("Explicit", source)) |> nrow()
TOTAL_clean = TOTAL_raw - EXPLICIT_extra
NOT_found = DF_HITS_matched$DF_final_NOT_FOUND |> nrow()
FOUND = TOTAL_clean - NOT_found

# DF_HITS_matched$DF_final_FOUND |> View()
# DF_HITS_matched$DF_final_NOT_FOUND

# Check size of DFs
nrow(DF_lyrics_new)
nrow(DF_lyrics_current)
nrow(DF_lyrics_updated)


