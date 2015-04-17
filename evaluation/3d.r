# http://stackoverflow.com/questions/26794236/ggplot2-3d-bar-plot

d <- read.table(file='example-data.txt', header=TRUE)

library(latticeExtra)

cloud(value~version+cfg_t_64, d, panel.3d.cloud=panel.3dbars, col.facet='steelblue',
      xbase=0.4, ybase=0.4, scales=list(arrows=FALSE, col=1),
      par.settings = list(axis.line = list(col = "transparent")))
      