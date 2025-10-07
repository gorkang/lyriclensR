make_CS <- function(DF_lyrics_paragraphs_HITS, DF_lyrics_updated, DF_paragraphs_updated) {

  if (any(is.null(c(DF_lyrics_paragraphs_HITS, DF_lyrics_updated, DF_paragraphs_updated)))) return(NULL)

  destination_folder = "~/gorkang@gmail.com_SHARED_WITH_ME/LyricLens AI/DB canciones/"

  # targets::tar_load(c("DF_lyrics_paragraphs_HITS", "DF_lyrics_updated", "DF_paragraphs_updated"))
  # data.table::fwrite(DF_lyrics_paragraphs_HITS$DF_lyrics_HITS,paste0(destination_folder, "DF_lyrics_HITS.gz"))
  # data.table::fwrite(DF_lyrics_paragraphs_HITS$DF_paragraphs_HITS, paste0(destination_folder, "DF_paragraphs_HITS.gz"))
  # data.table::fwrite(DF_lyrics_updated, paste0(destination_folder, "DF_lyrics_updated.gz"))
  # data.table::fwrite(DF_paragraphs_updated, paste0(destination_folder, "DF_paragraphs_updated.gz"))

  if (dir.exists(destination_folder)) {
    fs::dir_copy("outputs/DF_lyrics/",  paste0(destination_folder, "DF_lyrics/"), overwrite = TRUE)
    fs::dir_copy("outputs/DF_paragraphs/",  paste0(destination_folder, "DF_paragraphs/"), overwrite = TRUE)
    fs::dir_copy("outputs/lyrics_processed/",  paste0(destination_folder, "lyrics_processed/"), overwrite = TRUE)
    fs::dir_copy("outputs/zips/",  paste0(destination_folder, "zips/"), overwrite = TRUE)
    fs::dir_copy("outputs/DF/",  paste0(destination_folder, "DF/"), overwrite = TRUE)
  }

  return(NULL)

}
