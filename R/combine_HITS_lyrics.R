combine_HITS_lyrics <- function(DF_lyrics_current_CLEAN, DF_HITS_clean, DF_HITS_raw) {

  # targets::tar_load(c("DF_lyrics_current_CLEAN", "DF_HITS_clean"))

  # WITH SONG AND ARTIST
  # 2025/09/26: 1700
  DF_final_FOUND = DF_lyrics_current_CLEAN |>
    dplyr::inner_join(DF_HITS_clean,
                      by = dplyr::join_by(ID))



  # Not found
  # 2025/09/26: 1729
  DF_final_NOT_FOUND = DF_HITS_clean |>
    dplyr::anti_join(DF_final_FOUND, by = dplyr::join_by(ID))

  # Print how many found
  proportion_found(DF_HITS_clean, DF_HITS_raw, DF_final_NOT_FOUND)


  OUTPUT = list(DF_final_FOUND = DF_final_FOUND,
                DF_final_NOT_FOUND = DF_final_NOT_FOUND)

  return(OUTPUT)
}
