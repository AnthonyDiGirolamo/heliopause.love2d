Object = require("classic")

local Vector
Vector = require("vector").Vector
local color, floor
do
  local _obj_0 = require("helpers")
  color = _obj_0.color
  floor = _obj_0.floor
end

TouchInput = Object:extend()

function TouchInput:new(screen_width, screen_height, portrait)
  self.screen_width, self.screen_height, self.portrait = screen_width, screen_height, portrait
  self.positions = {}
  self.hold_time = {}
  self.hold_frames = {}
  self.touch_location = Vector()
  self.touch_location_angle = 0
  self.touch_location_length = 0
  self.touch_location_length_max = 0
  self.screen_touch_active = false
  self.screen_center = Vector()
  self:set_positions()

  self.names = {
    "right",
    "left",
    "up",
    "down",
    "fire",
    "pause",
    "zoomout",
    "zoomin",
    "rotate",
    "debug"
  }
end

function TouchInput:rotate()
  self.portrait = not self.portrait
  return self:set_positions()
end

function TouchInput:set_screen_size(w, h)
  self.screen_width = w
  self.screen_height = h
  return self:set_positions()
end

function TouchInput:set_positions(size_ratio, separation_ratio)
  if size_ratio == nil then
    size_ratio = .063
  end
  if separation_ratio == nil then
    separation_ratio = .063
  end
  local size = floor(size_ratio * self.screen_width)
  local separation = floor(separation_ratio * self.screen_width)
  local half_screen_height = floor(self.screen_height / 2)
  local half_screen_width = floor(self.screen_width / 2)
  self.screen_center = Vector(half_screen_width, half_screen_height)
  self.touch_location_length_max = half_screen_height

  if self.portrait then
    -- portrait base positions
    local dpad = Vector(self.screen_height + 2 * separation, self.screen_height - 2 * separation)
    local ab = Vector(self.screen_height + 2 * separation, 2 * separation)
    local zoom = Vector(self.screen_width - 2 * separation, half_screen_height)
    self.positions = {
      dpad + Vector(0, separation),  -- left
      dpad + Vector(0, -separation), -- right
      dpad + Vector(-separation, 0), -- up
      dpad + Vector(separation, 0),  -- down
      ab + Vector(0, separation),    -- fire
      ab + Vector(0, -separation),   -- pause
      zoom + Vector(0, 0.5 * separation),      -- zoom out
      zoom + Vector(0, -0.5 * separation),     -- zoom in
      zoom + Vector(0, -3 * 0.5 * separation), -- rotate
      zoom + Vector(0, 3 * 0.5 * separation)   -- debug
    }
  else
    -- landscape base positions
    local dpad = Vector(2 * separation, half_screen_height)
    local ab = Vector(self.screen_width - 3 * separation, half_screen_height)
    local zoom = Vector(half_screen_width, self.screen_height - 1 * separation)
    self.positions = {
      dpad + Vector(-separation, 0), -- left
      dpad + Vector(separation, 0),  -- right
      dpad + Vector(0, -separation), -- up
      dpad + Vector(0, separation),  -- down
      ab + Vector(-separation, 0),   -- fire
      ab + Vector(separation, 0),    -- pause
      zoom + Vector(-0.5 * separation, 0),    -- zoom out
      zoom + Vector(0.5 * separation, 0),     -- zoom in
      zoom + Vector(3 * 0.5 * separation, 0), -- rotate
      zoom + Vector(-3 * 0.5 * separation, 0) -- debug
    }
  end
  self.sizes = {
    size, -- left
    size, -- right
    size, -- up
    size, -- down
    size, -- fire
    size, -- pause
    size / 2, -- zoom out
    size / 2, -- zoom in
    size / 2, -- rotate
    size / 2  -- debug
  }
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = self.positions
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      _accum_0[_len_0] = 0
      _len_0 = _len_0 + 1
    end
    self.hold_time = _accum_0
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = self.positions
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      _accum_0[_len_0] = 0
      _len_0 = _len_0 + 1
    end
    self.hold_frames = _accum_0
  end
  return self
end

function TouchInput:draw()
  for i, button in ipairs(self.positions) do
    if button then
      color(5)
      love.graphics.circle("line", button.x, button.y, self.sizes[i])
    end
  end
end

function TouchInput:get_presses(touches, delta_time)
  local valid_button_touches = { }
  for bi, current_hold_time in ipairs(self.hold_time) do
    if self.positions[bi] then
      local is_pressed = false
      for ti, touch in ipairs(touches) do
        local x, y = love.touch.getPosition(touch)
        local touch_location = Vector(x, y) - self.positions[bi]
        local touch_location_length = touch_location:length()
        if touch_location_length < self.sizes[bi] then
          is_pressed = true
          valid_button_touches[ti] = true
        end
      end
      if is_pressed then
        self.hold_time[bi] = self.hold_time[bi] + delta_time
        self.hold_frames[bi] = self.hold_frames[bi] + 1
      else
        self.hold_time[bi] = 0
        self.hold_frames[bi] = 0
      end
    end
  end
  self.screen_touch_active = false
  for ti, touch in ipairs(touches) do
    if not valid_button_touches[ti] then
      self.screen_touch_active = true
      local x, y = love.touch.getPosition(touch)
      local touch_location = Vector(x, y) - self.screen_center
      self.touch_location = touch_location:clone()
      if self.portrait then
        self.touch_location:rotate(-.25)
      end
      self.touch_location_angle = self.touch_location:angle()
      self.touch_location_length = touch_location:length()
    end
  end
  return self.hold_time
end

function TouchInput:btn(number)
  return self.hold_time[number + 1] > 0
end

function TouchInput:btnp(number)
  return self.hold_frames[number + 1] == 1
end

return {TouchInput = TouchInput}
