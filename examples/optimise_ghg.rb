require_relative '../lib/decc_2050_optimizer'

g = Generation.new
g.maximum_size = 200
g.seed
g.run!
