require_relative '../lib/decc_2050_optimizer'

puts <<EOT
This optimisation seeks to minimise number of levers that are pursued, while at the same time beating the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels.
EOT


class Decc2050Model::Candidate

  # Set so that only level 1 geosequestration is possible
  self.acceptable_values[50] = ['1']
  # Set so that only level 1 or 2 of industry growth is possible (no collapsing industry)
  self.acceptable_values[40] = ['1']

  def calculate_fitness
    return ( [ghg_reduction,80].min * 10) - levers_altered
  end

  def levers_altered
    number_of_levers_altered = 0
    gene.split('').each do |a|
      number_of_levers_altered += 1 unless %w{0 1}.include?(a)
    end
    number_of_levers_altered
  end
  
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
  
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and requires altering #{levers_altered} levers from their default"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!(30)

