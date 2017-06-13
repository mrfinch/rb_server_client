require 'socket'

server = TCPSocket.open('localhost', 2000)

def listen server
  loop {
    message = server.gets
    if message
      puts message
    end
  }
end

def send server
  thr = Thread.new do
    loop {
      input = STDIN.gets.chomp
      if input
        server.puts input
      end
    }
  end
  # thr.join
end

send(server)
listen(server)
