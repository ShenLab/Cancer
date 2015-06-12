Do <- function(){
  pdf("Perf.pdf")
  #timing <- read.delim(Sys.glob("Usage/*.timing.txt"))
  #usage <- read.delim(Sys.glob("Usage/*.usage.txt"))
  timing.files <- Sys.glob("Usage/*.timing.txt")
  usage.files <- Sys.glob("Usage/*.usage.txt")
  num.files <- length(timing.files)
  boundaries <- data.frame(START=rep(0, num.files), 
                           END=rep(0, num.files), LEVEL=rep(0, num.files))
  for (i in seq_along(timing.files)){
    timing <- read.delim(timing.files[i])
    start <- timing[1, "start"]
    end <- timing[nrow(timing), "end"]
    num.overlapping <- sum(boundaries$START < end & boundaries$END > start)
    boundaries[i, "START"] <- start
    boundaries[i, "END"] <- end
    boundaries[i, "LEVEL"] <- num.overlapping + 1
  }
  max.mem <- 0
  for (i in seq_along(usage.files)){
    usage <- read.delim(usage.files[i])
    max.mem <- max(max.mem, max(usage$vmem))
  }
  par(mfrow=c(max(boundaries$LEVEL),1))
  par(mar=c(0,0,0,0))
  par(oma=c(4,4,2,3))
  min.time <- min(boundaries$START)
  max.time <- max(boundaries$END)
  for (j in 1:max(boundaries$LEVEL)){
    level.timing.files <- timing.files[boundaries$LEVEL==j]
    plot(0, 0, type='n', xlim=c(0, (max.time-min.time)/60), 
         xlab="Minutes since start",
         ylab="Memory used (gigabytes)",
         ylim=c(0, max.mem / 2^30), xaxt='n')
    for (i in seq_along(level.timing.files)){
      timing <- read.delim(level.timing.files[i])
      usage <- read.delim(gsub("timing", "usage", level.timing.files[i]))
      if (is.na(timing$end[nrow(timing)])){
        timing$end[nrow(timing)] <- as.integer(as.POSIXct(Sys.time()))
      }
      lines(x=(usage$current_time - min.time)/60, 
            y=usage$vmem / 2^30)
      abline(v=(timing$start - min.time)/60)
      mid.time <- (timing$start - min.time)/120 + (timing$end - min.time)/120
      yvalues <- c(0.25, 0.5, 0.75)[1:min(3, nrow(timing))]
      text(mid.time, (max.mem / 2^30)*yvalues, 
       labels=paste0(timing$job, ":", timing$sample), cex=0.75)
    }
    if (j==ceiling(max(boundaries$LEVEL) / 2)){
      mtext("Memory used (gigabytes)", 2, 2.5)
    }
  }
  
  axis(side=1)
  mtext("Minutes since submission", 1, 2.5)
  dev.off()
}
