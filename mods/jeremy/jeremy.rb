require_relative '../../lib/picklecraft'

def cage(p, pos, type)
  puts "Building a cage around #{pos} of #{type}"
  x, y, z = pos
  (-2..2).each do |a_offset|
    (-2..2).each do |b_offset|
      [-2, 2].each do |c_offset|
        p.place_block(type: type, x: x + a_offset, y: y + 1 + b_offset, z: z + c_offset)
        p.place_block(type: type, x: x + a_offset, y: y + 1 + c_offset, z: z + b_offset)
        p.place_block(type: type, x: x + c_offset, y: y + 1 + a_offset, z: z + b_offset)
      end
    end
  end
end

p = Picklecraft::Client.new(server: 'flarion.local', verbose: true, exit_on_error: true)

puts "players = #{p.players}"

player = p.player(name: 'jeremylightsmith')
puts "player = #{player}"

p.set_day_time 'day'

p.place_block(type: 'gold_block', position: player.position)
p.place_blocks(type: 'gold_block',
               from: [player.x, player.y + 2, player.z],
               to: [player.x, player.y + 100, player.z])
p.place_blocks_in_line(type: 'iron_ore',
                       position: player.position,
                       rotation: player.rotation[1],
                       length: 10)

# mika = p.player name: 'mikalightsmith'
# jeremy = p.player name: 'jeremylightsmith'
# pos = mika['position'].map(&:floor)

p.on_command do |event|
  puts "event = #{event.inspect}"
  case event['event']
  when 'command_event'
    case event['command']
    when '/cage'
      player = event['player']
      pos = player['position'].map(&:floor)
      cage(p, pos, 'GLASS')
    when '/ping'
      player = event['player']
      puts p.nearby_entities(player_name: player['name'], range: 50)
    end
  end
end

p.wait_for_events

# cage(p, pos, 'NETHERITE_BLOCK')
# cage(p, pos, 'DIAMOND_BLOCK')
