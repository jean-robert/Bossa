## settings
setwd('/data/R/Bossa')
require(knitr)

## action plan
## 1) load old data
load(file='nova.db.Rdata')
old.u.pairs <- unique(paste(nova.db$artist, nova.db$titre, sep=' | '))

## 2) update data
source('cetaitquoi.after.R')

## 3) check if anything to publish
new.u.pairs <- unique(paste(nova.db$artist, nova.db$titre, sep=' | '))

for(this.pair in new.u.pairs[!(new.u.pairs %in% old.u.pairs)]) {

  r <- which(with(nova.db, paste(artiste, titre, sep=' | '))==this.pair)[1]
  
  ## 4) write post for the new song
  TBU <- nova.db[r, ]
  save(TBU, file='TBU.Rdata')
  
  filename <- with(nova.db[r,],
                   paste(format(as.POSIXlt(as.numeric(time), origin='1970-01-01'), '%Y-%m-%d-%H-%M'), '-',
                         gsub('[ [:punct:]]', '-', artiste), '-',
                         gsub('[ [:punct:]]', '-', titre), '.md', sep=''))

                                        # knit the file
  knit(input='anewsong_knit_.md',
       output=filename)
                                        # push the post to the website
  tmpf <- tempfile()
  system(paste('mv', filename, tmpf))
  system('git checkout gh-pages')
  system(paste('mv', tmpf, paste('_posts/',filename,sep='')))
  system(paste('git add', paste('_posts/',filename,sep='')))
  system(paste("git commit -m 'adding a new song: ", gsub('[ [:punct:]]', ' ', nova.db[r, 'artiste']), '-',
               gsub('[ [:punct:]]', ' ', nova.db[r,'titre']), "'", sep=''))
  system('git checkout master')

}

system('git push origin gh-pages')
