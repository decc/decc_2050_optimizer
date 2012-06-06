require_relative '../lib/decc_2050_optimizer'

puts <<-EOT

This runs a series of optimisations with different generation sizes, dumping the results as it goes.

These can then be plotted to work out the correct trade-off between generation size and speed.

EOT

# See the calculate_fitness method on ../lib/candidate.rb for the definition

File.open(File.join(File.dirname(__FILE__),"explore_generation_size.tsv"),'w') do |f|
  [10,20,30,40,50,100,200,300].each do |generation_size|
    o = Decc2050Model::Optimizer.new
    o.generation_size = generation_size
    o.dump = f
    o.dump_prefix_header = "Generation size\t"
    o.dump_prefix ="#{ o.generation_size}\t"
    o.run!
  end
end
