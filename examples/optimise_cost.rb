require_relative '../lib/decc_2050_optimizer'

puts <<EOT

This optimisation seeks to minimise the point estimate of the average cost of the modelled
energy system per capita 2010-2050, while at the same time beating the 2050 greenhouse gas
reduction target of a 80% reduction on 1990 levels.

EOT


class Decc2050Model::Candidate

  def calculate_fitness
    return ( [ghg_reduction,80].min * 100) - cost
  end
  
  def cost
    @cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:point] }
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
  
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and a point cost estimate of #{cost.round}"
  end
  
end

o = Decc2050Model::Optimizer.new
o.generation_size = 200
o.run!(50)

