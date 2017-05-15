library(NSFgrantparser)
library(taxize)

load("NSF1980To2017Phylo.rda")

RunAnalysis <- function(focal.clade, data) {

  min.year=1980

  rank_ref <- taxize::rank_ref
  clade.info <- NULL
  try(clade.info <- NSFgrantparser::GetAllGrantDataForClades(c(focal.clade), data=data)[[1]])
  if(!is.null(clade.info)) {
  save(clade.info, file=paste0("GrantInfo_", focal.clade, ".zip"))
  all.investigator.names.df <- apply(clade.info[,which(grepl("LastName", names(clade.info)))], 2, as.character)
  all.investigator.names.vector <- unlist(all.investigator.names.df)
  all.investigator.names.vector <- all.investigator.names.vector[!is.na(all.investigator.names.vector)]
  local.result <- data.frame(title=clade.info$Award.AwardTitle, amount=clade.info$Award.AwardAmount, date=clade.info$Award.AwardEffectiveDate, PI=clade.info$Award.Investigator.LastName, abstract=clade.info$Award.AbstractNarration, directorate=clade.info$Award.Organization.Directorate.LongName, division=clade.info$Award.Organization.Division.LongName, investigators = paste(all.investigator.names.vector, collapse="|"), stringsAsFactors = FALSE)
  write.csv(local.result, file=paste0("GrantInfo_", focal.clade, ".csv"))
  }
}


clades <- c("Annelida", "Embryophyta", "Magnoliophyta", "Acrogymnospermae", "Polypodiopsida", "Bryophyta", "Plantae", "Hemiptera", "Odonata", "Blattodea", "Chelicerata", "Myriapoda", "Ascomycota", "Mammalia", "Coleoptera", "Basidiomycota", "Archaea", "Platyhelminthes", "Porifera", "Aves", "Nematoda", "Protozoa", "Tracheophyta", "Chromista", "Actinobacteria", "Lepidoptera", "Mollusca")



for(i in sequence(length(clades))) {
	try(RunAnalysis(clades[i], data))
}
