require_relative 'candidate'
require_relative 'generation'
  
module Decc2050Model
  class Optimizer
  
    # This contains an array containing the candidates in the latest generation
    attr_accessor :generation
    alias :this_generation :generation

    # This contians the number of the latest generation, starting at zero
    attr_accessor :generation_number
  
    # This is the size of each generation, a default is calculated
    # as sqrt(G)*(log(G)**2) after Baum et al (2000) as reported in
    # Mackay (1999) Rate of information aquisition of species subject
    # to natural selection
    attr_accessor :generation_size
  
    # This is the chance of any position on a child gene being mutated, default is 0.01
    attr_accessor :chance_of_mutation
  
    # This is the number of children produced by each generation
    # Default is two per adult. Children are produced, but only
    # the fittest go on to produce the next generation.
    attr_accessor :children_per_adult
    
    # If specified, dump will have its #puts method called once for each candidate
    # in a generation with a string in the form:
    # gene\tgeneration\tfitness
    # dump would typically be an IO object, usually an open File but perhaps also
    # stdout.
    attr_accessor :dump
    
    # If specified, this will be prepended to each row in the dump
    attr_accessor :dump_prefix
    
    # If specified, this will be prepended to the header of the dump file
    attr_accessor :dump_prefix_header
    
    def initialize
      @generation_number = 0
      @generation_size = calculate_default_generation_size
      @children_per_adult = 2
      @chance_of_mutation = 0.01

      @generation = new_generation
    end
  
    def run!(number_of_generations = 20)
      puts "Configured to run for #{number_of_generations} generations with #{generation_size} candidates in each generation, #{children_per_adult} children per adult and a #{chance_of_mutation} chance of mutation.\n\n"
      dump_headers
      
      generation.seed
      dump_generation
      
      number_of_generations.times do
        next!
        puts "The fittest candidate in generation #{generation_number} is #{generation.fittest.first.inspect}"
        dump_generation
      end
    
      puts
      puts "The fittest candiate after #{generation_number} generations was:"
      p generation.fittest.first
    
      puts
      puts "Inspect this candidate online at http://2050-calculator-tool.decc.gov.uk/pathways/#{generation.fittest.first.gene}/primary_energy_chart"
    end
  
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
    
    # TODO: What base should the logarithm be in?
    # I'm assuming base 2 for the minute
    def calculate_default_generation_size
      g = Candidate.gene_size_in_bits
      (Math.sqrt(g) * (Math.log2(g)**2)).round
    end
    
    def dump_headers
      return unless dump
      dump.puts "#{dump_prefix_header}generation\tgene\tfitness"
    end
    
    def dump_generation
      return unless dump
      this_generation.each do |candidate|
        dump.puts "#{dump_prefix}#{generation_number}\t#{candidate.gene}\t#{candidate.fitness}"
      end
    end
  
  end
end
