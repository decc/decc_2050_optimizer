# This is used to extend relevant array instances
module Decc2050Model
  module Generation
  
    attr_accessor :generation_size
  
    def seed
      space.times do 
        self << Candidate.new
      end
      sort_by_fitness!
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
      self.sort_by! { |c| c.fitness }.reverse!
    end
  
    def fittest(top_n = 1)
      first(top_n)
    end
    
    def fittest_candidates_fitness
      first.fitness
    end    
  
  end
end