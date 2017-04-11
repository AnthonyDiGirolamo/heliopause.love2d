-- require "helpers"
import round from require "helpers"

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

  -- about_equals: =>











a = Vector 1, 2
b = Vector 3.6, 5.2
print a
a\add b
print a
c = a + b
print c
print a == b
c\round!
print c
