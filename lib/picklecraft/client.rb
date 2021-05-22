require 'faraday'
require 'json'

module Picklecraft
  class Client
    def initialize(verbose: false, server: 'localhost', port: 3200)
      @verbose = verbose
      @client = Faraday.new(
        url: "http://#{server}:#{port}"
      )
    end

    def players
      parse(get('/players'))
    end

    def find_player(name:)
      player = parse(get("/players/#{name}"))

      puts "player = #{player}"

      raise "#{name} isn't on the server, only found #{players.map { |p| p['name'] }}" unless player['name']

      player
    end

    def place_block(params)
      post('/blocks/new', params)
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
