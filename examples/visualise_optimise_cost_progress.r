#!/usr/bin/Rscript
pdf("optimise_cost_progress_scatter_plot.pdf")
candidates <- read.table("optimise_cost.tsv",header = TRUE)
plot(candidates$generation,candidates$fitness,col=rgb(0,100,0,50,maxColorValue=255),pch=16)
dev.off()
