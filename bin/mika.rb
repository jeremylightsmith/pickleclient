require_relative '../lib/pickles/client'

p = Pickles::Client.new(verbose: true)

puts p.players

puts p.place_block(type: 'COBBLESTONE', x: 23, y: 28, z: 5)
