require_relative 'candidate'
require_relative 'generation'
  
module Decc2050Model
  class Optimizer
 
    # This contains the fittest candidate found. It is updated each generation.
    # If the fittest candidate in the current generation is less fit than this
    # candidate then this candidate will be kept.
    attr_accessor :fittest_candidate

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

    # If true, will not dump header into dump file. Default is nil (which is 
    # the same as false in ruby) so headers will be dumped on every run.
    attr_accessor :do_not_dump_header
    
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

    # If you choose to use the parallel processing version you 
    # need to call this before calling run
    def setup_parallel_processing
      require 'zmq'
      @context = ZMQ::Context.new(1)

      @sender = @context.socket(ZMQ::PUSH)
      @sender.bind("tcp://*:5557")

      @receiver = @context.socket(ZMQ::PULL)
      @receiver.bind("tcp://*:5558")

      @parallel_processing = true
    end
  
    def run!(number_of_generations = 20)

      start_time = Time.now

      puts "Configured to run for #{number_of_generations} generations with #{generation_size} candidates in each generation, #{children_per_adult} children per adult and a #{chance_of_mutation} chance of mutation. Running against DECC 2050 Model #{ModelStructure.instance.reported_calculator_version.downcase}.\n\n"

      dump_headers

      number_of_generations.times do
        next!
        puts "The fittest candidate in generation #{generation_number} is #{generation.fittest.first.inspect}"
        dump_generation
      end
    
      puts "\nThe fittest candiate after #{generation_number} generations was:"
      p fittest_candidate
    
      puts "\nInspect this candidate online at http://2050-calculator-tool.decc.gov.uk/pathways/#{fittest_candidate.gene}/primary_energy_chart"

      elapsed_time = Time.now - start_time
      number_of_candidates_calculated = number_of_generations * number_of_children
      candidates_per_second = (number_of_candidates_calculated / elapsed_time).round

      puts "\nThe elapsed time was #{elapsed_time.round} seconds for #{number_of_candidates_calculated} candidates, a rate of #{candidates_per_second} candidates per second.\n\n"
    end

    def simplist_candidate_with_fitness_within( tolerance = 0.015)
      threshold_to_beat = fittest_candidate.fitness.to_f * (1-tolerance)
      simplest_gene = fittest_candidate.gene
      Candidate.acceptable_values.each.with_index do |a,i|
        next if a.size == 1
        trial_gene = simplest_gene.dup
        trial_gene[i] = '1'
        trial_candidate = Candidate.new(trial_gene)
        if trial_candidate.fitness > threshold_to_beat
          simplest_gene = trial_gene
        end
      end
      simplest = Candidate.new(simplest_gene)
      puts "The simplest candidate within #{tolerance} of the fittest candidate's fitness is:"
      p simplest

      puts "\nInspect this candidate online at http://2050-calculator-tool.decc.gov.uk/pathways/#{simplest.gene}/primary_energy_chart"

      simplest
    end
  
    def reset!
      @generation = nil
      @generation_number = 0
      @fittest_candidate = nil
    end

    def next!
      @generation_number += 1
    
      @generation ||= new_generation
      @generation.seed
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
      
      # Check if the fittest candidate in this generation is fitter
      # than the fittest candidate of previous generations
      fittest_candidate_in_this_generation = next_generation.fittest.first
      @fittest_candidate ||= fittest_candidate_in_this_generation

      if @fittest_candidate.fitness < fittest_candidate_in_this_generation.fitness
        @fittest_candidate = fittest_candidate_in_this_generation
      end


      # Keep the memory down
      self.generation = nil
      GC.start
      
      # Start again with the next generation
      self.generation = next_generation
    end
  
    def new_generation
      g = Array.new
      g.extend(Generation)
      g.generation_size = generation_size
      if @parallel_processing
        g.sender = @sender
        g.receiver = @receiver
      end
      g
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
      return if do_not_dump_header
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
