require_relative 'candidate'
require_relative 'generation'
  
module Decc2050Model
  class Optimizer
  
    # This contains an array containing the candidates in the latest generation
    attr_accessor :generation
    alias :this_generation generation

    # This contians the number of the latest generation, starting at zero
    attr_accessor :generation_number
  
    # This is the size of each generation, default is 100
    attr_accessor :generation_size
  
    # This is the chance of any position on a child gene being mutated, default is 0.01
    attr_accessor :chance_of_mutation
  
    # This is the number of children produced by each generation
    # Default is two per adult. Children are produced, but only
    # the fittest go on to produce the next generation.
    attr_accessor :children_per_adult 
  
    def initialize
      @generation_number = 0
      @generation_size = 100
      @children_per_adult = 2
      @chance_of_mutation = 0.01

      @generation = new_generation
    end
  
    def run!(number_of_generations = 20)
    
      generation.seed
    
      number_of_generations.times do
        next!
        puts "The fittest candidate in generation #{generation_number} is #{generation.fittest.first.inspect}"
      end
    
      puts
      puts "The fittest candiate after #{generation_number} generations was:"
      p generation.fittest.first
    
      puts
      puts "Inspect this candidate online at http://2050-calculator-tool.decc.gov.uk/pathways/#{generation.fittest.first.gene}/primary_energy_chart"
    end
  
    private
  
    def new_generation
      g = Array.new
      g.extend(Generation)
      g.generation_size = generation_size
      g
    end
  
    def next!
      @generation_number += 1
    
      next_generation = new_generation
    
      # The next generation is created from the previous
      number_of_children.times do
        # Pick a random mother
        mum = this_generation.random
        # Pick a random father
        dad = this_generation.random
        # Cross their genes together to form a child
        child = mum.cross(dad)
        # Sometimes mutate some of the genes
        child.mutate(chance_of_mutation)
        # Add the child to the next generation
        next_generation.push child
      end
      
      # Rank by fitness
      next_generation.sort_by_fitness!
      # Cull the weakest
      next_generation.cull!
      
      # Keep the memory down
      self.generation = nil
      GC.start
      
      # Start again with the next generation
      self.generation = next_generation
    end
  
    def number_of_children
      generation_size * children_per_adult
    end
  
  end
end
