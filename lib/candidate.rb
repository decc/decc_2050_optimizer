require 'decc_2050_model'

class Candidate
  
  attr_accessor :gene
  
  def initialize(gene = Decc2050ModelResult::CONTROL.map { rand(4)+1 }.join)
    @gene = gene
  end
  
  def cross(other_candidate)
    d = other_candidate.gene
    new_gene = gene.split('').map.with_index do |c,i|
      rand(2) == 0 ? c : d[i]
    end.join
    Candidate.new(new_gene)
  end
  
  def mutate
    new_gene = gene.dup
    new_gene[rand(gene.size)] = (rand(4) + 1).to_s
    Candidate.new(new_gene)
  end
    
  def fitness
    @fitness ||= calculate_fitness
  end
  
  def calculate_fitness
    performance[:ghg][:percent_reduction_from_1990]
  end
  
  def performance
    @performance ||= Decc2050ModelResult.calculate_pathway(gene)
  end
  
  def inspect
    "#{gene}: #{fitness}"
  end
  
end