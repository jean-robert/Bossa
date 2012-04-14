<!-- begin.rcode echo=FALSE, results=hide
knit_hooks$set(inline = function(x) x)
load('TBU.Rdata')
end.rcode -->
---
layout: post
title: <!--rinline paste(TBU$artiste, TBU$titre, sep=' | ') -->
---


<!-- begin.rcode datascraping eval=TRUE, echo=FALSE, results=asis
    YTSearch <- tryCatch(paste(readLines(paste("http://www.youtube.com/results?search_type=videos&search_query=",
    	     gsub('[ [:punct:]]', '+', TBU$artiste), '+', gsub('[ [:punct:]]', '+', TBU$titre), sep='')), collapse="/n"),
	     error=function(e) { "riendutout" })
    named.p <- paste('<div id=\"',
    	             '(?<time>[0-9]+)\"',
                     ' class=\"resultat\"><span id=date>[0-9]+H[0-9]+</span>',
                     '<span id=\"artiste\"><a href=\"[A-Za-z[:punct:]]+\">',
                     '(?<artiste>[A-Za-z [:punct:]]+)',
                     '</a></span><span id=\"titre\">',
                     '(?<titre>[A-Za-z [:punct:]]+)',
                 '</span>', sep="")
	     
    named.p <- '<a href=\"/watch[?]v=(?<link>[A-Za-z0-9]+)\" class='
    locs <- gregexpr(named.p, YTSearch, perl=T)[[1]]
    if(locs[1] < 0) {
    	       vId <- NULL
    } else {
      ans <- do.call(rbind, lapply(1:length(locs), function(i) {
      	     preans <- sapply(1:length(attr(locs, "capture.names")), function(j) {
             substr(YTSearch, attr(locs, "capture.start")[i,j], attr(locs, "capture.start")[i,j] + attr(locs, "capture.length")[i,j] - 1) })
   	     names(preans) <- attr(locs, "capture.names")
             data.frame(t(preans), stringsAsFactors=F) }))
      vId <- ans[1,1]
    }

    if(is.null(vId)) {
  cat(paste('The new song is', TBU$titre, 'by', TBU$artiste, ' but is not yet available on Youtube, sorry!'))
} else {
  cat(paste('<iframe width="420" height="315" src="http://www.youtube.com/embed/', vId, '" frameborder="0" allowfullscreen></iframe>', sep=''))
}
end.rcode-->