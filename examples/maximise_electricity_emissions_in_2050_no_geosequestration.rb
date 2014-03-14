require_relative '../lib/decc_2050_optimizer'

puts <<-EOT

This optimisation maximizes the gCO2/kWh from electricity in 2050 while still beating
the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels. It doesn't
allow geosequestration.

EOT


class Decc2050ModelResult 

  def electricity_tables
    e = {}
    e[:demand] = table 322, 326
    e[:supply] = table 96, 111
    e[:emissions] = table 270, 273
    e[:capacity] = table 118, 132
    e[:emissions_factor] = annual_data("intermediate_output", 276)
    e['automatically_built'] = r("intermediate_output_q120")
    e['peaking'] = r("intermediate_output_q131")
    pathway['electricity'] = e
  end
end


class Decc2050Model::Candidate
 
  # Set so that only level 1 geosequestration is possible
  self.geosequestration = ['1']

  def calculate_fitness
    return ( [ghg_reduction,80].min * 50) + electricity_emissions_in_2050
  end
  
  def electricity_emissions_in_2050
    performance['electricity'][:emissions_factor][8]
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
    
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and a 2050 electricity emissions of #{electricity_emissions_in_2050} gCO2e/kWhe"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!
