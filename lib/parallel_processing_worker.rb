require 'ffi-rzmq'
require 'decc_2050_model'

context = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

sender = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")
gene = ""

while true
  receiver.recv_string gene
  result = Decc2050ModelResult.calculate_pathway(gene)
  sender.send_string(Marshal.dump(result), 0)
end
