library(foreach)
library(doParallel)

clades <- c("Chelicerata", "Myriapoda", "Ascomycota", "Plantae", "Mammalia", "Coleoptera")
setwd("~/Desktop")
ExecuteMarkdown <- function(x) {
  #rmarkdown::render("ParseNSFParameterized.Rmd", params = list(
   rmarkdown::render("test.Rmd", params = list(
      clade=x
  ))
}


registerDoParallel(cores=2)
foreach(i=clades) %do% ExecuteMarkdown(i)