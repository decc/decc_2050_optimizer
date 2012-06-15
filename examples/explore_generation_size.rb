require_relative '../lib/decc_2050_optimizer'

puts <<-EOT
EXPLORE THE PERFORMANCE OF THE OPTIMISER: GENERATION SIZE

This runs a series of optimisations with different generation sizes, dumping the results as it goes.

These can then be plotted to work out the correct trade-off between generation size and speed.

EOT

# See the calculate_fitness method on ../lib/candidate.rb for the definition

File.open(File.join(File.dirname(__FILE__),"explore_generation_size.tsv"),'w') do |f|

  o = Decc2050Model::Optimizer.new
  o.dump = f
  o.dump_prefix_header = "Generation_size\t"
  
  (1..100).step(1).to_a.concat((105..300).step(5).to_a).each_with_index do |generation_size,i|
    o.generation_size = generation_size
    o.dump_prefix ="#{ o.generation_size}\t"
    o.do_not_dump_header = true unless i == 0
    o.reset!
    o.run!
  end
end
