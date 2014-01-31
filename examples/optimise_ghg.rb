require_relative '../lib/decc_2050_optimizer'

puts <<EOT

The default optimisation just seeks to minimise greenhouse gas emissions in 2050, compared with 1990

EOT

# See the calculate_fitness method on ../lib/candidate.rb for the definition

o = Decc2050Model::Optimizer.new
o.generation_size = 50
o.run!(5)
o.simplist_candidate_with_fitness_within()
