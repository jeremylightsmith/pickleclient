require 'faraday'
require 'json'

module Pickles
  class Client
    def initialize(verbose: false)
      @verbose = verbose
      @client = Faraday.new(
        url: 'http://localhost:3200'
        # params: { access_token: ENV['ROLLBAR_READ_TOKEN'] },
      )
    end

    def players
      parse(get('/players'))
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
