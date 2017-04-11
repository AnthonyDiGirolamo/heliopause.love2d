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

cos = (n) ->
  math.cos(n*2*math.pi)

sin = (n) ->
  math.sin(n*2*math.pi)

sqrt = math.sqrt
sub = string.sub
add = table.insert
del = lume.remove
abs = math.abs
min = math.min
max = math.max
floor = math.floor
ceil = math.ceil

-- print round(1.6)
-- print round(1.4)
{
  :round
  :randomseed
  :random
  :random_int
  :cos
  :sin
  :sqrt
  :sub
  :add
  :del
  :abs
  :min
  :max
  :floor
  :ceil
}
