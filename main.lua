debug = true
local shine = require("shine")
local lume = require("lume")
Object = require("classic")

local round, randomseed, random, random_int, cos, sin, sqrt, sub, add, del, abs, min, max, floor, ceil, rect, rectfill,
      circfill, cls, color, sset, band, bor, bxor, bnot, shl, shr

do
  local _obj_0 = require("helpers")
  rect       =  _obj_0.rect
  rectfill   =  _obj_0.rectfill
  circfill   =  _obj_0.circfill
  cls        =  _obj_0.cls
  color      =  _obj_0.color
  round      =  _obj_0.round
  randomseed =  _obj_0.randomseed
  random     =  _obj_0.random
  random_int =  _obj_0.random_int
  cos        =  _obj_0.cos
  sin        =  _obj_0.sin
  sqrt       =  _obj_0.sqrt
  sub        =  _obj_0.sub
  add        =  _obj_0.add
  del        =  _obj_0.del
  abs        =  _obj_0.abs
  min        =  _obj_0.min
  max        =  _obj_0.max
  floor      =  _obj_0.floor
  ceil       =  _obj_0.ceil
  sset       =  _obj_0.sset
  band       =  _obj_0.band
  -- bor        =  _obj_0.bor
  -- bxor       =  _obj_0.bxor
  -- bnot       =  _obj_0.bnot
  -- shl        =  _obj_0.shl
  -- shr        =  _obj_0.shr
end

-- load vector.moon
local Vector
do
  local _obj_0 = require("vector")
  Vector = _obj_0.Vector
end

local TouchInput
do
  local _obj_0 = require("touch_input")
  TouchInput = _obj_0.TouchInput
end

function stat(args)
  return 0
end

-- LuaFormatter off
black       = 0
dark_blue   = 1
dark_purple = 2
dark_green  = 3
brown       = 4
dark_gray   = 5
light_gray  = 6
white       = 7
red         = 8
orange      = 9
yellow      = 10
green       = 11
blue        = 12
indigo      = 13
pink        = 14
peach       = 15
-- LuaFormatter on

local deg90 = math.pi * 0.5
local deg180 = math.pi
local deg270 = math.pi * 1.5
local debug_messages
local game_screen
local sect

function vector_distance(a, b)
  return (b - a):length()
end

GameScreen = Object:extend()

function GameScreen:new(width, height)
  self.screen_width = width
  self.screen_height = height
  self.rotation = deg270
  self.int_zoom_levels = {}
  self.int_zoom_index = 1
  self.pixel_width = width
  self.pixel_height = height
  self.screen_center = Vector(floor(width / 2), floor(height / 2))
end

function GameScreen:calc_int_zoom_levels()
  local izl = {}
  table.insert(izl, 1)

  local divisor = 1
  while true do
    divisor = divisor + 1
    local xquotient = self.screen_width / divisor
    local yquotient = self.screen_height / divisor
    if xquotient < 128 or yquotient < 128 then break end
    if math.fmod(self.screen_width, divisor) == 0 and math.fmod(self.screen_height, divisor) == 0 then
      table.insert(izl, divisor)
    end
  end
  self.int_zoom_levels = izl
end

function GameScreen:draw_canvas()
  if self:rotation_is_landscape() then
    love.graphics
        .draw(game_screen_canvas, 0, 0, self.rotation, game_screen.screen_width / game_screen.pixel_width, -- scale x
    game_screen.screen_height / game_screen.pixel_height -- scale y
    -- 0, -- Origin offset (x-axis).
    -- 0, -- Origin offset (y-axis).
    -- 0, -- Shearing factor (x-axis).
    -- 0 -- Shearing factor (y-axis).
    )
  else
    -- if self:rotation_is_portrait() then
    love.graphics.draw(game_screen_canvas, -- canvas
    0, -- position x
    game_screen.screen_height, -- position y
    self.rotation, -- rotation?
    game_screen.screen_height / game_screen.pixel_width, -- scale x
    game_screen.screen_width / game_screen.pixel_height -- scale y
    -- 0, -- Origin offset (x-axis).
    -- 0, -- Origin offset (y-axis).
    -- 0, -- Shearing factor (x-axis).
    -- 0 -- Shearing factor (y-axis).
    )
  end

end

function GameScreen:set_pixel_screen_size()
  -- update canvas size

  game_screen_canvas = love.graphics.newCanvas(self.pixel_width, self.pixel_height)
  game_screen_canvas:setFilter("nearest", "nearest")

  self.screen_center.x = round(self.pixel_width / 2)
  self.screen_center.y = round(self.pixel_height / 2)

  mmap_sizes = {floor(self.pixel_width * .375), self.pixel_width, 0}
  mmap_sizes[0] = floor(self.pixel_width * .1875)
  setup_mmap()

  if self.old_screen_center then

    -- make changes based on new screen center
    local screen_center_diff = self.screen_center - self.old_screen_center

    if screen_center_diff.x ~= 0 and screen_center_diff.y ~= 0 then
      -- update screen position of things that only exist in screen space. that is, no sector positions
      if sect then
        for index, star in ipairs(sect.starfield) do
          star.position:add(screen_center_diff)
          -- star:reset()
        end

        -- check starfield density
        local old_star_count = starfield_count
        local new_star_count = round(self.old_star_density * (self.pixel_width * self.pixel_height))
        starfield_count = new_star_count
        -- new stars are added/deleted in sector:scroll_starfield()

        -- Ship particle debris (sparks) and explosions
        for index, p in ipairs(particles) do p.screen_position:add(screen_center_diff) end

        for index, p in ipairs(projectiles) do
          -- if cannon shots (not a missile)
          if not p.sector_position then p.screen_position:add(screen_center_diff) end
        end
      end -- if sect

    end -- if screen center changed

  end -- end if old_screen_center

end

function GameScreen:rotate()
  if self.rotation == 0 then
    -- portrait
    self.rotation = deg270
  elseif self.rotation == deg270 then
    -- landscape
    self.rotation = 0
  end

  -- if self.rotation == 0 then
  --   -- portrait reversed
  --   self.rotation = deg90
  -- elseif self.rotation == deg90 then
  --   -- landscape reversed
  --   self.rotation = deg180
  -- elseif self.rotation == deg180 then
  --   -- portrait
  --   self.rotation = deg270
  -- elseif self.rotation == deg270 then
  --   -- landscape
  --   self.rotation = 0
  -- end
  self.pixel_height, self.pixel_width = self.pixel_width, self.pixel_height
  self:canvas_size_add()
  buttons:rotate()

  -- redistribute stars
  for index, star in ipairs(sect.starfield) do star:reset() end
end

function GameScreen:rotation_is_landscape()
  return self.rotation == 0 or self.rotation == 180
end

function GameScreen:rotation_is_portrait()
  return self.rotation == deg270 or self.rotation == 90
end

function GameScreen:zoom_out()
  if self:rotation_is_portrait() and self.pixel_height <= self.screen_width - 4 then
    self:canvas_size_add(4)
  elseif self:rotation_is_landscape() and self.pixel_width <= self.screen_width - 4 then
    self:canvas_size_add(4)
  end
end

function GameScreen:zoom_in()
  if self:rotation_is_portrait() and self.pixel_width >= 128 + 4 then
    self:canvas_size_add(-4)
  elseif self:rotation_is_landscape() and self.pixel_height >= 128 + 4 then
    self:canvas_size_add(-4)
  end
end

function GameScreen:int_zoom_out()
  self.int_zoom_index = self.int_zoom_index - 1
  if self.int_zoom_index < 1 then
    self.int_zoom_index = 1
  else
    self:set_int_zoom(self.int_zoom_index)
  end
end

function GameScreen:int_zoom_in()
  self.int_zoom_index = self.int_zoom_index + 1
  if self.int_zoom_index > #self.int_zoom_levels then
    self.int_zoom_index = #self.int_zoom_levels
  else
    self:set_int_zoom(self.int_zoom_index)
  end
end

function GameScreen:set_int_zoom(level)

  if starfield_count then self.old_star_density = starfield_count / (self.pixel_width * self.pixel_height) end
  self.old_screen_center = self.screen_center:clone()

  local divisor = self.int_zoom_levels[level]

  self.int_zoom_index = level

  if self:rotation_is_landscape() then
    self.pixel_width = floor(self.screen_width / divisor)
    self.pixel_height = floor(self.screen_height / divisor)
  else
    self.pixel_height = floor(self.screen_width / divisor)
    self.pixel_width = floor(self.screen_height / divisor)
  end

  self:set_pixel_screen_size()

  if sect then
    -- reset existing stars
    for i, star in ipairs(sect.starfield) do star:reset() end
    -- add new stars in reset positions
    local stars_to_add = starfield_count - #sect.starfield
    for i = 1, stars_to_add do
      if #sect.starfield >= 600 then break end
      add(sect.starfield, Star():reset())
    end
  end -- if sect

end

function GameScreen:canvas_size_add(amount)
  local diff = amount or 0
  self.old_star_density = starfield_count / (self.pixel_width * self.pixel_height)
  self.old_screen_center = self.screen_center:clone()

  self.pixel_width = self.pixel_width + diff

  if self:rotation_is_landscape() then
    self.pixel_height = floor(self.pixel_width * (self.screen_height / self.screen_width))
  else
    self.pixel_height = floor(self.pixel_width * (self.screen_width / self.screen_height))
  end

  self:set_pixel_screen_size()
end

function btn(number, player)
  return buttons:btn(number)
end

function btnp(number, player)
  return buttons:btnp(number)
end

-- titlestarv=Vector(3,-7)
-- star_color_index=0
-- star_color_monochrome=0
-- split_start=1
-- star_colors=nsplit"xaecd76|x98d165|x421051|x767676|x656565|x515151|"
---- star_colors={{0xa,0xe,0xc,0xd,0x7,0x6},{0x9,0x8,0xd,0x1,0x6,0x5},{0x4,0x2,0x1,0x0,0x5,0x1},{0x7,0x6,0x7,0x6,0x7,0x6},{0x6,0x5,0x6,0x5,0x6,0x5},{0x5,0x1,0x5,0x1,0x5,0x1}}
-- sect = Sector()

local debugfont_size = 10

function love.load(arg)

  -- love.window.setMode(1920,1440)
  love.window.setFullscreen(true)
  zoom_offset = Vector(0, 0)
  time = 0
  -- game_screen.screen_width, game_screen.screen_height = 1366, 768

  -- game_screen.screen_width = love.graphics.setWidth(1366)
  -- game_screen.screen_height = love.graphics.setHeight(768)

  game_screen = GameScreen(love.graphics.getWidth(), love.graphics.getHeight())
  game_screen:calc_int_zoom_levels()

  -- game_screen.screen_width = love.graphics.getWidth()
  -- game_screen.screen_height = love.graphics.getHeight()

  debugfont_size = round(love.graphics.getWidth() * 0.01)

  -- -- portait
  -- game_screen.pixel_width = 160
  -- game_screen.pixel_height = floor(game_screen.pixel_width*(game_screen.screen_width/game_screen.screen_height))

  -- landscape
  -- game_screen.pixel_width = 256
  -- game_screen.pixel_height = floor(game_screen.pixel_width*(game_screen.screen_height/game_screen.screen_width))

  game_screen:set_int_zoom(#game_screen.int_zoom_levels)
  -- game_screen:set_pixel_screen_size()

  -- game_screen.pixel_width, game_screen.pixel_height = 160, 160
  -- game_screen.pixel_width, game_screen.pixel_height = 256, 256
  starfield_count = floor(10 * (game_screen.pixel_width * game_screen.pixel_height) / (128 * 128))

  buttons = TouchInput(game_screen.screen_width, game_screen.screen_height, true)

  pixelfont = love.graphics.newFont("PICO-8.ttf", 5)
  -- pixelfont = love.graphics.newFont("Droid Sans Mono.ttf", 12)

  debugfont = love.graphics.newFont(debugfont_size)
  -- debugfont = love.graphics.newFont("small_font.ttf", 8)
  -- debugfont = love.graphics.newFont("PragmataProMono.ttf", 32)
  -- debugfont = love.graphics.newFont("iosevka-ss08-regular.ttf", debugfont_size)

  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")
  -- love.graphics.setLineStyle("smooth")

  game_screen_canvas = love.graphics.newCanvas(game_screen.pixel_width, game_screen.pixel_height)
  game_screen_canvas:setFilter("nearest", "nearest")
  -- game_screen_canvas:setFilter("linear", "linear", 1)

  -- local grain = shine.filmgrain()
  -- grain.opacity = 0.2
  -- local vignette = shine.vignette()
  -- vignette.parameters = {radius = 0.9, opacity = 0.7}
  -- local desaturate = shine.desaturate{strength = 0.6, tint = {255,250,200}}
  -- post_effect = desaturate:chain(grain):chain(vignette)
  -- post_effect.opacity = 0.5 -- affects both vignette and film grain
  -- post_effect = shine.scanlines()
  -- post_effect.opacity = 0.5 -- affects both vignette and film grain

  love.filesystem.setIdentity('heliopause')
  love.keyboard.setTextInput(true)

  _init()
  -- use landscape by default
  game_screen:rotate()
end

local touches
function love.update(dt)
  time = time + dt
  -- game_screen.screen_width = love.graphics.getWidth()
  -- game_screen.screen_height = love.graphics.getHeight()

  touches = love.touch.getTouches()
  buttons:get_presses(touches, love.timer.getDelta())

  _update()
end

function love.textinput(t)
end

-- Keyboard Keys
function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "p" then pilot:buildship() end
  if key == "b" then
    local px = pilot.sector_position.x
    local py = pilot.sector_position.y
    add(sect.planets, Planet(px, py, ((1 - Vector(px, py):angle()) - .25) % 1))
  end
  if key == "j" then load_sector() end
  if key == "c" then
    local planet, dist = nearest_planet()
    add_npc(planet)
  end
  -- if key == "s" then
  --   local screenshot = love.graphics.newScreenshot();
  --   screenshot:encode('png', os.time() .. '.png');
  -- end

  if key == "," then
    paused = not paused
    if paused then
      -- sfx(51,2)
      main_menu()
    end
  end

  if key == "0" then game_screen:rotate() end

  if key == "[" then game_screen:int_zoom_out() end
  if key == "]" then game_screen:int_zoom_in() end

end

function love.draw()

  love.graphics.setCanvas(game_screen_canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.setFont(pixelfont)

  debug_text_x = ceil(game_screen.screen_width * 0.0175)
  debug_text_y = ceil(game_screen.screen_height * 0.0517)

  debug_messages = {
    ("fps:     " .. love.timer.getFPS() .. ", delta_t: " .. love.timer.getDelta()), -- ("time:    " .. time),
    -- ("os.time: " .. os.time()),
    ("screen: [" .. game_screen.screen_width .. ", " .. game_screen.screen_height .. "], " .. "canvas: [" ..
        game_screen.pixel_width .. ", " .. game_screen.pixel_height .. "]"),
    ("starfield_count: " .. starfield_count .. ", #starfield: " .. #sect.starfield),
    -- ("Starfield Density: " .. starfield_count / (game_screen.pixel_width * game_screen.pixel_height))
    ("#planets: " .. #sect.planets)
  }

  _draw()

  love.graphics.setCanvas()
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(255, 255, 255, 255)

  -- post_effect:draw(function()

  game_screen:draw_canvas()
  -- -- center landscape
  -- love.graphics.draw(
  --   game_screen_canvas,
  --   (game_screen.screen_width-game_screen.screen_height)/2, -- x
  --   0, -- y
  --   0, -- radians
  --   -- deg270, -- radians
  --   game_screen.screen_height/game_screen.pixel_height, -- scale x
  --   game_screen.screen_height/game_screen.pixel_height -- scale y
  --   -- 0, -- Origin offset (x-axis).
  --   -- 0, -- Origin offset (y-axis).
  --   -- 0, -- Shearing factor (x-axis).
  --   -- 0 -- Shearing factor (y-axis).
  -- ) -- scale y

  -- end)

  -- positionx, positiony, rotation, scalex, scaley

  -- -- Observe the difference if the Canvas is drawn with the regular alpha blend mode instead.
  -- love.graphics.setBlendMode("alpha")
  -- love.graphics.draw(canvas, 100, 0)

  -- -- Rectangle is drawn directly to the screen with the regular alpha blend mode.
  -- love.graphics.setBlendMode("alpha")
  -- love.graphics.setColor(255, 255, 0, 128)
  -- love.graphics.rectangle('fill', 200, 0, 100, 100)

  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  -- TODO: Check if touchscreen is supported with love2d
  -- Note: touch screen buttons work on GPD win max 2 linux
  buttons:draw()

  color(7)
  love.graphics.setFont(debugfont)

  for i, is_pressed in ipairs(buttons.hold_time) do
    if is_pressed > 0 then table.insert(debug_messages, "button " .. (i - 1) .. " is pressed for " .. is_pressed) end
  end

  if #touches > 0 then
    for i, id in ipairs(touches) do
      local x, y = love.touch.getPosition(id)
      add(debug_messages, "touch " .. i .. ": " .. x .. ", " .. y)
    end
  end

  if buttons.touch_location_angle then
    table.insert(debug_messages, "touch_angle: " .. buttons.touch_location_angle)
    table.insert(debug_messages, "touch_length: " .. buttons.touch_location_length)
    table.insert(debug_messages, "touch_location: " .. buttons.touch_location:__tostring())
  end

  -- mi=buttons.touch_location_angle-.375
  -- mi=floor(4*mi)+1
  -- mi = mi % 4
  -- table.insert(debug_messages, "mi: "..mi)

  local index_messages = "integer zoom levels: "
  for i, num in ipairs(game_screen.int_zoom_levels) do
    if i == game_screen.int_zoom_index then
      index_messages = index_messages .. "[" .. num .. "]" .. ", "
    else
      index_messages = index_messages .. num .. ", "
    end
  end
  table.insert(debug_messages, index_messages)

  for i, message in ipairs(debug_messages) do

    if game_screen.rotation == deg270 then
      -- portait deg270
      love.graphics.print(message, i * debugfont_size + debug_text_y, -- game_screen.screen_height,
      game_screen.screen_height - debug_text_x, deg270)
    else
      -- landscape deg0
      love.graphics.print(message, debug_text_x, i * debugfont_size + debug_text_y, 0)
    end

  end

end

function split(s)
  local t, start_index, ti = {}, 2, split_start or 0
  local mode = sub(s, 1, 1)
  for i = 2, #s do
    local c = sub(s, i, i)
    if mode == "x" then
      t[ti] = ("0x" .. c) + 0
      ti = ti + 1
    elseif c == "," then
      local sstr = sub(s, start_index, i - 1)
      if mode == "a" then
        if sstr == "nil" then sstr = nil end
        t[ti] = sstr
      else
        t[ti] = sstr + 0
      end
      ti = ti + 1
      start_index = i + 1
    end
  end
  return t
end

function nsplit(s)
  local t, start_index, ti = {}, 1, split_start or 0
  for i = 1, #s do
    if sub(s, i, i) == "|" then
      t[ti] = split(sub(s, start_index, i - 1))
      ti = ti + 1
      start_index = i + 1
    end
  end
  return t
end

function rotated_angle(len)
  return rotated_vector(random(), len)
end

function rotated_vector(angle, x, y)
  return Vector(x or 1, y):rotate(angle)
end

function round(i)
  return floor(i + .5)
end

function format(num)
  local n = floor(num * 10 + 0.5) / 10
  return floor(n) .. "." .. round((n % 1) * 10)
end

Ship = Object:extend()
function Ship:new(h)
  self.npc = false
  self.hostile = h
  self.screen_position = game_screen.screen_center
  self.sector_position = Vector()
  self.cur_deltav = 0
  self.cur_gees = 0
  self.angle = 0
  self.angle_radians = 0
  self.heading = 90
  self.velocity_angle = 0
  self.velocity_angle_opposite = 180
  self.velocity = 0
  self.velocity_vector = Vector()
  self.orders = {}
  self.last_fire_time = -6
end

function Ship:buildship(seed, stype)
  self.ship_type_index = stype or random_int(#ship_types) + 1

  local seed_value = seed or random_int(32767)
  randomseed(seed_value)
  self.seed_value = seed_value
  self.name = ship_names[self.ship_type_index]
  local shape = ship_types[self.ship_type_index]

  local ship_colors = split "x6789abcdef"
  for i = 1, 6 do del(ship_colors, ship_colors[random_int(#ship_colors) + 1]) end

  local hp = 0
  local ship_mask = {}
  local rows = random_int(shape[#shape] + 1, shape[#shape - 1])
  local cols = floor(rows / 2)

  for y = 1, rows do
    add(ship_mask, {})
    for x = 1, cols do add(ship_mask[y], ship_colors[4]) end
  end

  local slopei, slope = 2, Vector(1, shape[1])

  for y = 2, rows - 1 do

    for x = 1, cols do

      local color = ship_colors[1 + floor((y + random_int(3) - 1) / rows * 3)]

      if cols - x < max(0, floor(slope.y)) then
        if random() < .6 then
          ship_mask[y][x] = color
          hp = hp + 1
          if ship_mask[y - 1][x] == ship_colors[4] then ship_mask[y][x] = darkshipcolors[color] end
        end
      end

    end

    if y >= floor(shape[slopei + 1] * rows) then slopei = slopei + 2 end
    slope = slope + Vector(1, shape[slopei])

    if slope.y > 0 and y > 3 and y < rows - 1 then
      for i = 1, random_int(round(slope.y / 4) + 1) do
        ship_mask[y][cols - i] = 5
        hp = hp + 2
      end
    end

  end

  local odd_columns = random_int(2)
  for y = rows, 1, -1 do for x = cols - odd_columns, 1, -1 do add(ship_mask[y], ship_mask[y][x]) end end

  if self.ship_type_index == #ship_types then hp = hp * 4 end

  self.hp = hp
  self.max_hp = hp
  self.hp_percent = 1
  self.deltav = max(hp * -0.0188 + 4.5647, 1) * 0.0326
  local turn_factor = 1
  if self.ship_type_index == 4 then turn_factor = turn_factor * .5 end
  self.turn_rate = round(turn_factor * max(hp * -0.0470 + 11.4117, 2))
  self.turn_rate = 180
  self.sprite_rows = rows
  self.sprite_columns = #ship_mask[1]
  self.transparent_color = ship_colors[4]
  self.sprite = ship_mask
  return self
end

function Ship:set_position_near_object(obj)
  local radius = obj.radius or obj.sprite_rows
  self.sector_position = rotated_angle(1.2 * radius) + obj.sector_position
  self:reset_velocity()
end

function Ship:clear_target()
  self.target_index = nil
  self.target = nil
end

function Ship:targeted_color()
  if self.hostile then
    return 8, 2
  else
    return 11, 3
  end
end

function Ship:draw_sprite_rotated(offscreen_pos, angle)
  if self.dead then return end
  local screen_position = offscreen_pos or self.screen_position
  local a = angle or self.angle_radians
  local rows, cols = self.sprite_rows, self.sprite_columns
  local tcolor = self.transparent_color
  local projectile_hit_by
  local close_projectiles = {}

  if self.targeted then
    local targetcircle_radius = round(rows / 2) + 4
    local circlecolor, circleshadow = self:targeted_color()
    local targetcircle_screen_position = screen_position + zoom_offset
    if offscreen_pos then
      (targetcircle_screen_position + Vector(1, 1)):draw_circle(targetcircle_radius, circleshadow, true)
      targetcircle_screen_position:draw_circle(targetcircle_radius, 0, true)
    end
    targetcircle_screen_position:draw_circle(targetcircle_radius, circlecolor)
  end

  for index, p in ipairs(projectiles) do
    if p.firing_ship ~= self then
      if (p.sector_position and offscreen_pos and (self.sector_position - p.sector_position):length() <= rows) or
          vector_distance(p.screen_position, screen_position) < rows then add(close_projectiles, p) end
    end
  end

  for y = 1, cols do
    for x = 1, rows do
      local color = self.sprite[x][y]
      if color ~= tcolor and color ~= nil then

        local pixel1 = Vector(rows - x - floor(rows / 2), y - floor(cols / 2) - 1)
        local pixel2 = Vector(pixel1.x + 1, pixel1.y)
        pixel1:rotate(a):add(screen_position):round()
        pixel2:rotate(a):add(screen_position):round()

        if self.hp < 1 and random() < .8 then
          make_explosion(pixel1, rows / 2, 18, self.velocity_vector)
          -- sfx(55,2)
          if not offscreen_pos then
            for i = 1, random_int(4, 2), 1 do
              add(particles, Spark(pixel1 + zoom_offset,
                                   rotated_angle(random(.25) + .25) + self.velocity_vector,
                                   color,
                                   128 + random_int(32)))
            end
          end

        else

          for index, projectile in ipairs(close_projectiles) do

            local impact = false
            if not offscreen_pos and
                (pixel1:about_equals(projectile.screen_position) or
                    (projectile.position2 and pixel1:about_equals(projectile.position2))) then
              impact = true
            elseif offscreen_pos and projectile.last_offscreen_pos and
                pixel1:about_equals(projectile.last_offscreen_pos) then
              impact = true
            end

            if impact then
              projectile_hit_by = projectile.firing_ship
              local damage = projectile.damage or 1
              self.hp = self.hp - damage
              if damage > 10 then
                make_explosion(pixel1, 8, 12, self.velocity_vector)
                -- sfx(57,1)
              else
                make_explosion(pixel1, 2, 6, self.velocity_vector)
                -- sfx(56,2)
              end
              local old_hp_percent = self.hp_percent
              self.hp_percent = self.hp / self.max_hp
              if not self.npc and old_hp_percent > .1 and self.hp_percent <= .1 then
                note_add("thruster malfunction")
              end
              -- if random()<.5 then
              add(particles, Spark(pixel1, rotated_angle(random(2) + 1) + self.velocity_vector, color, 128))
              -- end
              del(projectiles, projectile)
              self.sprite[x][y] = -5
              color = -5
              break
            end

          end

          if color < 0 then color = 5 end

          pixel1:add(zoom_offset)
          pixel2:add(zoom_offset)
          rectfill(pixel1.x, pixel1.y, pixel2.x, pixel2.y, color)
          -- pixel1:draw_line(pixel2, color)

        end

      end
    end
  end

  if projectile_hit_by then
    self.last_hit_time = secondcount
    self.last_hit_attacking_ship = projectile_hit_by
  end
end

function Ship:turn_left()
  self:rotate(self.turn_rate * love.timer.getDelta())
end

function Ship:turn_right()
  self:rotate(-self.turn_rate * love.timer.getDelta())
end

function Ship:rotate(signed_degrees)
  self.angle = (self.angle + signed_degrees) % 360
  self.angle_radians = self.angle / 360
  self.heading = (450 - self.angle) % 360
end

function Ship:draw()
  text(self:hp_string(), 0, 0, self:hp_color())
  local o = nil
  local co = self.orders[#self.orders]
  if co == self.full_stop then
    o = "stopping"
  elseif co == self.seek then
    o = "following"
  elseif co == self.fly_towards_destination then
    o = "flying to nearest planet"
  end
  if o then text(o, 1, 22, 12, true) end
  if self.last_fire_time + 5 >= secondcount then text("reloading", 1, 31, 10, true) end
  text("pixels/sec " .. format(10 * self.velocity), 0, 7)
  if self.accelerating then text(format(self.cur_gees) .. " g", 0, 14) end
  -- text((self.angle).." deg", 0,21)
  -- text((self.angle_radians).." rad", 0,28)
  -- text((self.heading).." heading", 0,35)
  -- text((self.velocity_angle).." vel-a", 0,42)
  -- text((self.velocity_angle_opposite).." vel-a-o", 0,49)
  self:draw_sprite_rotated() -- game_screen.screen_center+zoom_offset)

  table.insert(debug_messages, "sector_position: " .. self.sector_position:__tostring())
  -- table.insert(debug_messages, "Zoom offset: "..zoom_offset:__tostring())
  -- table.insert(debug_messages, "turn rate: "..self.turn_rate)

  -- local nplanet,dist=nearest_planet()
  -- table.insert(debug_messages, "Nearest Planet Position: "..nplanet.sector_position:__tostring())
  -- table.insert(debug_messages, "Nearest Planet Screen Position: "..nplanet.screen_position:__tostring())

end

function Ship:hp_color()
  return health_colormap[ceil(10 * self.hp_percent)]
end

function Ship:hp_string()
  return "hp " .. round(100 * self.hp_percent) .. "% " .. self.hp .. "/" .. self.max_hp
end

function Ship:data(y)
  rectfill(0, y + 34, 127, y, 0)
  rect(0, y + 34, 127, y, 6)
  self:draw_sprite_rotated(Vector(104, y + 17), 0)
  text(self.name .. "\nmodel " .. self.seed_value .. "\nmax hull " .. self.max_hp .. "\nmax thrust " ..
           format(self.deltav * 30.593514175) .. " g\nturn rate  " .. self.turn_rate .. " deg/sec", 3, y + 3)
end

function Ship:is_visible(player_ship_pos)
  local size = round(self.sprite_rows / 2)
  local screen_position = (self.sector_position - player_ship_pos + game_screen.screen_center):round()
  self.screen_position = screen_position
  return screen_position.x + zoom_offset.x < game_screen.pixel_width + size and screen_position.x + zoom_offset.x > 0 -
             size and screen_position.y + zoom_offset.y < game_screen.pixel_height + size and screen_position.y +
             zoom_offset.y > 0 - size
end

function Ship:update_location()
  if self.velocity > 0 then self.sector_position:add(self.velocity_vector) end
end

function Ship:reset_velocity()
  self.velocity_vector = Vector()
  self.velocity = 0
end

function Ship:predict_sector_position()
  if self.velocity > 0 then
    return self.sector_position + self.velocity_vector * 4
  else
    return self.sector_position
  end
end

function Ship:set_destination(dest)
  self.destination = dest.sector_position
  self:update_steering_velocity()
  self.max_distance_to_destination = self.distance_to_destination
end

function Ship:flee()
  self:set_destination(self.last_hit_attacking_ship)
  self:update_steering_velocity(1)
  local away_from_enemy = self.steer_vel:angle()
  local toward_enemy = (away_from_enemy + .5) % 1
  if self.distance_to_destination < 55 then
    self:rotate_towards_heading(away_from_enemy)
    self:apply_thrust()
  else
    self:full_stop()
    if self.hostile and self.angle_radians < toward_enemy + .1 and self.angle_radians > toward_enemy - .1 then
      self:fire_weapon()
    end
  end
end

function Ship:update_steering_velocity(modifier)
  local desired_velocity = self.sector_position - self.destination
  self.distance_to_destination = desired_velocity:length()
  self.steer_vel = (desired_velocity - self.velocity_vector) * (modifier or -1)
end

function Ship:seek()
  if self.seektime % 20 == 0 then self:set_destination(self.target) end
  self.seektime = self.seektime + 1

  local target_offset = self.destination - self.sector_position
  local distance = target_offset:length()
  self.distance_to_destination = distance
  local maxspeed = distance / 50
  local ramped_speed = (distance / (self.max_distance_to_destination * .7)) * maxspeed
  local clipped_speed = min(ramped_speed, maxspeed)
  local desired_velocity = target_offset * (ramped_speed / distance)
  self.steer_vel = desired_velocity - self.velocity_vector

  if self:rotate_towards_heading(self.steer_vel:angle()) then self:apply_thrust(self.steer_vel:length()) end
  if self.hostile then
    if distance < 128 then
      self:fire_weapon()
      self:fire_missile()
    end
  end
end

function Ship:fly_towards_destination()
  self:update_steering_velocity()
  if self.distance_to_destination > self.max_distance_to_destination * .9 then
    if self:rotate_towards_heading(self.steer_vel:angle()) then self:apply_thrust() end
  else
    self.accelerating = false
    self:reverse_direction()
    if self.distance_to_destination <= self.max_distance_to_destination * .11 then self:order_done(self.full_stop) end
  end
end

function Ship:approach_object(obj)
  local obj = obj or sect.planets[random_int(#sect.planets) + 1]
  self:set_destination(obj)
  self:reset_orders(self.fly_towards_destination)
  if self.velocity > 0 then add(self.orders, self.full_stop) end
end

function Ship:follow_cur_order()
  local order = self.orders[#self.orders]
  if order then order(self) end
end

function Ship:order_done(new_order)
  self.orders[#self.orders] = new_order
end

function Ship:reset_orders(new_order)
  self.orders = {}
  if new_order then add(self.orders, new_order) end
end

function Ship:cut_thrust()
  self.accelerating = false
  self.cur_deltav = 0
end

function Ship:wait()
  if secondcount > self.wait_duration + self.wait_time then self:order_done() end
end

function Ship:full_stop()
  if self.velocity > 0 and self:reverse_direction() then
    self:apply_thrust()
    if self.velocity < 1.2 * self.deltav then
      self:reset_velocity()
      self:order_done()
    end
  end
end

function Ship:fire_missile(weapon)
  if self.target and secondcount > 5 + self.last_fire_time then
    self.last_fire_time = secondcount
    add(projectiles, Missile(self, self.target))
    -- self:pilotsfx(54)
  end
end

-- function Ship:pilotsfx(n,c)
--   if self==pilot then sfx(n,c or 1) end
-- end

function Ship:fire_weapon()
  local hardpoints = {1, -1}
  if self.ship_type_index ~= 2 then hardpoints = {0} end
  local rate = 3
  if self.npc then rate = 5 end
  if framecount % rate == 0 then
    for index, y in ipairs(hardpoints) do
      add(projectiles,
          Cannon(rotated_vector(self.angle_radians, self.sprite_rows / 2 - 1, y * (self.sprite_columns / 4)) +
                 self.screen_position, rotated_vector(self.angle_radians, 6) + self.velocity_vector, 12, self))
    end
    -- self:pilotsfx(36)
  end
end

function Ship:apply_thrust(max_velocity)
  self.accelerating = true
  if self.cur_deltav < self.deltav then
    self.cur_deltav = self.cur_deltav + (self.deltav * love.timer.getDelta())
  else
    self.cur_deltav = self.deltav
  end
  local dv = self.cur_deltav
  -- self:pilotsfx(38+floor(12*dv/self.deltav),2)
  if max_velocity and dv > max_velocity then dv = max_velocity end
  if self.hp_percent <= random(.1) then dv = 0 end
  self.cur_gees = dv * 30.593514175
  local a = self.angle_radians
  local additional_velocity_vector = Vector(cos(a) * dv, sin(a) * dv)
  local velocity_vector = self.velocity_vector
  local velocity
  local engine_location = rotated_vector(a, self.sprite_rows * -.5) + self.screen_position
  add(particles, ThrustExhaust(engine_location, additional_velocity_vector * -1.3 * self.sprite_rows))
  velocity_vector:add(additional_velocity_vector)
  velocity = velocity_vector:length()
  self.velocity_angle = velocity_vector:angle()
  self.velocity_angle_opposite = (self.velocity_angle + 0.5) % 1
  self.velocity = velocity
  self.velocity_vector = velocity_vector
end

function Ship:dampen_speed()
  if self.velocity < 1.2 * self.deltav then
    self:reset_velocity()
  else
    local cvn = self.velocity_vector:clone()
    cvn:normalize()
    self.velocity_vector:add(cvn * -0.01)
    self.velocity = self.velocity_vector:length()
  end
end

function Ship:reverse_direction()
  if self.velocity > 0 then return self:rotate_towards_heading(self.velocity_angle_opposite) end
end

function Ship:rotate_towards_heading(heading)
  local delta = (heading * 360 - self.angle + 180) % 360 - 180
  if delta ~= 0 then
    local r = (self.turn_rate * love.timer.getDelta()) * delta / abs(delta)
    if abs(delta) > abs(r) then delta = r end
    self:rotate(delta)
  end
  return delta < 0.1 and delta > -.1
end

function nearest_planet()
  local planet
  local dist = 32767
  for index, p in ipairs(sect.planets) do
    if p.planet_type then
      local d = vector_distance(pilot.sector_position, p.sector_position)
      if d < dist then
        dist = d
        planet = p
      end
    end
  end
  return planet, dist
end

function land_at_nearest_planet()
  local planet, dist = nearest_planet()
  if dist < planet.radius * 1.4 then
    if pilot.velocity < .5 then
      -- sect:reset_planet_visibility()
      landed_front_rendered = false
      landed_back_rendered = false
      landed_planet = planet
      landed = true
      landed_menu()
      -- draw_rect(128,128,0)
    else
      note_add("moving too fast to land")
    end
  else
    note_add("too far to land")
  end
  return false
end

function takeoff()
  sect:reset_planet_visibility()
  pilot:set_position_near_object(landed_planet)
  landed = false
  return false
end

function clear_targeted_ship_flags()
  for index, ship in ipairs(npcships) do ship.targeted = false end
end

function next_hostile_target(ship)
  local targeting_ship = ship or pilot
  local hostile
  for i = 1, #npcships do
    next_ship_target(ship)
    if targeting_ship.target.hostile then break end
  end
  return true
end

function next_ship_target(ship, random)
  local targeting_ship = ship or pilot
  if random then
    targeting_ship.target_index = random_int(#npcships) + 1
  else
    targeting_ship.target_index = (targeting_ship.target_index or #npcships) % #npcships + 1
  end
  targeting_ship.target = npcships[targeting_ship.target_index]
  if targeting_ship == targeting_ship.target then targeting_ship.target = pilot end
  if not ship then
    clear_targeted_ship_flags()
    targeting_ship.target.targeted = true
  end
  return true
end

Missile = Ship:extend()
function Missile:new(fship, t)
  self.sector_position = fship.sector_position:clone()
  self.screen_position = fship.screen_position:clone()
  self.velocity_vector = fship.velocity_vector:clone()
  self.velocity = fship.velocity
  self.target = t
  self.sprite_rows = 1
  self.firing_ship = fship
  self.cur_deltav = .1
  self.deltav = .1
  self.hp_percent = 1
  self.duration = 512
  self.damage = 20
end

function Missile:update()
  self.destination = self.target:predict_sector_position()
  self:update_steering_velocity()
  self.angle_radians = self.steer_vel:angle()
  self:apply_thrust(self.steer_vel:length())
  self.duration = self.duration - 1
  self:update_location()
end

function Missile:draw(shipvel, offscreen_pos)
  local screen_position = (offscreen_pos or self.screen_position) + zoom_offset
  self.last_offscreen_pos = offscreen_pos
  if self:is_visible(pilot.sector_position) or offscreen_pos then
    screen_position:draw_line(screen_position + rotated_vector(self.angle_radians, 4), 6)
  end
end

Star = Object:extend()
function Star:new()
  self.position = Vector()
  self.color = 7
  self.speed = 1
end

function Star:reset(x, y)
  self.position = Vector(x or random_int(game_screen.pixel_width), y or random_int(game_screen.pixel_height))
  self.color = random_int(#star_colors[star_color_monochrome + star_color_index + 1]) + 1
  self.speed = (random(.75) + 0.25)
  return self
end

Sun = Object:extend()
function Sun:new(radius, x, y)
  local r = radius or 64 + random_int(128)
  local c = random_int(6, 1)
  self.screen_position = Vector()
  self.radius = r
  self.sun_color_index = c
  self.color = sun_colors[c + 5]
  self.sector_position = Vector(x or 0, y or 0)
end

function Sun:draw(ship_pos)
  local screen_position = self.screen_position + zoom_offset
  if stellar_object_is_visible(self, ship_pos) then
    for i = 0, 1 do screen_position:draw_circle(self.radius - i * 3, sun_colors[i * 5 + self.sun_color_index], true) end
  end
end

function stellar_object_is_visible(obj, ship_pos)
  obj.screen_position = obj.sector_position - ship_pos + game_screen.screen_center
  return obj.screen_position.x + zoom_offset.x < game_screen.pixel_width + obj.radius and obj.screen_position.x +
             zoom_offset.x > 0 - obj.radius and obj.screen_position.y + zoom_offset.y < game_screen.pixel_height +
             obj.radius and obj.screen_position.y + zoom_offset.y > 0 - obj.radius
end

-- starfield_count=40
Sector = Object:extend()
function Sector:new()
  self.seed = random_int(32767)
  randomseed(self.seed)
  self.planets = {}
  self.starfield = {}
  for i = 1, starfield_count do
    add(self.starfield, Star():reset())
  end
end

function Sector:reset_planet_visibility()
  for index, p in ipairs(self.planets) do
    p.rendered_circle = false
    p.rendered_terrain = false
  end
end

function Sector:new_planet_along_elipse()
  local x, y, sdist
  local planet_nearby = true
  while (planet_nearby) do
    x = random(150)
    y = sqrt((random(35) + 40) ^ 2 * (1 - x ^ 2 / (random(50) + 100) ^ 2))
    if random() < .5 then x = x * -1 end
    if random() < .75 then y = y * -1 end
    if #self.planets == 0 then break end
    sdist = 32767
    for index, p in ipairs(self.planets) do sdist = min(sdist, vector_distance(Vector(x, y), p.sector_position / 33)) end
    planet_nearby = sdist < 15
  end
  return Planet(x * 33, y * 33, ((1 - Vector(x, y):angle()) - .25) % 1)
end

function Sector:add_to_starfield_at_screen_edge(amount)
  for i = 0, amount do
    local side = round(random(3)) -- 0 1 2 3
    if side == 0 then
      -- left
      add(sect.starfield, Star():reset(0, false))
    elseif side == 1 then
      -- right
      add(sect.starfield, Star():reset(game_screen.pixel_width, false))
    elseif side == 2 then
      -- top
      add(sect.starfield, Star():reset(false, 0))
    elseif side == 3 then
      -- bottom
      add(sect.starfield, Star():reset(false, game_screen.pixel_height))
    end
  end
end

function Sector:draw_starfield(shipvel)
  local lstart, lend
  for index, star in ipairs(self.starfield) do
    local position = star.position + zoom_offset
    lstart = star.position + (shipvel * star.speed * -.5)
    lend = star.position + (shipvel * star.speed * .5)
    local i = star_color_monochrome + star_color_index + 1
    local star_color_count = #star_colors[i]
    local color_index = 1 + ((star.color - 1) % star_color_count)
    -- debug.debug()
    -- print(lstart.x..","..lstart.y.." - "..star.position.x..","..star.position.y.." - "..lend.x..","..lend.y.."\n")
    star.position:draw_line(lend, star_colors[i + 1][color_index])
    lstart:draw_line(star.position, star_colors[i][color_index])
  end
end

function Sector:scroll_starfield(shipvel)
  -- did starcount change?
  local stars_to_add = starfield_count - #self.starfield
  -- add new stars if stars_to_add >= 1
  if stars_to_add > 0 then
    -- don't add more than 600 for performance sake
    if stars_to_add + starfield_count < 600 then sect:add_to_starfield_at_screen_edge(stars_to_add) end
    -- add stars at random locations
    -- for i = 1, stars_to_add do
    --   add(self.starfield, Star():reset())
    -- end
  elseif stars_to_add < 0 then
    -- remove random stars if we have to many
    for i = 1, (stars_to_add * -1) do
      local index_to_delete = random(1, #self.starfield)
      table.remove(self.starfield, index_to_delete)
    end
  end

  -- move stars outside the screen margin to the opposite side of the screen
  if shipvel.x ~= 0 or shipvel.y ~= 0 then
    local margin = 12
    local width, height = game_screen.pixel_width, game_screen.pixel_height
    for index, star in ipairs(self.starfield) do
      -- move stars according to the ship velocity
      star.position:add(shipvel * star.speed * -1)
      if star.position.x > width + margin then
        star:reset(-margin)
      elseif star.position.x < -margin then
        star:reset(width + margin)
      elseif star.position.y > height + margin then
        star:reset(false, -margin)
      elseif star.position.y < -margin then
        star:reset(false, height + margin)
      end
    end
  end
end

function is_offscreen(p, m)
  local margin = m or 0
  local mincoord = 0 - margin
  local max_x_coord = game_screen.pixel_width + margin
  local max_y_coord = game_screen.pixel_height + margin
  local x, y = p.screen_position.x, p.screen_position.y
  local duration_up = p.duration < 0
  if p.deltav then
    return duration_up
  else
    return duration_up or x > max_x_coord or x < mincoord or y > max_y_coord or y < mincoord
  end
end

Spark = Object:extend()
function Spark:new(p, pv, c, d)
  self.screen_position = p
  self.particle_velocity = pv
  self.color = c
  self.duration = d or random_int(7, 2)
end

function Spark:update(shipvel)
  self.screen_position:add(self.particle_velocity - shipvel)
  self.duration = self.duration - 1
end

function Spark:draw(shipvel)
  self.screen_position:draw_point(self.color)
  self:update(shipvel)
end

function make_explosion(pixel1, size, colorcount, center_velocity)
  add(particles, Explosion(pixel1, size, colorcount, center_velocity))
end

Explosion = Spark:extend()
function Explosion:new(position, size, colorcount, shipvel)
  local explosion_size_factor = random()
  self.screen_position = position:clone()
  self.particle_velocity = shipvel:clone()
  self.radius = explosion_size_factor * size
  self.radius_delta = explosion_size_factor * random(.5)
  self.len = colorcount - 3
  self.duration = colorcount
end

function Explosion:draw(shipvel)
  local screen_position = self.screen_position + zoom_offset
  local r = round(self.radius)
  for i = r + 3, r, -1 do
    local c = damage_colors[self.len - self.duration + i]
    if c then screen_position:draw_circle(i, c, true) end
  end
  self:update(shipvel)
  self.radius = self.radius - self.radius_delta
end

Cannon = Object:extend()
function Cannon:new(p, pv, c, ship)
  self.screen_position = p
  self.position2 = p:clone()
  self.particle_velocity = pv + pv:perpendicular():normalize() * (random(2) - 1)
  self.color = c
  self.firing_ship = ship
  self.duration = 16
end

function Cannon:update(shipvel)
  self.position2 = self.screen_position:clone()
  self.screen_position:add(self.particle_velocity - shipvel)
  self.duration = self.duration - 1
end
function Cannon:draw(shipvel)
  local p2 = self.position2 + zoom_offset
  local screen_position = self.screen_position + zoom_offset
  p2:draw_line(screen_position, self.color)
end

ThrustExhaust = Object:extend()
function ThrustExhaust:new(p, pv)
  self.screen_position = p
  self.particle_velocity = pv
  self.duration = 0
end

function ThrustExhaust:draw(shipvel)
  local c, pv = random_int(11, 9), self.particle_velocity
  local deflection, flicker = pv:perpendicular() * 0.7, pv * (random(2) + 2)
  flicker = flicker + deflection * (random() - .5)
  local screen_position = self.screen_position + zoom_offset
  local p0, p1a = screen_position + flicker, screen_position + pv
  for index, a in ipairs {p1a + deflection, p1a + deflection * -1} do
    for index, b in ipairs {p0, screen_position} do a:draw_line(b, c) end
  end
  if random() > .4 then add(particles, Spark(p0, shipvel + (flicker * .25), c)) end
  self.screen_position:add(pv - shipvel)
  self.duration = self.duration - 1
end

function draw_rect(w, h, c)
  rectfill(0, 0, w, h, c)
end

function draw_sprite_circle(xc, yc, radius, filled, c)
  local xvalues = {}
  local fx, fy = 0, 0
  local x, y = -radius, 0
  local err = 2 - 2 * radius
  color(c)
  while (x < 0) do
    xvalues[1 + x * -1] = y

    if not filled then fx, fy = x, y end
    for i = x, fx do
      sset(xc - i, yc + y)
      sset(xc + i, yc - y)
    end
    for i = fy, y do
      sset(xc - i, yc - x)
      sset(xc + i, yc + x)
    end

    radius = err
    if radius <= y then
      y = y + 1
      err = err + y * 2 + 1
    end
    if radius > x or err > y then
      x = x + 1
      err = err + x * 2 + 1
    end
  end
  xvalues[1] = xvalues[2]
  return xvalues
end

perms = {}
for i = 0, 255 do perms[i] = i end
for i = 0, 255 do
  local r = random_int(32767) % 256
  perms[i], perms[r] = perms[r], perms[i]
end

perms12 = {}
for i = 0, 255 do
  local x = perms[i] % 12
  perms[i + 256], perms12[i], perms12[i + 256] = perms[i], x, x
end

function getn_3d(ix, iy, iz, x, y, z)
  local t = .6 - x * x - y * y - z * z
  local index = perms12[ix + perms[iy + perms[iz]]]
  return max(0, (t * t) * (t * t)) * (grads3[index][0] * x + grads3[index][1] * y + grads3[index][2] * z)
end

function simplex3d(x, y, z)
  local s = (x + y + z) * 0.333333333
  local ix, iy, iz = floor(x + s), floor(y + s), floor(z + s)
  local t = (ix + iy + iz) * 0.166666667
  local x0, y0, z0 = x + t - ix, y + t - iy, z + t - iz
  ix, iy, iz = band(ix, 255), band(iy, 255), band(iz, 255)
  local n0 = getn_3d(ix, iy, iz, x0, y0, z0)
  local n3 = getn_3d(ix + 1, iy + 1, iz + 1, x0 - 0.5, y0 - 0.5, z0 - 0.5)
  local ijk
  if x0 >= y0 then
    if y0 >= z0 then
      ijk = ijks[1]
    elseif x0 >= z0 then
      ijk = ijks[2]
    else
      ijk = ijks[3]
    end
  else
    if y0 < z0 then
      ijk = ijks[4]
    elseif x0 < z0 then
      ijk = ijks[5]
    else
      ijk = ijks[6]
    end
  end
  local n1 = getn_3d(ix + ijk[1], iy + ijk[2], iz + ijk[3], x0 + 0.166666667 - ijk[1], y0 + 0.166666667 - ijk[2],
                     z0 + 0.166666667 - ijk[3])
  local n2 = getn_3d(ix + ijk[4], iy + ijk[5], iz + ijk[6], x0 + 0.333333333 - ijk[4], y0 + 0.333333333 - ijk[5],
                     z0 + 0.333333333 - ijk[6])
  return 32 * (n0 + n1 + n2 + n3)
end

-- Make a new planet type
function new_planet(a)
  local p = nsplit(a)
  local args = p[2]
  return {
    class_name = p[1][1],
    noise_octaves = args[1],
    noise_zoom = args[2],
    noise_persistance = args[3],
    mmap_color = args[4],
    full_shadow = args[5] or 1,
    transparent_color = args[6] or 14,
    minc = args[7] or 1,
    maxc = args[8] or 1,
    min_size = args[9] or 16,
    color_map = p[3]
  }
end

Planet = Object:extend()
function Planet:new(x, y, phase, r)
  local planet_type = planet_types[random_int(#planet_types) + 1]

  local radius = r or random_int(130, planet_type.min_size)
  local planet_canvas = love.graphics.newCanvas(radius * 2 + 1, radius * 2 + 1)
  planet_canvas:setFilter("nearest", "nearest")

  self.planet_canvas = planet_canvas
  self.screen_position = Vector()
  self.radius = radius
  self.sector_position = Vector(x, y)
  self.bottom_right_coord = 2 * radius - 1
  self.phase = phase
  self.planet_type = planet_type
  self.noise_factor_vert = random_int(planet_type.maxc + 1, planet_type.minc)
  self.noisedx = random(1024)
  self.noisedy = random(1024)
  self.noisedz = random(1024)
  self.rendered_circle = false
  self.rendered_terrain = false
  self.color = planet_type.mmap_color
end

function Planet:draw(ship_pos)
  if stellar_object_is_visible(self, ship_pos) then
    -- self.screen_position:draw_circle(
    --   self.radius,
    --   self.color,true)

    self:render_planet()

    -- sspr(
    --   0,0,self.bottom_right_coord,self.bottom_right_coord,
    --   self.screen_position.x-self.radius,
    --   self.screen_position.y-self.radius)

    love.graphics.draw(self.planet_canvas, self.screen_position.x - self.radius + zoom_offset.x,
                       self.screen_position.y - self.radius + zoom_offset.y -- deg270,
    -- game_screen.screen_height/game_screen.pixel_height, -- scale x
    -- game_screen.screen_height/game_screen.pixel_height -- scale y
    -- 0, -- Origin offset (x-axis).
    -- 0, -- Origin offset (y-axis).
    -- 0, -- Shearing factor (x-axis).
    -- 0 -- Shearing factor (y-axis).
    )

  end
end

function Planet:render_planet(fullmap, render_far_side)
  local radius = self.radius - 1
  if fullmap then radius = 47 end

  love.graphics.setCanvas(self.planet_canvas)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  if not self.rendered_circle then
    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x = 0
    self.yfromzero = 0
    self.y = radius - self.yfromzero
    self.phi = 0
    -- sect:reset_planet_visibility()
    -- pal()
    -- palt(0,false)
    -- palt(self.planet_type.transparent_color,true)
    love.graphics.clear(0, 0, 0, 0)
    -- color(pink)
    -- sset(0,0)
    -- sset(1,1)
    -- sset(2,2)
    xvaluestring = ""
    if fullmap then
      self.width, self.height = 114, 96
    else
      self.xvalues = draw_sprite_circle(radius, radius, radius, true, 0)
      draw_sprite_circle(radius, radius, radius, false, self.planet_type.mmap_color)
    end
    self.rendered_circle = true
  end

  -- local m = ""
  -- for i, x in ipairs(self.xvalues) do
  --   m = m..x..", "
  -- end

  -- table.insert(debug_messages, self.xvalues[1])
  -- table.insert(debug_messages, self.xvalues[#self.xvalues])
  -- local absy=abs(radius-self.y)+1
  -- xvaluestring = xvaluestring..absy.." "
  -- xvaluestring = xvaluestring..self.y.." -> "
  -- if self.xvalues[absy] then
  --   xvaluestring = xvaluestring.." "..self.xvalues[absy].." "
  -- else
  --   xvaluestring = xvaluestring.." nil "
  -- end
  -- if self.xvalues[self.y] then
  --   xvaluestring = xvaluestring.." "..self.xvalues[self.y].."\n"
  -- else
  --   xvaluestring = xvaluestring.." nil\n"
  -- end
  -- table.insert(debug_messages, xvaluestring)

  if (not self.rendered_terrain) and self.rendered_circle then

    local theta_start, theta_end = 0, .5
    local theta_increment = theta_end / self.width
    if fullmap and render_far_side then
      theta_start = .5
      theta_end = 1
    end

    if self.phi > .25 then
      self.rendered_terrain = true
    else

      local partialshadow = self.planet_type.full_shadow ~= 1
      local phase_values, phase = {}, self.phase

      local x, doublex, x1, x2, i, c1, c2
      local y = radius - self.y
      local xvalueindex = abs(y) + 1
      if xvalueindex <= #self.xvalues then
        x = floor(sqrt(radius * radius - y * y))
        doublex = 2 * x
        if phase < .5 then
          x1 = -self.xvalues[xvalueindex]
          x2 = floor(doublex - 2 * phase * doublex - x)
        else
          x1 = floor(x - 2 * phase * doublex + doublex)
          x2 = self.xvalues[xvalueindex]
        end
        for i = x1, x2 do
          if partialshadow or (phase < .5 and i > x2 - 2) or (phase >= .5 and i < x1 + 2) then
            phase_values[radius + i] = 1
          else
            phase_values[radius + i] = 0
          end
        end
      end

      for theta = theta_start, theta_end - theta_increment, theta_increment do

        local phasevalue = phase_values[self.x]
        local c = nil

        -- if fullmap or phasevalue==1 then
        if fullmap or
            (phasevalue ~= 0 and xvalueindex <= #self.xvalues and self.x >= self.radius - self.xvalues[xvalueindex] and
                self.x < self.radius + self.xvalues[xvalueindex]) then
          -- and sget(self.x,self.y)~=self.planet_type.transparent_color then
          local freq = self.planet_type.noise_zoom
          local max_amp = 0
          local amp = 1
          local value = 0
          for n = 1, self.planet_type.noise_octaves do
            -- value=value+love.math.noise(
            value = value +
                        simplex3d(self.noisedx + freq * cos(self.phi) * cos(theta),
                                  self.noisedy + freq * cos(self.phi) * sin(theta),
                                  self.noisedz + freq * sin(self.phi) * self.noise_factor_vert)
            max_amp = max_amp + amp
            amp = amp * self.planet_type.noise_persistance
            freq = freq * 2
          end
          value = value / max_amp
          if value > 1 then value = 1 end
          if value < -1 then value = -1 end
          value = value + 1
          value = value * (#self.planet_type.color_map - 1) / 2
          value = round(value)

          c = self.planet_type.color_map[value + 1]
          if not fullmap and phasevalue == 1 then c = dark_planet_colors[c + 1] end
        end

        if xvalueindex <= #self.xvalues and
            (self.x == self.radius - self.xvalues[xvalueindex] - 1 or self.x == self.radius + self.xvalues[xvalueindex] -
                1) then c = black end
        if c ~= nil then
          color(c)
          sset(self.x, self.y)
        end
        self.x = self.x + 1
      end
      self.x = 0
      if self.phi >= 0 then
        self.yfromzero = self.yfromzero + 1
        self.y = radius + self.yfromzero
        self.phi = self.phi + .5 / (self.height - 1)
      else
        self.y = radius - self.yfromzero
      end
      self.phi = self.phi * -1
    end

  end

  love.graphics.setCanvas(game_screen_canvas)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  return self.rendered_terrain
end

function add_npc(pos, pirate)
  local t = random_int(#ship_types) + 1

  if pirate or random() < .2 then
    t = random_int(3, 1)
    pirate = true
    pirates = pirates + 1
  end

  local npc = Ship(pirate):buildship(nil, t)
  npc:set_position_near_object(pos)
  npc:rotate(random_int(360))
  npc.npc = true
  add(npcships, npc)
  npc.index = #npcships
end

function load_sector()
  warpsize = pilot.sprite_rows
  sect = Sector()
  note_add("arriving in system ngc " .. sect.seed)
  add(sect.planets, Sun())
  for i = 1, round(random(3, 24)) do
    local p = sect:new_planet_along_elipse()
    -- TODO new_planet_along_elipse returns nans
    if not (p.sector_position.y ~= p.sector_position.y) and (not p.sector_position.x ~= p.sector_position.x) then
      add(sect.planets, p)
    end
  end
  pilot:set_position_near_object(lume.randomchoice(sect.planets))
  pilot:clear_target()
  pirates = 0
  npcships = {}
  shipyard = {}
  projectiles = {}

  for index, p in ipairs(sect.planets) do for i = 1, random_int(4) do add_npc(p) end end

  if pirates == 0 then add_npc(sect.planets[2], true) end

  -- for i=1,5 do
  --   add_npc(pilot,false)
  -- end

  return true
end

function _init()
  -- these nsplits need split_start = 0
  grads3 =
      nsplit "n1,1,0,|n-1,1,0,|n1,-1,0,|n-1,-1,0,|n1,0,1,|n-1,0,1,|n1,0,-1,|n-1,0,-1,|n0,1,1,|n0,-1,1,|n0,1,-1,|n0,-1,-1,|"
  mmap_sizes = split "n24,48,128,0,"
  mmap_sizes = {floor(game_screen.pixel_width * .375), game_screen.pixel_width, 0}
  mmap_sizes[0] = floor(game_screen.pixel_width * .1875)
  music_tracks = split "n13,0,-1,"
  mousemodes = split "agamepad,two button mouse,stylus (pocketchip),"
  framecount, secondcount, mousemode, mmap_size_index, music_track = 0, 0, 2, 0, 0
  mbtn = 0
  -- these nsplits need split_start = 1
  split_start = 1
  btnv = split "x2031"
  ijks = nsplit "n1,0,0,1,1,0,|n1,0,0,1,0,1,|n0,0,1,1,0,1,|n0,0,1,0,1,1,|n0,1,0,0,1,1,|n0,1,0,1,1,0,|"
  outlinedindex = split "n2,2,1,2,0,2,2,0,2,1,1,1,-1,-1,1,-1,-1,1,-1,0,1,0,0,-1,0,1,"
  star_color_index = 0
  star_color_monochrome = 0
  star_colors = nsplit "xaecd76|x98d165|x421051|x767676|x656565|x515151|"
  -- star_colors={{0xa,0xe,0xc,0xd,0x7,0x6},{0x9,0x8,0xd,0x1,0x6,0x5},{0x4,0x2,0x1,0x0,0x5,0x1},{0x7,0x6,0x7,0x6,0x7,0x6},{0x6,0x5,0x6,0x5,0x6,0x5},{0x5,0x1,0x5,0x1,0x5,0x1}}
  darkshipcolors = split "x01221562493d189"
  dark_planet_colors = split "x0011055545531121"
  health_colormap = split "x8899aaabbb"
  damage_colors = split "x7a98507a98507a9850"
  sun_colors = split "x6ea9d789ac"
  ship_names = split "afighter,cruiser,freighter,superfreighter,station,"
  ship_types =
      nsplit "n1.5,.25,.7,.75,.8,-2,1,14,18,|n3.5,.5,.583333,0,.8125,-1,1,18,24,|n3,2,.2125,0,.8125,-3,1,16,22,|n6,0,.7,-.25,.85,.25,1,32,45,|n4,1,.1667,-1,.3334,0,.6668,1,.8335,-1,1,30,40,|"
  planet_types = {
    new_planet("atundra,|n5,.5,.6,6,|x76545676543|"),
    new_planet("adesert,|n5,.35,.3,9,|x449944994499b1949949949949949|"),
    new_planet("abarren,|n5,.55,.35,5,|x565056765056|"), new_planet("alava,|n5,.55,.65,4,|x040504049840405040|"),
    new_planet("agas giant,|n1,.4,.75,2,1,14,4,20,50,|x76d121c|"),
    new_planet("agas giant,|n1,.4,.75,8,1,12,4,20,50,|x7fe21288|"),
    new_planet("agas giant,|n1,.7,.75,10,1,14,4,20,50,|xfa949a|"),
    new_planet("aterran,|n5,.3,.65,11,0,|x1111111dcfbb3334567|"),
    new_planet("aisland,|n5,.55,.65,12,0,|x11111111dcfb3|"),
    new_planet("arainbow giant,|n1,.7,.75,15,1,4,4,20,50,|x1dcba9e82|")
  }

  -- poke(0x5f2d,1)
  note_text = nil
  note_display_time = 4
  paused = false
  landed = false
  particles = {}
  pilot = Ship()
  -- pilot.npc = true
  pilot:buildship(nil, 2)
  load_sector()
  setup_mmap()
  -- music(13)
  -- local titlestarv=Vector(0,-3)
  titlestarv = Vector(3, -7)

  -- while(not btnp(4)) do
  --   cls()
  --   sect:scroll_starfield(titlestarv)
  --   sect:draw_starfield(titlestarv)
  --   circfill(64,135,90,2)
  --   circfill(64,172,122,0)
  --   map(0,0,6,-15)
  --   map(16,0,0,70)
  --   flip()
  -- end
end

function setup_mmap()
  mmap_size = mmap_sizes[mmap_size_index]
  if mmap_size and mmap_size > 0 then
    mmap_size_halved = mmap_size / 2
    mmap_offset = Vector(game_screen.pixel_width - 2 - mmap_size_halved, mmap_size_halved + 1)
  end
end

function draw_mmap_ship(obj)
  if obj.deltav then
    local p = (obj.sector_position / mmap_denominator):add(mmap_offset):round()
    local x, y = p.x, p.y
    local c = obj:targeted_color()
    if obj.npc then
      p:draw_point(c)
      if obj.targeted then p:draw_circle(2, c) end
    else
      if obj.damage then
        p:draw_circle(1, 9)
      else
        rect(x - 1, y - 1, x, y, 7)
      end
    end
  end
end

function draw_mmap()
  local text_height = mmap_size
  if mmap_size > 0 then
    if mmap_size < 100 then
      text_height = text_height + 4
      rectfill(game_screen.pixel_width - 3 - mmap_size, 0, game_screen.pixel_width - 1, mmap_size + 2, 1)
    else
      text_height = 0
    end

    local x, y = abs(pilot.sector_position.x), abs(pilot.sector_position.y)
    if y > x then x = y end
    mmap_denominator = min(6, ceil(x / 5000)) * 5000 / mmap_size_halved
    for index, obj in ipairs(sect.planets) do
      local p = obj.sector_position:clone() -- +game_screen.screen_center
      if obj.planet_type then p:add(Vector(-obj.radius, -obj.radius)) end
      p = p / mmap_denominator + mmap_offset
      if mmap_size > 100 then
        p:draw_circle(ceil(obj.radius / 32) + 1, obj.color)
      else
        p:draw_point(obj.color)
      end
    end

    if framecount % 3 ~= 0 then
      for index, p in ipairs(projectiles) do draw_mmap_ship(p) end

      for index, s in ipairs(npcships) do draw_mmap_ship(s) end

      draw_mmap_ship(pilot)
    end

  end
  text("s " .. #npcships - pirates, game_screen.pixel_width - 16, text_height)
  text("s " .. pirates, game_screen.pixel_width - 16, text_height + 7, 8)
end

function text(text, x, y, textcolor, outline)
  local c = textcolor or 6
  local s = darkshipcolors[c]
  if outline then
    for i = 1, #outlinedindex, 2 do
      if i > 10 then s = c end
      color(s)
      love.graphics.print(text, x + outlinedindex[i], y + outlinedindex[i + 1] + 1)
    end
    c = 0
  else
    color(s)
    love.graphics.print(text, x + 1, y + 1 + 1)
  end
  color(c)
  love.graphics.print(text, x, y + 1)
end

function note_add(text)
  note_text = text
  note_display_time = 4
end

function note_draw()
  if note_display_time > 0 then
    text(note_text, 0, game_screen.pixel_height - 7)
    if framecount >= 29 then note_display_time = note_display_time - 1 end
  end
end

function myship_menu()
  showyard = false
  shipinfo = true
  menu("x6b66|aback,repair,|", {
    landed_menu, function()
      pilot:buildship(pilot.seed_value, pilot.ship_type_index)
      note_add("hull damage repaired")
    end
  })
end

function addyardships()
  shipyard = {}
  for i = 1, 2 do add(shipyard, Ship():buildship(nil, random_int(#ship_types, 1))) end
end

function buyship(i)
  pilot:buildship(shipyard[i].seed_value, shipyard[i].ship_type_index)
  shipyard[i] = nil
  note_add("purchased!")
  myship_menu()
end

function call_option(i)
  if cur_option_callbacks[i] then
    local return_value = cur_option_callbacks[i]()
    paused = false
    if return_value == nil then
      paused = true
    elseif return_value then
      if type(return_value) == "string" then note_add(return_value) end
      paused = true
    end
  end
  if paused then
    -- sfx(53,2)
  else
    -- sfx(52,2)
  end
end

function menu(coptions, callbacks)
  if coptions then
    local c = nsplit(coptions)
    cur_menu_colors = c[1]
    cur_options = c[2]
    cur_option_callbacks = callbacks
  end

  if shipinfo then
    pilot:data(0)
  elseif showyard then
    for i = 0, 1 do
      local s = shipyard[i + 1]
      if s then s:data(i * 36) end
    end
  end

  for a = .25, 1, .25 do
    local i = a * 4
    local text_color = cur_menu_colors[i]
    if i == pressed then text_color = darkshipcolors[text_color] end
    if cur_options[i] then
      local p = rotated_vector(a, 15) +
                    Vector(floor(game_screen.pixel_width / 2), floor(game_screen.pixel_height / 2) + 26)
      if a == .5 then
        p.x = p.x - 4 * #cur_options[i]
      elseif a ~= 1 then
        p.x = p.x - round(4 * (#cur_options[i] / 2))
      end
      text(cur_options[i], p.x, p.y, text_color, true)
    end
  end
  text("  |  \n -+- \n  |", floor(game_screen.pixel_width / 2) - 10, floor(game_screen.pixel_height / 2) + 21, 6, true)
end

function main_menu()
  menu("xc8b7|aautopilot,fire missile,options,system,|", {
    function()
      menu("xcc6c|afull stop,near planet,back,follow,|", {
        function()
          if pilot.velocity > 0 then pilot:reset_orders(pilot.full_stop) end
          return false
        end, function()
          local planet, dist = nearest_planet()
          pilot:approach_object(planet)
          return false
        end, main_menu, function()
          if pilot.target then
            pilot:reset_orders(pilot.seek)
            pilot.seektime = 0
          end
          return false
        end
      })
    end, function()
      pilot:fire_missile()
      return false
    end, function()
      menu("x6fba|aback,starfield,minimap size,mouse,|", {
        main_menu, function()
          menu("x7f6a|amore stars,~dimming,less stars,~colors,|", {
            function()
              starfield_count = starfield_count + 5
              return "star count: " .. starfield_count
            end, function()
              star_color_index = star_color_index + 1
              star_color_index = star_color_index % 2
              return true
            end, function()
              starfield_count = max(0, starfield_count - 5)
              return "star count: " .. starfield_count
            end, function()
              star_color_monochrome = star_color_monochrome + 1
              star_color_monochrome = star_color_monochrome % 2
              star_color_monochrome = star_color_monochrome * 3
              return true
            end
          })
        end, function()
          mmap_size_index = mmap_size_index + 1
          mmap_size_index = mmap_size_index % #mmap_sizes
          setup_mmap()
          return true
        end, function()
          menu("xc698|acontrol mode,back,music,|", {
            function()
              mousemode = mousemode + 1
              mousemode = mousemode % 3
              note_add(mousemodes[mousemode])
            end, main_menu, function()
              music_track = music_track + 1
              music_track = music_track % 3
              music(music_tracks[music_track])
            end
          })
        end
      })
    end, function()
      menu("x86cb|atarget next pirate,back,land,target next,|",
           {next_hostile_target, main_menu, land_at_nearest_planet, next_ship_target})
    end
  })
end

function landed_menu()
  shipinfo = false
  showyard = false
  menu("xc67a|atakeoff,nil,my ship,shipyard,|", {
    takeoff, nil, myship_menu, function()
      showyard = true
      if #shipyard == 0 then addyardships() end
      menu("x767a|abuy top,back,buy bottom,more,|", {
        function()
          buyship(1)
        end, landed_menu, function()
          buyship(2)
        end, addyardships
      })
    end
  })
end

-- pos=0
-- mtbl={}
-- for i=1,96 do
--   mtbl[i]={floor(-sqrt(-sin(i/193))*48+64)}
--   mtbl[i][2]=(64-mtbl[i][1])*2
-- end
-- for i=0,95 do
--   poke(64*i+56,peek(64*i+0x1800))
-- end
-- cs={}
-- for i=0,15 do
--   cs[i]={(cos(0.5+0.5/16*i)+1)/2}
--   cs[i][2]=(cos(0.5+0.5/16*(i+1))+1)/2-cs[i][1]
-- end

-- function shift_sprite_sheet()
--   for i=0,95 do
--     poke(64*i+0x1838,peek(64*i))
--     memcpy(64*i,64*i+1,56)
--     memcpy(64*i+0x1800,64*i+0x1801,56)
--     poke(64*i+56,peek(64*i+0x1800))
--   end
-- end

function landed_update()
  local p = landed_planet
  if not landed_front_rendered then
    landed_front_rendered = p:render_planet(true)
    if landed_front_rendered then
      p.rendered_circle = false
      p.rendered_terrain = false
      -- for j=1,56 do
      --   shift_sprite_sheet()
      -- end
    end
  else
    if not landed_back_rendered then
      landed_back_rendered = p:render_planet(true, true)
    else
      -- pos=1-pos
      -- if pos==0 then
      --   shift_sprite_sheet()
      -- end
    end
  end
end

function render_landed_screen()
  -- cls()
  if landed_front_rendered and landed_back_rendered then
    -- for i=1,96 do
    --   local a,b=mtbl[i][1],mtbl[i][2]
    --   pal()
    --   local lw=ceil(b*cs[15][2])
    --   for j=15,0,-1 do
    --     if j==4 then
    --       for ci=0,#dark_planet_colors-1 do
    --         pal(ci,dark_planet_colors[ci+1])
    --       end
    --     end
    --     if j<15 then lw=floor(a+b*cs[j+1][1])-floor(a+b*cs[j][1]) end
    --     -- sspr(pos+j*7,i-1,7,1,floor(a+b*cs[j][1]),i+16,lw,1)
    --   end
    -- end
    -- pal()
    text(landed_planet.planet_type.class_name, 1, 1)
  else
    love.graphics.draw(landed_planet.planet_canvas, 0, 0 -- deg270,
    -- game_screen.screen_height/game_screen.pixel_height, -- scale x
    -- game_screen.screen_height/game_screen.pixel_height -- scale y
    -- 0, -- Origin offset (x-axis).
    -- 0, -- Origin offset (y-axis).
    -- 0, -- Shearing factor (x-axis).
    -- 0 -- Shearing factor (y-axis).
    )
    -- sspr(0,0,127,127,0,0)
    text("scanning for a\nsuitable landing site...", 1, 1, 6)
  end
end

function _update()
  framecount = framecount + 1
  framecount = framecount % 30
  if framecount == 0 then secondcount = secondcount + 1 end

  -- mbtn=stat(34)
  if buttons.screen_touch_active then
    mbtn = 1
  else
    mbtn = 0
  end

  if not landed and btnp(4, 0) then
    paused = not paused
    if paused then
      -- sfx(51,2)
      main_menu()
    else
      -- sfx(52,2)
    end
    pressed = nil
  end

  if landed then landed_update() end

  if paused or landed then

    -- mi=buttons.touch_location-Vector(0,26)
    -- mi.x = mi.x * .4
    -- mi=mi:angle()-.375
    -- mi=floor(4*mi)+1
    -- mi = mi % 4
    keys = {"w", "a", "s", "d"}

    for i = 1, 4 do
      if btn(btnv[i]) or love.keyboard.isDown(keys[i]) then pressed = i end
      if pressed then
        if pressed == i and not (btn(btnv[i]) or love.keyboard.isDown(keys[i])) then
          pressed = nil
          msel = secondcount
          call_option(i)
        end
      end
    end

  else

    local no_orders = not pilot.orders[1]
    if no_orders and (mousemode == 1 or (mousemode == 2 and mbtn > 0)) then
      -- pilot:rotate_towards_heading(mv:angle())
      pilot:rotate_towards_heading(buttons.touch_location_angle)
    end

    if (mousemode == 1 and mbtn > 1) -- or (mousemode==2 and mbtn>0 and mv:length()>38)
    or (mousemode == 2 and mbtn > 0 and buttons.touch_location_length > .60 * buttons.touch_location_length_max) or
        btn(2, 0) or love.keyboard.isDown("w") then
      pilot:apply_thrust()
    else
      if pilot.accelerating and no_orders then pilot:cut_thrust() end
      if no_orders then pilot:dampen_speed() end
    end

    -- zoom out
    if btn(6) or love.keyboard.isDown("-") then
      game_screen:zoom_out()
      -- pilot:buildship()
    end
    -- if btnp(6) then
    --   game_screen:int_zoom_out()
    --   -- pilot:buildship()
    -- end
    -- zoom in
    if btn(7) or love.keyboard.isDown("=") then game_screen:zoom_in() end
    -- if btnp(7) then
    --   game_screen:int_zoom_in()
    --   -- pilot:buildship()
    -- end
    -- rotate
    if btnp(8) then game_screen:rotate() end
    -- debug (add npc)
    if btnp(9) then
      local planet, dist = nearest_planet()
      add_npc(planet)

      -- load_sector()
    end

    if btn(0, 0) or love.keyboard.isDown("a") then pilot:turn_left() end
    if btn(1, 0) or love.keyboard.isDown("d") then pilot:turn_right() end
    if btn(3, 0) or love.keyboard.isDown("s") then pilot:reverse_direction() end
    if btn(5, 0) or love.keyboard.isDown(".") or (mousemode == 1 and mbtn == 1 or mbtn == 3) then pilot:fire_weapon() end

    for index, p in ipairs(projectiles) do p:update(pilot.velocity_vector) end

    for index, s in ipairs(npcships) do
      if s.ship_type_index == #ship_types then
        s:rotate(.1)
      else

        if s.last_hit_time and s.last_hit_time + 30 > secondcount then

          s:reset_orders()
          s:flee()
          if s.hostile then
            s.target = s.last_hit_attacking_ship
            s.target_index = s.target.index
          end

        else

          if #s.orders == 0 then
            if s.hostile then
              s.seektime = 0
              if not s.target then next_ship_target(s, true) end
              add(s.orders, s.seek)
            else
              s:approach_object()
              s.wait_duration = random_int(46, 10)
              s.wait_time = secondcount
              add(s.orders, s.wait)
            end
          end
          s:follow_cur_order()

        end

      end

      s:update_location()
      if s.hp < 1 then

        if s.hostile then
          pirates = pirates - 1
          if pirates < 1 then
            note_add("sector cleared!")
            note_display_time = 8
          end
        end

        del(npcships, s)
        pilot:clear_target()
      end
    end

    pilot:follow_cur_order()
    pilot:update_location()
    if pirates < 1 and note_display_time <= 0 then
      note_add("fly to system edge for ftl jump")
      note_display_time = 8
    end
    if pilot.sector_position.x > 32000 or pilot.sector_position.y > 32000 then load_sector() end

    sect:scroll_starfield(pilot.velocity_vector)
  end
end

function render_game_screen()
  cls()
  -- Draw Starfield
  sect:draw_starfield(pilot.velocity_vector)
  -- Draw Planets
  for index, p in ipairs(sect.planets) do p:draw(pilot.sector_position) end
  -- Draw ships if on screen
  for index, s in ipairs(npcships) do if s:is_visible(pilot.sector_position) then s:draw_sprite_rotated() end end

  -- Draw Current Target
  if pilot.target then
    last_offscreen_pos = nil
    local player_screen_position = pilot.screen_position
    local targeted_ship = pilot.target
    if targeted_ship then
      if not targeted_ship:is_visible(pilot.sector_position) then
        local distance = "" .. floor((targeted_ship.screen_position - player_screen_position):length())
        local color, shadow = targeted_ship:targeted_color()
        local hull_radius = floor(targeted_ship.sprite_rows * .5)
        local d = rotated_vector((targeted_ship.screen_position - player_screen_position):angle())
        -- target is shown in a circle around the player
        -- use the smaller of the two screen dimensions to define the circle radius
        local draw_dist_from_center = floor(min(game_screen.pixel_width, game_screen.pixel_height) / 2 - 8)
        last_offscreen_pos = d * (draw_dist_from_center - hull_radius) + game_screen.screen_center
        local p2 = last_offscreen_pos:clone():add(Vector(-4 * (#distance / 2))):add(zoom_offset)
        targeted_ship:draw_sprite_rotated(last_offscreen_pos)
        if p2.y > floor(game_screen.pixel_width / 2 - 1) then
          p2:add(Vector(1, -12 - hull_radius))
        else
          p2:add(Vector(1, 7 + hull_radius))
        end
        text(distance, round(p2.x), round(p2.y), color)
      end
      text(targeted_ship.name .. targeted_ship:hp_string(), 0, game_screen.pixel_height - 14, targeted_ship:hp_color())
    end
  end

  -- Draw player pilot ship
  pilot:draw()

  -- If dead show the continue menu
  if pilot.hp < 1 then
    paused = true
    pilot.dead = true
    menu("x78bb|acontinue?,nil,yes,|", {
      nil, nil, function()
        pilot.dead = false
        pilot:buildship(pilot.seed_value, pilot.ship_type_index)
        return false
      end
    })
  end

  -- Draw damage particles
  for index, p in ipairs(particles) do
    if is_offscreen(p, 32) then
      del(particles, p)
    else
      if paused then
        p:draw(Vector())
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  -- Draw projectiles
  for index, p in ipairs(projectiles) do
    if is_offscreen(p, 63) then
      del(projectiles, p)
    else
      if last_offscreen_pos and p.sector_position and pilot.target and
          (pilot.target.sector_position - p.sector_position):length() <= pilot.target.sprite_rows then
        p:draw(nil, (p.sector_position - pilot.target.sector_position) + last_offscreen_pos)
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  -- Draw the minimap
  draw_mmap()

  -- If warping, draw the warp effect
  if warpsize > 0 then
    -- camera shake on pico8
    -- camera(random_int(2)-1, random_int(2)-1)
    circfill(63, 63, warpsize, 7)
    warpsize = warpsize - 1
    -- reset camera if warp is done
    -- if warpsize==0 then camera() end
  end

end

function _draw()
  if landed then
    render_landed_screen()
  else
    render_game_screen()
  end
  if paused or landed then menu() end
  note_draw()
  -- draw cursor for mouse mode
  -- if mousemode>0 then
  --   buttons.touch_location:draw_circle(1,8)
  -- end
end
