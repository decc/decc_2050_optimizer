require_relative '../lib/decc_2050_optimizer'

puts <<EOT

This optimisation seeks to minimise the point estimate of the average cost of the modelled
energy system per capita 2010-2050.

EOT


class Decc2050Model::Candidate

  def calculate_fitness
    return (-cost)
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

File.open(File.join(File.dirname(__FILE__),"optimise_cost.tsv"),'w') do |f|
  o = Decc2050Model::Optimizer.new
  o.dump = f
  o.run!(50)
end

