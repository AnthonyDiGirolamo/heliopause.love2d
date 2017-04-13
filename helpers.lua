local lume = require("lume")
local actual_random = math.random
local randomseed
randomseed = function()
  return math.randomseed(os.time())
end
if love then
  actual_random = love.math.random
  randomseed = love.math.setRandomSeed
end
local round
round = function(i)
  return math.floor(i + .5)
end
local random
random = function(a, b)
  if not a then
    a, b = 0, 1
  end
  if not b then
    b = 0
  end
  return a + actual_random() * (b - a)
end
local random_int
random_int = function(n, minimum)
  return math.floor(random(n, minimum))
end
local cos
cos = function(x)
  return math.cos((x or 0) * math.pi * 2)
end
local sin
sin = function(x)
  return -math.sin((x or 0) * math.pi * 2)
end
local atan2
atan2 = function(x, y)
  return (0.75 + math.atan2(x, y) / (math.pi * 2)) % 1.0
end
local sqrt = math.sqrt
local sub = string.sub
local add = table.insert
local del = lume.remove
local abs = math.abs
local min = math.min
local max = math.max
local floor = math.floor
local ceil = math.ceil
local picocolors = {
  {
    0x1D,
    0x2B,
    0x53
  },
  {
    0x7E,
    0x25,
    0x53
  },
  {
    0x00,
    0x87,
    0x51
  },
  {
    0xAB,
    0x52,
    0x36
  },
  {
    0x5F,
    0x57,
    0x4F
  },
  {
    0xC2,
    0xC3,
    0xC7
  },
  {
    0xFF,
    0xF1,
    0xE8
  },
  {
    0xFF,
    0x00,
    0x4D
  },
  {
    0xFF,
    0xA3,
    0x00
  },
  {
    0xFF,
    0xEC,
    0x27
  },
  {
    0x00,
    0xE4,
    0x36
  },
  {
    0x29,
    0xAD,
    0xFF
  },
  {
    0x83,
    0x76,
    0x9C
  },
  {
    0xFF,
    0x77,
    0xA8
  },
  {
    0xFF,
    0xCC,
    0xAA
  }
}
picocolors[0] = {
  0,
  0,
  0
}
local cls
cls = function()
  return love.graphics.clear()
end
local color
color = function(c)
  return love.graphics.setColor(unpack(picocolors[c] or {
    0,
    0,
    0
  }))
end
local circfill
circfill = function(x, y, radius, c)
  color(c)
  return love.graphics.circle("fill", x, y, radius)
end
local rectfill
rectfill = function(ax, ay, bx, by, c)
  if c then
    color(c)
  end
  if bx < ax then
    ax, bx = bx, ax
  end
  if by < ay then
    ay, by = by, ay
  end
  if ax == bx or ay == by then
    return love.graphics.line(ax, ay, bx, by)
  else
    return love.graphics.rectangle("fill", math.floor(ax), math.floor(ay), math.floor(bx - ax) + 1, math.floor(by - ay) + 1)
  end
end
return {
  rectfill = rectfill,
  circfill = circfill,
  cls = cls,
  color = color,
  round = round,
  randomseed = randomseed,
  random = random,
  random_int = random_int,
  cos = cos,
  sin = sin,
  atan2 = atan2,
  sqrt = sqrt,
  sub = sub,
  add = add,
  del = del,
  abs = abs,
  min = min,
  max = max,
  floor = floor,
  ceil = ceil
}
