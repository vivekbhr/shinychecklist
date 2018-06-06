
saveData <- function(data, storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    saveDataFlatfile(data, storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    saveDataGsheets(data, storage)
  }
}

loadData <- function(storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    loadDataFlatfile(storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    #loadDataGsheets(storage)
  }
}
saveDataFlatfile <- function(data, storage) {
  fileName <- paste0(
    paste(
      format(Sys.time(), "%Y%m%d-%H%M%OS"),
      digest::digest(data, algo = "md5"),
      sep = "_"
    ),
    ".csv"
  )
  
  resultsDir <- storage$path
  
  # write out the results
  write.csv(x = data, file = file.path(resultsDir, fileName),
            row.names = FALSE, quote = TRUE)
}
loadDataFlatfile <- function(storage) {
  resultsDir <- storage$path
  files <- list.files(file.path(resultsDir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- do.call(rbind, data)
  
  data
}

saveDataGsheets <- function(data, storage) {
  gs_add_row(gs_key(storage$key), input = data)
}
loadDataGsheets <- function() {
  gs_read_csv(gs_key(storage$key))
}
