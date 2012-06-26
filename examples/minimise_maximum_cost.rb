require_relative '../lib/decc_2050_optimizer'

puts <<EOT
This optimisation seeks to minimise the maximum estimate of the average cost of the modelled energy system per capita 2010-2050, while at the same time beating the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels.

EOT


class Decc2050Model::Candidate

  def calculate_fitness
    return ( [ghg_reduction,80].min * 100) - maximum_cost
  end
  
  def cost
    @cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:point] }
  end

  def maximum_cost
    @maximum_cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:high] }
  end
  
  def minimum_cost
    @minimum_cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:low] }
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
  
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and cost estimate of #{minimum_cost.round}-#{cost.round}-#{maximum_cost.round}"
  end
  
end

File.open(File.join(File.dirname(__FILE__),"optimise_cost.tsv"),'w') do |f|
  o = Decc2050Model::Optimizer.new
  o.dump = f
  o.run!(50)
end

