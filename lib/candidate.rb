require 'decc_2050_model'

class Array
  def random
    at(rand(size))
  end
end  

module Decc2050Model
  
  class Candidate
  
    attr_accessor :gene
  
    def initialize(gene = Candidate.random_gene)
      @gene = gene
    end
  
    def cross(other_candidate)
      d = other_candidate.gene
      new_gene = gene.split('').map.with_index do |c,i|
        rand(2) == 0 ? c : d[i]
      end.join
      Candidate.new(new_gene)
    end
  
    def mutate(chance_of_mutation = 0.01)
      
      # We add some random noise so that when number_of_mutations is not a whole number 
      # we sometimes get the higher value and sometimes get the lower
      number_of_mutations = ((chance_of_mutation * gene.size) + (rand(2) * 0.5)).round
      return self if number_of_mutations == 0
      
      new_gene = gene.dup
      number_of_mutations.times do
        i = rand(Candidate.acceptable_values.size)
        new_gene[i] = Candidate.acceptable_values[i].random
      end
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
      "#{gene} (with a greenhouse gas reduction of #{fitness}%)"
    end
    
    @acceptable_values = ModelStructure.instance.types.map do |type|
      case type
      when 0, '0'; ['0']
      when 1, '1', 'A'; ['1']
      when 2, '2', 'B'; ['1','2']
      when 3, '3', 'C'; ['1','2','3']
      when 4, '4', 'D'; ['1','2','3','4']
      end
    end
  
    def self.acceptable_values
      @acceptable_values
    end
  
    def self.random_gene
      acceptable_values.map.with_index do |a,i|
        Candidate.acceptable_values[i].random
      end.join
    end
    
    def self.gene_size_in_bits
      combinations = @acceptable_values.inject(1) do |combinations,acceptable_values_for_this_choice|
        combinations * acceptable_values_for_this_choice.size
      end
      combinations.to_s(2).size
    end
    
  end
end
