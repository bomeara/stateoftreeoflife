
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(cache=FALSE)
library(NSFgrantparser)
library(taxize)
library(pander)
library(rphylotastic)
library(geiger)
library(ape)
library(phytools)
library(wordcloud2)
library(tm)
library(SnowballC)
library(webshot)
library(htmlwidgets)
webshot::install_phantomjs()

files <- system("ls -1 GrantInfo_*.csv", intern=TRUE)
clade.names <- gsub("GrantInfo_","", gsub(".csv", "", files))

summary.df <- data.frame()
aggregate.df <- data.frame()
for (clade.index in sequence(length(clade.names))) {
    print(paste("loading", clade.names[clade.index]))
    clade.info <- read.csv(files[clade.index], stringsAsFactors=FALSE)

    local.df <- data.frame(clade=clade.names[clade.index], number.grants=nrow(clade.info), total.grants=sum(clade.info$amount), median.grant=median(clade.info$amount), mean.grant=mean(clade.info$amount), PIs=paste(clade.info$PI, collapse=", "), all.investigators=paste(gsub("\\|", ",", clade.info$investigators), collapse=", "), stringsAsFactors=FALSE)
    summary.df <- rbind(summary.df, local.df, stringsAsFactors=FALSE)
    clade.info$taxon <- clade.names[clade.index]
    aggregate.df <- rbind(aggregate.df, clade.info, stringsAsFactors=FALSE)
}
write.csv(summary.df, file="SummarizedGrantInfo.csv")
write.csv(aggregate.df, file="IndividualGrantInfo.csv")
#pander(summary.df[,-ncol(summary.df)])
clade.names <- unique(aggregate.df$taxon)
for (clade.index in sequence(length(clade.names))) {
    clade.df <- subset(aggregate.df, taxon==clade.names[clade.index])
    dissertation.df <- clade.df[grepl("dissertation", clade.df$title, ignore.case=TRUE),]
    if(nrow(dissertation.df)>0) {
        write.csv(dissertation.df, file=paste0("DissertationGrantInfo_", clade.names[clade.index], ".csv"))
    }
    person.info <- data.frame()
    all.people <- c()
    for (grant.index in sequence(nrow(clade.df))) {
        people <- strsplit(clade.df$investigators[grant.index], "\\|")[[1]]
        all.people <- c(all.people, people)
        amount.per.person <- clade.df$amount[grant.index]/length(people)
        person.info <- rbind(person.info, data.frame(word=people, freq=round(amount.per.person), stringsAsFactors = FALSE), stringsAsFactors=FALSE)
    }
    money.by.person <- data.frame()
    unique.people <- unique(all.people)
    for (person.index in sequence(length(unique.people))) {
        money.by.person <- rbind(money.by.person, data.frame(word=unique.people[person.index], freq=sum(subset(person.info, word==unique.people[person.index])$freq), stringsAsFactors=FALSE))
    }
    cat(as.character(clade.names[clade.index]))
    all.people.df <- data.frame(table(all.people))
    names(all.people.df) <- c("word", "freq")
    all.words <- VCorpus(VectorSource(removePunctuation(paste(unlist(c(clade.df$title, clade.df$abstract)), collapse=" "))))
    all.words <- tm_map(all.words, content_transformer(tolower))
    all.words <- tm_map(all.words, removeWords, stopwords("english"))
    all.words <- tm_map(all.words, removeWords, c("will", "also"))

    all.words <- tm_map(all.words, stripWhitespace)
    #all.words <- tm_map(all.words, stemDocument)
    all.words.df <- data.frame(table(strsplit(as.character(all.words[[1]]), " ")[[1]]))
    names(all.words.df) <- c("word", "freq")
    if(nrow(all.words.df)>1000) {
     all.words.df <- all.words.df[order(all.words.df$freq, decreasing=TRUE),]
     all.words.df <- all.words.df[1:1000,]

    }

    money.by.person <- money.by.person[order(money.by.person$freq, decreasing=TRUE),]
    all.people.df <- all.people.df[order(all.people.df$freq, decreasing=TRUE),]


    my_graph =     wordcloud2(all.words.df)
    saveWidget(my_graph,"tmp.html",selfcontained = F)
    webshot("tmp.html",paste0("Figure_",clade.names[clade.index],"_Words.pdf"), delay =5, vwidth = 480, vheight=480)


    my_graph =     wordcloud2(money.by.person)
    saveWidget(my_graph,"tmp.html",selfcontained = F)
    webshot("tmp.html",paste0("Figure_",clade.names[clade.index],"_PeopleByMoney.pdf"), delay =5, vwidth = 480, vheight=480)



    my_graph =     wordcloud2(all.people.df)
    saveWidget(my_graph,"tmp.html",selfcontained = F)
    webshot("tmp.html",paste0("Figure_",clade.names[clade.index],"_PeopleByNumberOfGrants.pdf"), delay =5, vwidth = 480, vheight=480)

    system("/usr/local/bin/git commit -m'updated figures' -a")
    system("/usr/local/bin/git push")
}
