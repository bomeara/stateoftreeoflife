library(rphylotastic)
data <- read.csv("clades.txt", header=FALSE, stringsAsFactors = FALSE)
data <- data[,1]
data <- data[which(nchar(data)>0)]
taxa <- unlist(strsplit(gsub(':', " ", data)," "))
taxa <- unique(taxa[which(nchar(taxa)>2)])
fractions <- rep(NA, length(taxa))
number.total <- rep(NA, length(taxa))
number.dark <- rep(NA, length(taxa))
number.known <- rep(NA, length(taxa))
result.names <- rep(NA, length(taxa))
for (i in sequence(length(taxa))) {
  taxon <- taxa[i]
  result.names[i] <- taxon
  local.results <- NULL
  try(local.results <- SeparateDarkTaxaGenbank(taxon, sleep=3))
  if(!is.null(local.results)) {
     save(local.results, file=paste0("names_",taxon,".gzip"), compress=TRUE)
     fractions[i] <- local.results$fraction.dark
     number.total[i] <- length(local.results$dark) + length(local.results$known)
     number.dark[i] <- length(local.results$dark)
     number.known[i] <- length(local.results$known)
  }
  print(paste(result.names[i], fractions[i]))
  all.results <- data.frame(taxon=result.names[!is.na(fractions)], fraction.dark=fractions[!is.na(fractions)], number.total=number.total[!is.na(fractions)], number.dark=number.dark[!is.na(fractions)], number.known=number.known[!is.na(fractions)], stringsAsFactors=FALSE)
  write.csv(all.results, "GenbankInfo.csv")
}
