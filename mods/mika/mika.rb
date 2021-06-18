require_relative '../lib/pickles/client'

p = Pickles::Client.new(server: 'asteroid', verbose: true)

puts p.players

puts p.place_block(type: 'COBBLESTONE', x: -180, y: 70, z: -402)
