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

{
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
}
