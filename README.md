# OPTIMISER FOR THE DECC 2050 CALCULATOR TOOL

This is a toy genetic algorithm optimiser for the DECC 2050 Pathways Calculator. 
It allows multi-criteria non-linear optimisation of possible pathways for the UK's energy system.

Further detail on the overall project:
http://www.decc.gov.uk/2050

Canonical source for this optimizer:
http://github.com/decc/decc_2050_optimizer

## STATUS

Right now this is a naive implementation that we are messing around with.
It has not been used in anger.

## INSTALATION

Requires:
* ruby 1.9.3 (www.ruby-lang.org)
* a standard C compiler and libraries
* the R statistical package (only if you want to plot the visualisations)
* the zeromq libary (only if you want to run in parallel processing mode)

Requires the bundler gem:

    sudo gem install bundler

To install dependencies:
  
    cd decc_2050_optimizer
    bundler
  
## INSTRUCTIONS

### STANDARD PROCESSING

To run an example optimisation
  
    cd decc_2050_optimizer
    ruby examples/optimise_ghg.rb

To write your optimisation, take a look at:
  
    examples/optimise_cost_no_nuclear.rb

### PARALELL PROCESSING

The code has support for parallel processing. To use it, you must first run a few worker processes:

    bundle exec lib/parallel_processing_worker.rb

Then you should set the optimiser to use the workers. This means adding:

    optimiser.setup_parallel_processing

before calling
    
    optimiser.run!

For an example, take a look at examples/optimise_cost_no_nuclear_parallel.rb or run it by:
    
    bundle exec examples/optimise_cost_no_nuclear_parallel.rb

  
## HACKING

Grateful for bugs and patches: http://github.com/decc/decc_2050_optimizer

## CONTACT

tom.counsell@decc.gsi.gov.uk

Department of Energy and Climate Change
3 Whitehall Place
London
SW1A 1AA

## LICENCE

Where not otherwise covered by separate copyright, this source code is Crown Copyright (c) 2012

Where not otherwise covered by a separate licence, this source code is distributed under the MIT licence: http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


