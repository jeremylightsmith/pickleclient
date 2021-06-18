require 'ostruct'

class Player < OpenStruct
  def x
    position[0].floor
  end

  def y
    position[1].floor
  end

  def z
    position[2].floor
  end
end
