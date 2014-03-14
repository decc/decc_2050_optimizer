require_relative '../lib/decc_2050_optimizer'

puts <<EOT
PARALLEL PROCESSING EXAMPLE

Note, you need to start some workers BEFORE running this.

This optimisation seeks to minimise the point estimate of the average cost of the modelled
energy system per capita 2010-2050, while at the same time:
* beating the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels.
* assumming no new nuclear power stations are built.

EOT

class Decc2050Model::Candidate
  
  # Set so that only level 1 nuclear is possible
  nuclear_power = ['1']

  def calculate_fitness
    ( [ghg_reduction,80].min * 100) - cost
  end
  
  def cost
    @cost ||= performance['cost_components'].values.inject(0) { |sum,component| sum+component[:point] }
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
  
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}% and a point cost estimate of #{cost.round})"
  end
  
end

o = Decc2050Model::Optimizer.new
o.setup_parallel_processing
o.run!


