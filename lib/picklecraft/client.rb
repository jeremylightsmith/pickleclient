require 'faraday'
require 'json'
require 'colorize'

module Picklecraft
  class Client
    def initialize(verbose: false, server: 'localhost', port: 3200, exit_on_error: true)
      @verbose = verbose
      @exit_on_error = exit_on_error
      @server = server
      @port = port
      @client = Faraday.new(
        url: "http://#{server}:#{port}"
      )
      @threads = []
    end

    def players
      rpc(method: :getPlayers).map { |p| Player.new(p) }
    end

    def player(name:)
      Player.new(rpc(method: 'getPlayer', name: name))
    end

    def place_block(type:, position:)
      rpc(method: 'placeBlock', type: type, position: position)
    end

    def place_blocks(type:, from:, to:)
      rpc(method: 'placeBlocks', type: type, fromPosition: from, toPosition: to)
    end

    def place_blocks_in_line(type:, position:, rotation:, length:)
      length.times do |_i|
        position = increment_position_in_direction(position, rotation, 1)
        place_block(type: type, position: position)
      end
    end

    def get_blocks(from:, to:)
      rpc(method: 'getBlocks', fromPosition: from, toPosition: to)
    end

    def nearby_entities(player_name:, range:)
      rpc(method: 'getNearbyEntities', playerName: player_name, range: range)
    end

    def set_day_time(time)
      rpc(method: 'setDayTime', time: time)
    end

    def lift_boot
      rpc(method: 'liftBoot')
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

    def increment_position_in_direction(pos, rotation, distance)
      [
        pos[0] - distance * Math.sin(to_radians(rotation)),
        pos[1],
        pos[2] + distance * Math.cos(to_radians(rotation))
      ]
    end

    def to_radians(angle)
      angle / 180.0 * Math::PI
    end

    def rpc(body)
      path = '/rpc'
      puts "POST #{path} : #{body}" if @verbose
      response = @client.post(path, body.to_json)

      if response.status == 200
        JSON.parse(response.body)
      else
        handle_error(response)
      end
    end

    def handle_error(response)
      error = begin
        JSON.parse(response.body)['error']
      rescue StandardError
        response.body
      end

      if @exit_on_error # rubocop:disable Style/GuardClause
        puts "Error: #{error}".red
        exit(1)
      else
        raise "Error: #{error}"
      end
    end
  end
end
