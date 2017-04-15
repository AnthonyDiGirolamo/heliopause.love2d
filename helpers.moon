lume = require "lume"

-- If love isn't available
actual_random = math.random
randomseed = ->
  math.randomseed os.time()

if love
  actual_random = love.math.random
  randomseed = love.math.setRandomSeed

round = (i) ->
  math.floor i+.5

random = (a, b) ->
  if not a
    a, b = 0, 1
  if not b
    b = 0
  a + actual_random() * (b - a)

random_int = (n,minimum) ->
  math.floor random(n, minimum)

cos = (x) ->
  math.cos((x or 0)*math.pi*2)

sin = (x) ->
  -math.sin((x or 0)*math.pi*2)

atan2 = (x, y) ->
  (0.75 + math.atan2(x,y) / (math.pi * 2)) % 1.0

sqrt = math.sqrt
sub = string.sub
add = table.insert
del = lume.remove
abs = math.abs
min = math.min
max = math.max
floor = math.floor
ceil = math.ceil

picocolors = {
  {0x1D, 0x2B, 0x53}, -- 1 dark_blue
  {0x7E, 0x25, 0x53}, -- 2 dark_purple
  {0x00, 0x87, 0x51}, -- 3 dark_green
  {0xAB, 0x52, 0x36}, -- 4 brown
  {0x5F, 0x57, 0x4F}, -- 5 dark_gray
  {0xC2, 0xC3, 0xC7}, -- 6 light_gray
  {0xFF, 0xF1, 0xE8}, -- 7 white
  {0xFF, 0x00, 0x4D}, -- 8 red
  {0xFF, 0xA3, 0x00}, -- 9 orange
  {0xFF, 0xEC, 0x27}, -- 10 yellow
  {0x00, 0xE4, 0x36}, -- 11 green
  {0x29, 0xAD, 0xFF}, -- 12 blue
  {0x83, 0x76, 0x9C}, -- 13 indigo
  {0xFF, 0x77, 0xA8}, -- 14 pink
  {0xFF, 0xCC, 0xAA}, -- 15 peach
}
picocolors[0] = {0,0,0} -- 0 black

cls = ->
  love.graphics.clear()

color = (c) ->
  love.graphics.setColor(unpack(picocolors[c] or {0,0,0}))

circfill = (x, y, radius, c) ->
  color c
  love.graphics.circle("fill", x, y, radius)

-- rect(ax, ay, bx, by, c)
--   color(c)
--   local w = bx-ax
--   local h = bx-ax
--   -- -- print(ax..","..ay.." - "..bx..","..by.." - "..w..","..h.."\n")
--   -- if w==0 and h==0 then
--   --   love.graphics.points(ax, ay)
--   -- else
--     love.graphics.rectangle("line", ax, ay, w, h)
--   --
--
rectfill = (ax, ay, bx, by, c, style="fill") ->
  color c if c
  if bx < ax
    ax, bx = bx, ax
  if by < ay
    ay, by = by, ay

  if ax == bx or ay == by
    -- rectangle is only one pixel tall or wide
    love.graphics.line ax, ay, bx, by
  else
    love.graphics.rectangle(style,
      math.floor(ax),
      math.floor(ay),
      math.floor(bx - ax) + 1,
      math.floor(by - ay) + 1)

rect = (ax, ay, bx, by, c) ->
  rectfill ax, ay, bx, by, c, "line"

sset = (x, y) ->
  love.graphics.points(x+1, y+1)


band = (x, y) ->
	bit.band(x*0x10000, y*0x10000)/0x10000


bor = (x, y) ->
	bit.bor(x*0x10000, y*0x10000)/0x10000


bxor = (x, y) ->
	bit.bxor(x*0x10000, y*0x10000)/0x10000


bnot = (x) ->
	bit.bnot(x*0x10000)/0x10000


shl = (x, y) ->
	bit.lshift(x*0x10000, y)/0x10000


shr = (x, y) ->
	bit.arshift(x*0x10000, y)/0x10000


{
  :sset
  :rect
  :rectfill
  :circfill
  :cls
  :color
  :round
  :randomseed
  :random
  :random_int
  :cos
  :sin
  :atan2
  :sqrt
  :sub
  :add
  :del
  :abs
  :min
  :max
  :floor
  :ceil
  :band
  :bor
  :bxor
  :bnot
  :shl
  :shr
}
