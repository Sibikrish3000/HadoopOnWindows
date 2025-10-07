#!/usr/bin/env Rscript
con <- file("stdin", open = "r")
counts <- list()
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  fields <- strsplit(line, "\t")[[1]]
  key <- fields[1]
  value <- as.numeric(fields[2])
  counts[[key]] <- ifelse(is.null(counts[[key]]), value, counts[[key]] + value)
}
close(con)
for (k in names(counts)) {
  cat(k, "\t", counts[[k]], "\n", sep = "")
}
