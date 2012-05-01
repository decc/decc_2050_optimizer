require_relative '../lib/decc_2050_optimizer'

class Candidate

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
    "#{gene}: #{fitness.round}: GHG: #{ghg_reduction} Cost:#{cost.round}"
  end
  
end

g = Generation.new
g.maximum_size = 200
g.seed
g.run!(50)

