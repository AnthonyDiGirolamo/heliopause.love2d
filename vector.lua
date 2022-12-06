local color, round, randomseed, random, random_int, cos, sin, atan2, sqrt, sub, add, del, abs, min, max, floor, ceil
do
  local _obj_0 = require("helpers")
  color, round, randomseed, random, random_int, cos, sin, atan2, sqrt, sub, add, del, abs, min, max, floor, ceil = _obj_0.color, _obj_0.round, _obj_0.randomseed, _obj_0.random, _obj_0.random_int, _obj_0.cos, _obj_0.sin, _obj_0.atan2, _obj_0.sqrt, _obj_0.sub, _obj_0.add, _obj_0.del, _obj_0.abs, _obj_0.min, _obj_0.max, _obj_0.floor, _obj_0.ceil
end


Object = require "classic"
Vector = Object:extend()

function Vector:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Vector:__add(other)
  return Vector(self.x + other.x, self.y + other.y)
end


function Vector:__sub(other)
  return Vector(self.x - other.x, self.y - other.y)
end

function Vector:__mul(scalar)
  return Vector(self.x * scalar, self.y * scalar)
end

function Vector:__div(scalar)
  return Vector(self.x / scalar, self.y / scalar)
end

function Vector:__eq(other)
  return self.x == other.x and self.y == other.y
end

function Vector:__tostring()
  return "[" .. tostring(self.x) .. ", " .. tostring(self.y) .. "]"
end

function Vector:add(v)
  self.x = self.x + v.x
  self.y = self.y + v.y
  return self
end

function Vector:clone()
  return Vector(self.x, self.y)
end

function Vector:round()
  self.x = round(self.x)
  self.y = round(self.y)
  return self
end

function Vector:ceil()
  self.x = ceil(self.x)
  self.y = ceil(self.y)
  return self
end

function Vector:about_equals(v)
  return round(v.x) == self.x and round(v.y) == self.y
end

function Vector:angle()
  return atan2(self.x, self.y)
end

function Vector:length()
  return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector:scaled_length()
  return 182 * math.sqrt((self.x / 182) ^ 2 + (self.y / 182) ^ 2)
end

function Vector:perpendicular()
  return Vector(-self.y, self.x)
end

function Vector:normalize()
  local l = self:length()
  self.x = self.x / l
  self.y = self.y / l
  return self
end

function Vector:rotate(phi)
  local c = cos(phi)
  local s = sin(phi)
  local x = self.x
  local y = self.y
  self.x = (c * x) - (s * y)
  self.y = (s * x) + (c * y)
  return self
end

function Vector:draw_point(c)
  color(c)
  return love.graphics.points(round(self.x), round(self.y))
end

function Vector:draw_line(v, c)
  local a = self:clone()
  local b = v:clone()
  a:round()
  b:round()
  color(c)
  if a == b then
    return love.graphics.points(a.x, a.y, b.x, b.y)
  else
    return love.graphics.line(a.x, a.y, b.x, b.y)
  end
end

function Vector:draw_circle(radius, c, fill)
  local draw_mode = "line"
  if fill then
    draw_mode = "fill"
  end
  color(c)
  return love.graphics.circle(draw_mode, self.x, self.y, radius)
end

return {
  Vector = Vector
}
