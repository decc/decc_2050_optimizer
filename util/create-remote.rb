require 'fog'
require 'pry'

# Need to have a ~/.fog file with AWS credentials
puts "Connecting to AWS"
connection =  Fog::Compute.new({
  :provider => 'AWS',
})


# This sets up an Ubuntu precise high compute instance 
puts "Bootstrapping a server"
server = connection.servers.bootstrap(
  :image_id => 'ami-1de8d369',
  :flavor_id=> 'c1.xlarge',
  :private_key_path => '~/.ssh/id_rsa',
  :public_key_path => '~/.ssh/id_rsa.pub', 
  :username => 'ubuntu'
)

puts "Waiting for server to be ready"
server.wait_for { ready? }

puts "Sever ready"

puts "You can now:"
puts "ssh ubuntu@#{server.dns_name}"

# p server

p server.ssh(["whoami"])

puts "Uploading setup code"
p server.scp("setup-remote.sh","setup-remote.sh")

puts "Running setup code"
p server.ssh("sh ./setup-remote.sh")
puts "Server setup"


