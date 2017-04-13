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
return {
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
