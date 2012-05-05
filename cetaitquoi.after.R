
# recupere les chansons sur nova après une certaine heure

setwd('~/Rwork/Bossa')
require(multicore)

named.p <- paste('<div id=\"',
                 '(?<time>[0-9]+)\"',
                 ' class=\"resultat\"><span id=date>[0-9]+H[0-9]+</span>',
                 '<span id=\"artiste\"><a href=\"[A-Za-z[:punct:]]+\">',
                 '(?<artiste>[A-Za-z [:punct:]]+)',
                 '</a></span><span id=\"titre\">',
                 '(?<titre>[A-Za-z [:punct:]]+)',
                 '</span>', sep="")

                                        # We need to loop on times
getSongsAfter <- function(d) {
  message('Retrieving songs from ', d)
  cdate <- as.numeric(Sys.time())
  lastcdate <- 0
  edate <- d # end date
  ans <- NULL
  while(cdate > edate) {
    message('Trying ', format(as.POSIXlt(cdate, origin='1970-01-01'),"%Y-%m-%d %H:%M"))
    novaSearch <- tryCatch(paste(readLines(paste("http://www.novaplanet.com/cetaitquoicetitre/radionova/", cdate, sep="")), collapse="/n"),
                           error=function(e) { "riendutout" })
                                        # Finding the bits we want
    locs <- gregexpr(named.p, novaSearch, perl=T)[[1]]
    if(locs[1]<0) {
      cdate <- 0
    } else {
      ans <- rbind(ans, do.call(rbind, lapply(1:length(locs), function(i) {
        preans <- sapply(1:length(attr(locs, "capture.names")), function(j) {
          substr(novaSearch, attr(locs, "capture.start")[i,j], attr(locs, "capture.start")[i,j] + attr(locs, "capture.length")[i,j] - 1) })
        names(preans) <- attr(locs, "capture.names")
        data.frame(t(preans), stringsAsFactors=F) })))
      cdate <- min(as.numeric(ans$time))
      if(cdate==lastcdate) {
        cdate <- cdate - 3600
        lastcdate <- cdate
      } else { lastcdate <- cdate }
    }
  }
  ans <- do.call(rbind, lapply(sort(unique(ans$time)[unique(ans$time)>edate]), function(i) subset(ans, time==i)[1,]))
  rownames(ans) <- NULL
  message(nrow(ans), ' songs retrieved')
  ans
}

load(file='nova.db.Rdata')
last.d <- as.numeric(max(nova.db$time))
nova.db <- rbind(nova.db, getSongsAfter(last.d))
save(nova.db, file='nova.db.Rdata')
