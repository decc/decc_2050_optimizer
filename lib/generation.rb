# This is used to extend relevant array instances
module Decc2050Model
  module Generation
  
    attr_accessor :generation_size
    attr_accessor :sender
    attr_accessor :receiver
  
    def seed
      space.times do 
        self << Candidate.new
      end
    end
  
    def space
      @generation_size - size
    end
  
    def cull!
      if space < 0
        pop(-space)
      end 
    end
  
    def random
      at(rand(size))
    end
  
    def sort_by_fitness!
      parallel_process_pathways if parallel_processing?
      self.sort_by! { |c| c.fitness }.reverse!
    end
  
    def fittest(top_n = 1)
      first(top_n)
    end
    
    def fittest_candidates_fitness
      first.fitness
    end


    def parallel_processing?
      sender && receiver
    end

    def parallel_process_pathways
      send_pathways_out_for_calculation
      gather_results_back
    end

    def send_pathways_out_for_calculation
      @sent_pathways = {}
      each do |candidate|
        @sent_pathways[candidate.gene] = candidate
        sender.send(candidate.gene)
      end
    end

    def gather_results_back
      size.times do 
        performance = Marshal.load(receiver.recv(0))
        gene = performance[:_id]
        @sent_pathways[gene].performance = performance
      end
    end
  
  end
end
