#!/usr/bin/env Rscript
con <- file("stdin", open = "r")
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  key <- trimws(line)
  cat(key, "\t", 1, "\n", sep = "")
}
close(con)
