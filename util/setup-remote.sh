## REQUIRED LIBRARIES

# Basics
sudo apt-get update
sudo apt-get install -y git build-essential libxml2-dev libxslt-dev zip unzip
sudo apt-get install -y libcurl4-openssl-dev libssl-dev

# Ruby
sudo apt-add-repository -y ppa:brightbox/ruby-ng-experimental
sudo apt-get update 
sudo apt-get install -y ruby1.9.3

# Zeromq
sudo apt-get install -y uuid-dev
wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
tar -xvzf zeromq-2.2.0.tar.gz
cd zeromq-2.2.0
./configure
make
sudo make install
sudo ldconfig
cd ..
ARCHFLAGS="-arch x86_64" sudo gem install zmq -- --with-zmq-dir=/usr/local


## THE CODE
git clone https://github.com/decc/decc_2050_optimizer.git

# Bundler
sudo gem install --no-ri --no-rdoc bundler
cd decc_2050_optimizer
bundle

