require_relative '../lib/decc_2050_optimizer'

puts <<EOT

The default optimisation just seeks to minimise greenhouse gas emissions in 2050, compared with 1990

EOT

g = Generation.new
g.seed
g.run!
