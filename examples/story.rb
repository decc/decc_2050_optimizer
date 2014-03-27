require_relative '../lib/decc_2050_optimizer'

puts <<EOT

This runs a series of optimisations. 

First, it finds the pathway with:
1. Lowest central cost
2. Lowest emissions
3. Lowest imports

Then, it tries to find the trade-offs between the three:
1. cost versus emissions
2. cost versus imports
3. emissions versus imports

EOT

class Decc2050Model::Candidate

  # This is the 2010-2050 average cost per capita per year
  # FIXME: Can we get discounted total cost? or the 2050 cost?
  def cost
    @cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:point] }
  end

  # This is the 2050 MtCO2e
  # FIXME: Can we get cummulative emissions?
  def emissions
    @emissions ||= performance[:ghg]['Total'].last
  end

  # This is the 2050 TWh including Uranium imports.
  # May want to exclude Uranium and do it as a proportion
  def imports
    @imports ||= performance['imports']["Primary energy"]['2050'][:quantity]
  end

  def inspect
    "#{gene}\t#{cost.round}\t#{emissions.round}\t#{imports.round}"
  end

end

results = File.open('results','w')

o = Decc2050Model::Optimizer.new
o.setup_parallel_processing

0.step(750,50).each do |emissions_target|

 puts "Lowest central cost with #{emissions_target} MtCO2e in 2050"

  Decc2050Model::Candidate.send(:define_method, :calculate_fitness) do
      return -cost - ((emissions_target - emissions).abs * 5000)
  end

  o.reset
  o.run!(40)
  best = o.fittest_candidate

  results.puts "Lowest central cost with #{emissions_target} MtCO2e in 2050\t#{best.inspect}"
end

puts "Lowest central cost"
class Decc2050Model::Candidate
  def calculate_fitness
    return -cost
  end
end

o = Decc2050Model::Optimizer.new
o.run!(40)
best = o.fittest_candidate

results.puts "Lowest central cost\t#{best.inspect}"

puts "Lowest emisssions"
class Decc2050Model::Candidate
  def calculate_fitness
    return -emissions
  end
end

o = Decc2050Model::Optimizer.new
o.run!(40)
best = o.fittest_candidate

results.puts "Lowest emissions\t#{best.inspect}"

puts "Lowest imports"
class Decc2050Model::Candidate
  def calculate_fitness
    return -imports
  end
end

o = Decc2050Model::Optimizer.new
o.run!(40)
best = o.fittest_candidate

results.puts "Lowest imports\t#{best.inspect}"


results.close


