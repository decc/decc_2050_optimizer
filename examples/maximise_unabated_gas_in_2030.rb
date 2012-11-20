require_relative '../lib/decc_2050_optimizer'

puts <<-EOT

This optimisation maximizes the GW of unabated generation in 2030

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

  def calculate_fitness
    return ( [ghg_reduction,80].min * 10) + gw_unabated_gas_generation_in_2030
  end
  
  def gw_unabated_gas_generation_in_2030
    performance['electricity'][:capacity]["Standby / peaking gas"][4] + performance['electricity'][:capacity]["Gas / Biogas"][4]
  end
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
    
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and a 2030 unabated gas generation of #{gw_unabated_gas_generation_in_2030} GW"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!
