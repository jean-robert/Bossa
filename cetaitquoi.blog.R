## data directory
setwd('/data/R/Bossa')
require(knitr)

## blog directory
## TODO

## action plan
## 1) load old data
load(file='nova.db.Rdata')
old.u.pairs <- sort(table(paste(nova.db$artist, nova.db$titre, sep=' | ')))

## 2) update data
source('cetaitquoi.R')

## 3) check if anything to publish
new.u.pairs <- sort(table(paste(nova.db$artist, nova.db$titre, sep=' | ')))

if(sum(!(names(new.u.pairs) %in% names(old.u.pairs)))>0) {
  ## 4) write article
  write.csv(subset(nova.db,
                   paste(artiste, titre, sep=' | ') %in% names(new.u.pairs)[!(names(new.u.pairs) %in% names(old.u.pairs))]),
            file='to.be.updated.csv')
#
#  filename <- paste(jobList$ID[job], Sys.Date(), '.html', sep='')
#                                        # knit the file
#  knit(input=jobList$knitrFile[job],
#       output=filename)

}

