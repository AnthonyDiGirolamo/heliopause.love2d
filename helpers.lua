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
    0x1D / 0xFF,
    0x2B / 0xFF,
    0x53 / 0xFF
  },
  {
    0x7E / 0xFF,
    0x25 / 0xFF,
    0x53 / 0xFF
  },
  {
    0x00 / 0xFF,
    0x87 / 0xFF,
    0x51 / 0xFF
  },
  {
    0xAB / 0xFF,
    0x52 / 0xFF,
    0x36 / 0xFF
  },
  {
    0x5F / 0xFF,
    0x57 / 0xFF,
    0x4F / 0xFF
  },
  {
    0xC2 / 0xFF,
    0xC3 / 0xFF,
    0xC7 / 0xFF
  },
  {
    0xFF / 0xFF,
    0xF1 / 0xFF,
    0xE8 / 0xFF
  },
  {
    0xFF / 0xFF,
    0x00 / 0xFF,
    0x4D / 0xFF
  },
  {
    0xFF / 0xFF,
    0xA3 / 0xFF,
    0x00 / 0xFF
  },
  {
    0xFF / 0xFF,
    0xEC / 0xFF,
    0x27 / 0xFF
  },
  {
    0x00 / 0xFF,
    0xE4 / 0xFF,
    0x36 / 0xFF
  },
  {
    0x29 / 0xFF,
    0xAD / 0xFF,
    0xFF / 0xFF
  },
  {
    0x83 / 0xFF,
    0x76 / 0xFF,
    0x9C / 0xFF
  },
  {
    0xFF / 0xFF,
    0x77 / 0xFF,
    0xA8 / 0xFF
  },
  {
    0xFF / 0xFF,
    0xCC / 0xFF,
    0xAA / 0xFF
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
rectfill = function(ax, ay, bx, by, c, style)
  if style == nil then
    style = "fill"
  end
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
    return love.graphics.rectangle(style, math.floor(ax), math.floor(ay), math.floor(bx - ax) + 1, math.floor(by - ay) + 1)
  end
end
local rect
rect = function(ax, ay, bx, by, c)
  return rectfill(ax, ay, bx, by, c, "line")
end
local sset
sset = function(x, y)
  return love.graphics.points(x + 1, y + 1)
end
local band
band = function(x, y)
  return bit.band(x * 0x10000, y * 0x10000) / 0x10000
end
local bor
bor = function(x, y)
  return bit.bor(x * 0x10000, y * 0x10000) / 0x10000
end
local bxor
bxor = function(x, y)
  return bit.bxor(x * 0x10000, y * 0x10000) / 0x10000
end
local bnot
bnot = function(x)
  return bit.bnot(x * 0x10000) / 0x10000
end
local shl
shl = function(x, y)
  return bit.lshift(x * 0x10000, y) / 0x10000
end
local shr
shr = function(x, y)
  return bit.arshift(x * 0x10000, y) / 0x10000
end
return {
  sset = sset,
  rect = rect,
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
  ceil = ceil,
  band = band,
  bor = bor,
  bxor = bxor,
  bnot = bnot,
  shl = shl,
  shr = shr
}
