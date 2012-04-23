setwd('/data/R/Bossa')
require(ggplot2)
require(multicore)

load('nova.db.Rdata')

# make sure things are unique
# nova.db <- do.call(rbind, lapply(unique(nova.db$time), function(i) subset(nova.db, time==i)[1,]))

# retrieve unique artists
u.artists <- sort(table(nova.db$artist))
df <- data.frame(Artiste=factor(names(tail(u.artists, 10)), levels=names(tail(u.artists, 10))),
                 Occurrences=tail(u.artists, 10))
p <- ggplot(df) + geom_bar(aes(x=Artiste, y=Occurrences)) + scale_x_discrete(labels=NULL) + theme_bw() + coord_flip() + geom_text(aes(x=Artiste, y=5, label=Artiste),  col='white', size=4, hjust=0)
png(file='top10artistes.png'); print(p); dev.off()

# retrieve unique artists/songs pairs
u.pairs <- sort(table(paste(nova.db$artist, nova.db$titre, sep=' | ')))

df <- data.frame(Chanson=factor(names(tail(u.pairs, 10)), levels=names(tail(u.pairs, 10))),
                 Occurrences=tail(u.pairs, 10))
p <- ggplot(df) + geom_bar(aes(x=Chanson, y=Occurrences)) + scale_x_discrete(labels=NULL) + theme_bw() + coord_flip() + geom_text(aes(x=Chanson, y=5, label=Chanson), col='white', size=4, hjust=0)
png(file='top10chansons.png'); print(p); dev.off()

# for each song, get week of diffusion
nova.db$wn <- with(nova.db, format(as.POSIXlt(as.numeric(time),origin='1970-01-01'), '%Y-%U'))
nova.db$pairs <- with(nova.db, paste(artiste, titre, sep=' | '))

df <- do.call(rbind, lapply(unique(nova.db$wn), function(w) {
  message('starting week ',w, ' (', round(100*which(w==unique(nova.db$wn))/length(unique(nova.db$wn)), 2), '%)')
  sub.nova.db <- subset(nova.db, wn==w)
  do.call(rbind, lapply(unique(nova.db$pairs), function(p) {
    data.frame(Week=w, Chanson=p, Count=length(which(with(sub.nova.db, pairs==p))), stringsAsFactors=F)
  }))
}))

p <- ggplot(df) + geom_tile(aes(x=Week, y=Chanson, fill=Count)) + scale_y_discrete(labels=NULL) + theme_bw() + opts(axis.ticks=theme_segment(size=0))
pdf('test.pdf'); print(p); dev.off();

# first diffusion date
u.pairs <- unique(paste(nova.db$artist, nova.db$titre, sep=' | '))

first.diffs <- do.call(c,mclapply(u.pairs, function(p) {
  min(as.numeric(subset(nova.db, paste(artiste, titre, sep=' | ')==p)$time)) }))
names(first.diffs) <- u.pairs
df <- data.frame(p=factor(names(sort(first.diffs)), levels=names(sort(first.diffs))),
                 fd=as.POSIXlt(sort(first.diffs), origin='1970-01-01'))
ggplot(df) + geom_point(aes(x=p, y=fd)) + theme_bw()

save.image(file='nova.analyse.Rdata')
