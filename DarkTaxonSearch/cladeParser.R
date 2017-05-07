library(rphylotastic)
data <- read.csv("clades.txt", header=FALSE, stringsAsFactors = FALSE)
data <- data[,1]
data <- data[which(nchar(data)>0)]
fractions <- rep(NA, length(data))
number.total <- rep(NA, length(data))
number.dark <- rep(NA, length(data))
number.known <- rep(NA, length(data))
result.names <- rep(NA, length(data))
for (i in sequence(length(data))) {
  taxon <- strsplit(gsub(':', " ", data[i])," ")[[1]]
  taxon <- taxon[length(taxon)]
  result.names[i] <- taxon
  local.results <- NULL
  try(local.results <- SeparateDarkTaxaGenbank(taxon))
  if(!is.null(local.results)) {
     fractions[i] <- local.results$fraction.dark
     number.total[i] <- length(local.results$dark) + length(local.results$known)
     number.dark[i] <- length(local.results$dark)
     number.known[i] <- length(local.results$known)
  }
  print(paste(result.names[i], fractions[i]))
  all.results <- data.frame(taxon=result.names[!is.na(fractions)], fraction.dark=fractions[!is.na(fractions)], number.total=number.total[!is.na(fractions)], number.dark=number.dark[!is.na(fractions)], number.known=number.known[!is.na(fractions)], stringsAsFactors=FALSE)
  write.csv(all.results, "GenbankInfo.csv")
}
