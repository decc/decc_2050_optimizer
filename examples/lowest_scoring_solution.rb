require_relative '../lib/decc_2050_optimizer'

puts <<EOT
This optimisation seeks to minimise the total 'score' from choices (e.g., a level 1 counts as 1, a level 4 as 4), while at the same time beating the 2050 greenhouse gas reduction target of a 80% reduction on 1990 levels.
EOT


class Decc2050Model::Candidate

  # Set so that only level 1 geosequestration is possible
  #self.acceptable_values[50] = ['1']

  def calculate_fitness
    return ( [ghg_reduction,80].min * 10) - score
  end

  def score
    score = 0
    code.each do |a|
      score += a
    end
    score
  end
  
  
  def ghg_reduction
    @ghg_reduction ||= performance[:ghg][:percent_reduction_from_1990]
  end
  
  def inspect
    "#{gene} (with a greenhouse gas reduction of #{ghg_reduction}%) and has a score of #{score}"
  end
  
end

o = Decc2050Model::Optimizer.new
o.run!(30)

