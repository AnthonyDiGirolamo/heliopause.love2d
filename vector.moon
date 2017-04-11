import
  round
  randomseed
  random
  random_int
  cos
  sin
  sqrt
  sub
  add
  del
  abs
  min
  max
  floor
  ceil
  from require "helpers"

twopi = math.pi*2

class Vector
  new: (x, y) =>
    @x = x or 0
    @y = y or 0

  __add: (other) =>
    Vector @x + other.x, @y + other.y

  __sub: (other) =>
    Vector @x - other.x, @y - other.y

  __mul: (scalar) =>
    Vector @x * scalar, @y * scalar

  __div: (scalar) =>
    Vector @x / scalar, @y / scalar

  __eq: (other) =>
    @x == other.x and @y == other.y

  __tostring: =>
    "[#{@x}, #{@y}]"

  add: (v) =>
    @x = @x + v.x
    @y = @y + v.y
    self

  clone: =>
    Vector @x, @y

  round: =>
    @x = round @x
    @y = round @y
    self

  ceil: =>
    @x = ceil @x
    @y = ceil @y
    self

  about_equals: (v) =>
    round(v.x) == @x and round(v.y) == @y

  angle: =>
    a = math.atan2(@y,@x) / twopi
    if a < 0
      a = (.5 - -1*a) + .5
    a

  length: =>
    math.sqrt(@x^2 + @y^2)

  scaled_length: =>
    182 * math.sqrt((@x / 182)^2 + (@y / 182)^2)

  perpendicular: =>
    Vector -@y, @x

  normalize: =>
    l = @length!
    @x = @x / l
    @y = @y / l
    self

  rotate: (phi) =>
    c = cos phi
    s = sin phi
    @x = c * @x - s * @y
    @y = s * @x + c * @y
    self

  draw_point: (c) =>
    color c
    love.graphics.points round(@x), round(@y)

  draw_line: (v, c) =>
    a = @clone!
    b = v\clone!
    a\round!
    b\round!
    color c
    if a == b
      love.graphics.points a.x, a.y
    else
      love.graphics.line a.x, a.y,
        b.x, b.y

  draw_circle: (radius, c, fill) =>
    draw_mode = "line"
    if fill
      draw_mode = "fill"
    color c
    love.graphics.circle draw_mode,
      @x, @y, radius

-- a = Vector 1, 2
-- b = Vector 3.6, 5.2
-- print a
-- a\add b
-- print a
-- c = a + b
-- print c
-- print a == b
-- c\round!
-- print c
-- c = a + b
-- c\ceil!
-- print c
-- print c\length!
-- print c\normalize!
-- print c\angle!
-- print c\length!
-- d = c\perpendicular!
-- print d\angle!
-- e = Vector 1, 0
-- print e\rotate(.5)
-- print "draw line"
-- a = Vector 1.2, 3.8
-- b = Vector 2.8, 4.2
-- a\draw_line b, 7
-- print a
-- print b

{:Vector}
