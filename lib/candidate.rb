require 'decc_2050_model'

class Array
  def random
    at(rand(size))
  end
end  

module Decc2050Model
  
  class Candidate
  
    attr_accessor :gene
    attr_accessor :performance
  
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
  
    # The change of mutation is taken as
    # meaning the probability of each bit
    # of information in the gene being changed
    def mutate(chance_of_mutation = 0.01)
      return self if chance_of_mutation == 0
      new_gene = gene.dup
      (0...gene.size).each do |i|
        next if Candidate.acceptable_values[i].size == 1
        bit_size = (Candidate.acceptable_values[i].size - 1).to_s(2).size
        if(rand < (bit_size * chance_of_mutation))
          new_gene[i] = Candidate.acceptable_values[i].random
        end
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
    
    @acceptable_values = ModelStructure.instance.types.map.with_index do |type,index|
      if index <= 15 && index !=3 # Decimal points are allowed
        case type
        when 0, '0'     ; %w[0]
        when 1, '1', 'A'; %w[1]
        when 2, '2', 'B'; %w[1 b c d e f g h i j 2]
        when 3, '3', 'C'; %w[1 b c d e f g h i j 2 l m n o p q r s t 3]
        when 4, '4', 'D'; %w[1 b c d e f g h i j 2 l m n o p q r s t 3 v w x y z A B C D 4]
        end
      else
        case type
        when 0, '0'     ; %w[0]
        when 1, '1', 'A'; %w[1]
        when 2, '2', 'B'; %w[1 2]
        when 3, '3', 'C'; %w[1 2 3]
        when 4, '4', 'D'; %w[1 2 3 4]
        end
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
