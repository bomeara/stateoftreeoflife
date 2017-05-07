library(NSFgrantparser)
library(taxize)

load("NSF1980To2017Phylo.rda")

RunAnalysis <- function(focal.clade, data) {

  min.year=1980

  rank_ref <- taxize::rank_ref
  clade.info <- NULL
  try(clade.info <- NSFgrantparser::GetAllGrantDataForClades(c(focal.clade), data=data)[[1]])
  if(!is.null(clade.info)) {
  save(clade.info, file=paste0("~/Desktop/GrantInfo_", focal.clade, ".rda"))
  local.result <- data.frame(title=clade.info$Award.AwardTitle, amount=clade.info$Award.AwardAmount, date=clade.info$Award.AwardEffectiveDate, PI=clade.info$Award.Investigator.LastName, abstract=clade.info$Award.AbstractNarration, directorate=clade.info$Award.Organization.Directorate.LongName, division=clade.info$Award.Organization.Division.LongName, stringsAsFactors = FALSE)
  write.csv(local.result, file=paste0("~/Desktop/GrantInfo_", focal.clade, ".csv"))
  }
}


clades <- c("Hemiptera", "Odonata", "Blattodea", "Chelicerata", "Myriapoda", "Ascomycota", "Plantae", "Mammalia", "Coleoptera", "Basidiomycota", "Archaea", "Platyhelminthes", "Porifera", "Aves", "Nematoda", "Protozoa", "Tracheophyta", "Chromista", "Actinobacteria", "Lepidoptera", "Mollusca", "Annelida")



for(i in sequence(length(clades))) {
	try(RunAnalysis(clades[i], data))
}
