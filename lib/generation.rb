require_relative 'candidate'
  
class Generation < Array
  
  attr_accessor :generation_number
  attr_accessor :maximum_size
  attr_accessor :chance_of_mutation
  attr_accessor :chance_of_death
  
  def initialize
    @generation_number = 0
    @maximum_size = 100
    @chance_of_mutation = 0.1
    @chance_of_death = 0.5
  end
  
  def run!(number_of_generations = 20)
    number_of_generations.times do
      next!
      puts "The fittest candidate in generation #{generation_number} is #{fittest.first.inspect}"
    end
    puts
    puts "The fittest candiate after #{generation_number} generations was:"
    p fittest.first
  end
  
  def seed(initial_size = maximum_size)
    initial_size.times do 
      self << Candidate.new
    end
    sort_by_fitness!
    puts "The fittest candidate in the random starting population is #{fittest.first.inspect}"
  end
  
  def space
    @maximum_size - size
  end
  
  def number_to_die_in_this_generation
    (size * chance_of_death).round
  end
  
  def next!
    @generation_number += 1
    
    # Some of the previous generation die
    number_to_die_in_this_generation.times do
      sick_candidate = un_fitness_weighted_random_candidate
      delete sick_candidate
    end
    
    # To be replaced by children
    space.times do
      mum = fitness_weighted_random_candidate
      dad = fitness_weighted_random_candidate
      child = mum.cross(dad)
      child.mutate if rand < chance_of_mutation
      push child
    end
      
    sort_by_fitness!
  end
  
  def fittest(top_n = 1)
    first(top_n)
  end
  
  def fitness_weighted_random_candidate
    target = rand(total_fitness)
    current_sum = 0
    each do |candidate|
      current_sum = current_sum + candidate.fitness
      return candidate if current_sum >= target
    end
    last
  end
  
  def un_fitness_weighted_random_candidate
    target = rand(total_un_fitness)
    current_sum = 0
    reverse.each do |candidate|
      current_sum = current_sum + (fittest_candidates_fitness - candidate.fitness)
      return candidate if current_sum >= target
    end
    first
  end
  
  def total_fitness
    inject(0) { |sum,candidate| sum + candidate.fitness }
  end
  
  def total_un_fitness
    f = fittest_candidates_fitness
    inject(0) { |sum,candidate| sum + f - candidate.fitness }
  end
    
  def fittest_candidates_fitness
    first.fitness
  end
  
  def sort_by_fitness!
    self.sort_by! { |c| c.fitness }.reverse!
  end
  
end