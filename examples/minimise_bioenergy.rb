require_relative '../lib/decc_2050_optimizer'

puts <<-EOT
Minimises the TWh of bioenergy used (irrespective of source) in 2050, subject to hitting the 80% emissions reduction target
EOT


class Decc2050Model::Candidate

  def calculate_fitness
    return ( [ghg_reduction,80].min * 100) - bioenergy_in_twh
  end
  
  def bioenergy_in_twh
    performance[:primary_energy_supply]['Bioenergy'].last
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
    
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and a 2050 bioenergy supply of #{bioenergy_in_twh} TWh"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!
