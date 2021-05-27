require 'faraday'
require 'json'

module Picklecraft
  class Client
    def initialize(verbose: false, server: 'localhost', port: 3200)
      @verbose = verbose
      @server = server
      @port = port
      @client = Faraday.new(
        url: "http://#{server}:#{port}"
      )
      @threads = []
    end

    def players
      parse(get('/players'))
    end

    def player(name:)
      player = parse(post('/player', name: name))

      raise "#{name} isn't on the server, only found #{players.map { |p| p['name'] }}" unless player['name']

      player
    end

    def place_block(type:, x:, y:, z:)
      post('/place_block', type: type, x: x, y: y, z: z)
    end

    def nearby_entities(player_name:, range:)
      parse(post('/nearby_entities', player_name: player_name, range: range))
    end

    def get(path, params = {})
      puts "GET #{path}" if @verbose
      @client.get(path, params).body
    end

    def post(path, body = {})
      puts "POST #{path} : #{body}" if @verbose
      @client.post(path, body.to_json).body
    end

    def put(path, body = {})
      puts "PUT #{path} : #{body}" if @verbose
      @client.put(path, body.to_json).body
    end

    def on_command
      @threads << Thread.new do
        socket = TCPSocket.new(@server, @port + 1)
        while (line = socket.gets)
          yield JSON.parse(line.strip)
        end
        socket.close
      end
    end

    def listen
      puts 'Listening for events, type ctrl-c to stop...'
      @threads.each(&:join)
    end

    private

    def check(response)
      if response.status == 200
        response.body
      else
        raise "Error: #{response.body}"
      end
    end

    def parse(json)
      JSON.parse(json)
    end
  end
end
