
## saveData wrapper function
#' @export
saveData <- function(data, storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    saveDataFlatfile(data, storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    saveDataGsheets(data, storage)
  }
}

## load Data wrapper
#' @export
loadData <- function(storage) {
  if (storage$type == STORAGE_TYPES$FLATFILE) {
    loadDataFlatfile(storage)
  } else if (storage$type == STORAGE_TYPES$GOOGLE_SHEETS) {
    loadDataGsheets(storage)
  }
}

# flat file : save
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

# flat file : load
loadDataFlatfile <- function(storage) {
  resultsDir <- storage$path
  files <- list.files(file.path(resultsDir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- do.call(rbind, data)
  return(data)
}

## GSHEETS : save
saveDataGsheets <- function(data, storage) {
  googlesheets::gs_add_row(gs_url(storage$url), input = data)
}

## GSHEETS : load
loadDataGsheets <- function(storage) {
  googlesheets::gs_read_csv(gs_url(storage$url))
}
