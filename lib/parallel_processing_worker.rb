require 'zmq'
require 'decc_2050_model'

context = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

sender = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")

while true
  gene = receiver.recv(0)
  result = Decc2050ModelResult.calculate_pathway(gene)
  sender.send(Marshal.dump(result))
end
