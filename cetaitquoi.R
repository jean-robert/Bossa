
# recupere les chansons sur nova a l'heure donnée, jour donnée

setwd('/data/R/Bossa')
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
getSongsDay <- function(d) {
  message('Retrieving songs on ', d)
  cdate <- as.numeric(as.POSIXlt(as.Date(d))) # current date
  lastcdate <- 0
  edate <- as.numeric(as.POSIXlt(as.Date(d)-1)) # end date
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
  ans <- do.call(rbind, lapply(unique(ans$time), function(i) subset(ans, time==i)[1,]))
  ans <- ans[as.Date(as.POSIXlt(as.numeric(ans$time),origin="1970-01-01"))==(as.Date(d)-1),]
  rownames(ans) <- NULL
  message(nrow(ans), ' songs retrieved')
  ans
}

load(file='nova.db.Rdata')
last.d <- as.Date(as.POSIXlt(as.numeric(max(nova.db$time)),origin='1970-01-01'))
nova.db <- rbind(nova.db, do.call(rbind, mclapply(format(seq(from=last.d, to=Sys.Date(), by='1 day')), getSongsDay)))
save(nova.db, file='nova.db.Rdata')
