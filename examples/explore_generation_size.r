#!/usr/bin/Rscript
library(ggplot2)

candidates <- read.table("explore_generation_size.tsv",header = TRUE)

pdf("explore_generation_size_scatter.pdf")
ggplot(candidates, aes(x=generation, y=fitness) ) + geom_point() + facet_wrap( ~ Generation_size) +
  opts(title="Variation in performance for different generation sizes")
dev.off()

pdf("explore_generation_size_frontier.pdf")
frontier <- aggregate( . ~ Generation_size, data = candidates[,c("Generation_size","fitness")], max)
ggplot(frontier, aes(x=Generation_size, y=fitness) ) + geom_point() +
  opts(title="Variation in performance for different number of candidates per generation") +
  scale_x_continuous(name="Number of candidates in each generation") +
  scale_y_continuous(name="Fittest candidate after 20 generations")
dev.off()
