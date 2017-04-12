local color
color = require("pico_api").color
local round, randomseed, random, random_int, cos, sin, sqrt, sub, add, del, abs, min, max, floor, ceil
do
  local _obj_0 = require("helpers")
  round, randomseed, random, random_int, cos, sin, sqrt, sub, add, del, abs, min, max, floor, ceil = _obj_0.round, _obj_0.randomseed, _obj_0.random, _obj_0.random_int, _obj_0.cos, _obj_0.sin, _obj_0.sqrt, _obj_0.sub, _obj_0.add, _obj_0.del, _obj_0.abs, _obj_0.min, _obj_0.max, _obj_0.floor, _obj_0.ceil
end
local twopi = math.pi * 2
local Vector
do
  local _class_0
  local _base_0 = {
    __add = function(self, other)
      return Vector(self.x + other.x, self.y + other.y)
    end,
    __sub = function(self, other)
      return Vector(self.x - other.x, self.y - other.y)
    end,
    __mul = function(self, scalar)
      return Vector(self.x * scalar, self.y * scalar)
    end,
    __div = function(self, scalar)
      return Vector(self.x / scalar, self.y / scalar)
    end,
    __eq = function(self, other)
      return self.x == other.x and self.y == other.y
    end,
    __tostring = function(self)
      return "[" .. tostring(self.x) .. ", " .. tostring(self.y) .. "]"
    end,
    add = function(self, v)
      self.x = self.x + v.x
      self.y = self.y + v.y
      return self
    end,
    clone = function(self)
      return Vector(self.x, self.y)
    end,
    round = function(self)
      self.x = round(self.x)
      self.y = round(self.y)
      return self
    end,
    ceil = function(self)
      self.x = ceil(self.x)
      self.y = ceil(self.y)
      return self
    end,
    about_equals = function(self, v)
      return round(v.x) == self.x and round(v.y) == self.y
    end,
    angle = function(self)
      local a = math.atan2(self.y, self.x) / twopi
      if a < 0 then
        a = (.5 - -1 * a) + .5
      end
      return a
    end,
    length = function(self)
      return math.sqrt(self.x ^ 2 + self.y ^ 2)
    end,
    scaled_length = function(self)
      return 182 * math.sqrt((self.x / 182) ^ 2 + (self.y / 182) ^ 2)
    end,
    perpendicular = function(self)
      return Vector(-self.y, self.x)
    end,
    normalize = function(self)
      local l = self:length()
      self.x = self.x / l
      self.y = self.y / l
      return self
    end,
    rotate = function(self, phi)
      local c = cos(phi)
      local s = sin(phi)
      self.x = c * self.x - s * self.y
      self.y = s * self.x + c * self.y
      return self
    end,
    draw_point = function(self, c)
      color(c)
      return love.graphics.points(round(self.x), round(self.y))
    end,
    draw_line = function(self, v, c)
      local a = self:clone()
      local b = v:clone()
      a:round()
      b:round()
      color(c)
      if a == b then
        return love.graphics.points(a.x, a.y)
      else
        return love.graphics.line(a.x, a.y, b.x, b.y)
      end
    end,
    draw_circle = function(self, radius, c, fill)
      local draw_mode = "line"
      if fill then
        draw_mode = "fill"
      end
      color(c)
      return love.graphics.circle(draw_mode, self.x, self.y, radius)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x = x or 0
      self.y = y or 0
    end,
    __base = _base_0,
    __name = "Vector"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vector = _class_0
end
return {
  Vector = Vector
}
