local lume = require("lume")

local actual_random = math.random

function randomseed()
  return math.randomseed(os.time())
end

if love then
  actual_random = love.math.random
  randomseed = love.math.setRandomSeed
end

function round(i)
  return math.floor(i + .5)
end

function random(a, b)
  if not a then
    a, b = 0, 1
  end
  if not b then
    b = 0
  end
  return a + actual_random() * (b - a)
end

function random_int(n, minimum)
  return math.floor(random(n, minimum))
end

function cos(x)
  return math.cos((x or 0) * math.pi * 2)
end

function sin(x)
  return -math.sin((x or 0) * math.pi * 2)
end

function atan2(x, y)
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
  {0x1D / 0xFF, 0x2B / 0xFF, 0x53 / 0xFF}, -- 1 dark_blue
  {0x7E / 0xFF, 0x25 / 0xFF, 0x53 / 0xFF}, -- 2 dark_purple
  {0x00 / 0xFF, 0x87 / 0xFF, 0x51 / 0xFF}, -- 3 dark_green
  {0xAB / 0xFF, 0x52 / 0xFF, 0x36 / 0xFF}, -- 4 brown
  {0x5F / 0xFF, 0x57 / 0xFF, 0x4F / 0xFF}, -- 5 dark_gray
  {0xC2 / 0xFF, 0xC3 / 0xFF, 0xC7 / 0xFF}, -- 6 light_gray
  {0xFF / 0xFF, 0xF1 / 0xFF, 0xE8 / 0xFF}, -- 7 white
  {0xFF / 0xFF, 0x00 / 0xFF, 0x4D / 0xFF}, -- 8 red
  {0xFF / 0xFF, 0xA3 / 0xFF, 0x00 / 0xFF}, -- 9 orange
  {0xFF / 0xFF, 0xEC / 0xFF, 0x27 / 0xFF}, -- 10 yellow
  {0x00 / 0xFF, 0xE4 / 0xFF, 0x36 / 0xFF}, -- 11 green
  {0x29 / 0xFF, 0xAD / 0xFF, 0xFF / 0xFF}, -- 12 blue
  {0x83 / 0xFF, 0x76 / 0xFF, 0x9C / 0xFF}, -- 13 indigo
  {0xFF / 0xFF, 0x77 / 0xFF, 0xA8 / 0xFF}, -- 14 pink
  {0xFF / 0xFF, 0xCC / 0xFF, 0xAA / 0xFF}  -- 15 peach
}
picocolors[0] = {0,0,0} -- 0 black

function cls()
  return love.graphics.clear()
end

function color(c)
  return love.graphics.setColor(unpack(picocolors[c] or {0, 0, 0}))
end

function circfill(x, y, radius, c)
  color(c)
  return love.graphics.circle("fill", x, y, radius)
end

function rectfill(ax, ay, bx, by, c, style)
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
    -- rectangle is only one pixel tall or wide
    return love.graphics.line(ax, ay, bx, by)
  else
    return love.graphics.rectangle(style, math.floor(ax), math.floor(ay), math.floor(bx - ax) + 1, math.floor(by - ay) + 1)
  end
end

function rect(ax, ay, bx, by, c)
  return rectfill(ax, ay, bx, by, c, "line")
end

function sset(x, y)
  return love.graphics.points(x + 1, y + 1)
end

function band(x, y)
  return bit.band(x * 0x10000, y * 0x10000) / 0x10000
end

function bor(x, y)
  return bit.bor(x * 0x10000, y * 0x10000) / 0x10000
end

function bxor(x, y)
  return bit.bxor(x * 0x10000, y * 0x10000) / 0x10000
end

function bnot(x)
  return bit.bnot(x * 0x10000) / 0x10000
end

function shl(x, y)
  return bit.lshift(x * 0x10000, y) / 0x10000
end

function shr(x, y)
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
