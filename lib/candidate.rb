require 'decc_2050_model'

class Array
  def random
    at(rand(size))
  end
end  

module Decc2050Model

  module CandidateClassMethods

    # Some choices can be 1,2,3,4 others 1.0, 1.1, 1.2 etc, others only 1 and 2
    # the optimiser needs to know that so it doesn't create any unacceptable
    # candidates
    def default_acceptable_values
      ModelStructure.instance.types.map.with_index do |type,index|
        if index <= 15 && index !=3 # Decimal points are allowed
          case type
          when nil, 0, '0'     ; %w[0]
          when 1, '1', 'A'; %w[1]
          when 2, '2', 'B'; %w[1 b c d e f g h i j 2]
          when 3, '3', 'C'; %w[1 b c d e f g h i j 2 l m n o p q r s t 3]
          when 4, '4', 'D'; %w[1 b c d e f g h i j 2 l m n o p q r s t 3 v w x y z A B C D 4]
          end
        else
          case type
          when nil, 0, '0'     ; %w[0]
          when 1, '1', 'A'; %w[1]
          when 2, '2', 'B'; %w[1 2]
          when 3, '3', 'C'; %w[1 2 3]
          when 4, '4', 'D'; %w[1 2 3 4]
          end
        end
      end
    end
  
    # An array of acceptable values for each position in the gene
    def acceptable_values
      @acceptable_values ||= default_acceptable_values
    end

    # This is a general override.
    # E.g., Candidate.only_permit_levels_up_to 2
    # would mean no choice could have a value above 2
    def only_permit_levels_up_to(max_level)
      maximum_acceptable_choice_array_size = max_level.to_i
      maximum_acceptable_choice_array_size_decimal = ((max_level-1)*10)+1

      acceptable_values.map!.with_index do |ok_values, index|
        if ok_values.size > 4 # Then this choice permits decimal points
          ok_values.slice(0,maximum_acceptable_choice_array_size_decimal)
        else
          ok_values.slice(0,maximum_acceptable_choice_array_size)
        end
      end
    end

    # This creates a handy set of methods for the user to specify
    # a different set of acceptable values. 
    #
    # e.g., the user could call Candidate.nuclear_power_stations = [1] 
    # to prevent the optimiser from choosing solutions with nuclear power
    ModelStructure.instance.choices.each do |choice|
      method_name = choice.name.downcase.gsub(/\W+/,'_') + "="

      send(:define_method, method_name) do |ok_values|
        acceptable_values[choice.number] = ok_values.map(&:to_s)
      end
    end
  

    # This is handy
    def random_gene
      acceptable_values.map.with_index do |a,i|
        Candidate.acceptable_values[i].random
      end.join
    end
    
    # This is used to optimise the generation size
    def gene_size_in_bits
      combinations = acceptable_values.inject(1) do |combinations,acceptable_values_for_this_choice|
        combinations * acceptable_values_for_this_choice.size
      end
      combinations.to_s(2).size
    end
  end
  
  class Candidate

    extend CandidateClassMethods
  
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
  
    def code
      @code ||= Decc2050ModelUtilities.new.convert_letters_to_float(gene.split(''))
    end
  
    def inspect
      "#{gene} (with a greenhouse gas reduction of #{fitness}%)"
    end
    
  end
end
