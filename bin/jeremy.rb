require_relative '../lib/picklecraft/client'

def cage(p, pos, type)
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

p = Picklecraft::Client.new(server: 'localhost', verbose: true)

mika = p.find_player name: 'mikalightsmith'
# jeremy = p.find_player name: 'jeremylightsmith'

pos = mika['position'].map(&:floor)

# cage(p, pos, 'NETHERITE_BLOCK')
# cage(p, pos, 'DIAMOND_BLOCK')
