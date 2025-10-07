make_CS <- function(DF_lyrics_paragraphs_HITS, DF_lyrics_updated, DF_paragraphs_updated) {
# targets::tar_objects()
destination_folder = "~/gorkang@gmail.com_SHARED_WITH_ME/LyricLens AI/DB canciones/"

# targets::tar_load(c("DF_lyrics_paragraphs_HITS", "DF_lyrics_updated", "DF_paragraphs_updated"))
data.table::fwrite(DF_lyrics_paragraphs_HITS$DF_lyrics_HITS,paste0(destination_folder, "DF_lyrics_HITS.gz"))
data.table::fwrite(DF_lyrics_paragraphs_HITS$DF_paragraphs_HITS, paste0(destination_folder, "DF_paragraphs_HITS.gz"))
data.table::fwrite(DF_lyrics_updated, paste0(destination_folder, "DF_lyrics_updated.gz"))
data.table::fwrite(DF_paragraphs_updated, paste0(destination_folder, "DF_paragraphs_updated.gz"))

fs::dir_copy("outputs/lyrics_processed/",  paste0(destination_folder, "lyrics_processed/"))
fs::dir_copy("outputs/zips/",  paste0(destination_folder, "zips/"))
fs::dir_copy("outputs/DF/",  paste0(destination_folder, "DF/"))
# DF_lyrics_paragraphs_HITS, DF_lyrics_updated, DF_paragraphs_updated
# data.table::fwrite()

return(NULL)

}
