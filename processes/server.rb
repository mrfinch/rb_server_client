# TODO: on close of connection send user disconnected
require 'socket'
require 'pry'

@clients = []

server = TCPServer.new('localhost', 2000)

def listen server
  loop {
    client = server.accept
    puts "Client accepted at #{Time.now}"

    thr = Thread.new(client) do
      username = nil
      client.puts 'Enter yr username:'
      puts @clients
      while true
        username = client.gets.chomp
        puts "#{username} trying to connect"

        @clients.each do |clnt|
          if clnt[:nickname] == username
            client.puts "Choose another nickname"
            username = nil
            break
          end
        end
        break if username
      end
      puts "#{username} connected to chat"
      client.puts "You are connected. Happy Chatting"

      client_info = { client: client, nickname: username }
      send_notification_to_rest_clients("#{username} connected to chat window.", client_info)
      send_list_of_users_available_to_chat_to_client(client)
      @clients << client_info
      listen_to_messages_from_client(client_info)
    end
  }
end

def listen_to_messages_from_client client_info
  loop {
    msg = client_info[:client].gets.chomp
    if msg
      send_message_to_rest_clients(msg, client_info)
    end
  }
end

def send_message_to_rest_clients msg, client_info
  @clients.each do |clnt|
    next if clnt[:nickname] == client_info[:nickname]
    clnt[:client].puts "From #{client_info[:nickname]}: #{msg}"
  end
end

def send_notification_to_rest_clients msg, client_info
  @clients.each do |clnt|
    next if clnt[:nickname] == client_info[:nickname]
    clnt[:client].puts "#{msg}"
  end
end

def send_list_of_users_available_to_chat_to_client client
  client.puts "List of people available for chat:"
  @clients.each.with_index do |clnt, index|
    client.puts "#{index + 1}. #{clnt[:nickname]}"
  end
end


listen(server)
