require_relative '../lib/decc_2050_optimizer'

puts <<-EOT

This optimisation seeks to minimise the TWh of electricity used in 2050 by the UK, while at the 
same time beating the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels.

EOT


class Decc2050Model::Candidate

  def calculate_fitness
    return ( [ghg_reduction,80].min * 10) - electricity_supply_in_2050
  end
  
  def electricity_supply_in_2050
    performance['electricity'][:supply]["Total generation supplied to grid"].last
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
    
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and a 2050 electricity supply of #{electricity_supply_in_2050} TWh"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!
