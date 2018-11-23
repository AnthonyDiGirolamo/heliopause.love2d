local Vector
Vector = require("vector").Vector
local color, floor
do
  local _obj_0 = require("helpers")
  color, floor = _obj_0.color, _obj_0.floor
end
local ControlPad
do
  local _class_0
  local _base_0 = {
    names = {
      "right",
      "left",
      "up",
      "down",
      "fire",
      "pause",
      "zoomout",
      "zoomin",
      "rotate"
    },
    rotate = function(self)
      self.portrait = not self.portrait
      return self:set_positions()
    end,
    set_screen_size = function(self, w, h)
      self.screen_width = w
      self.screen_height = h
      return self:set_positions()
    end,
    set_positions = function(self, size_ratio, separation_ratio)
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
        local dpad = Vector(self.screen_height + 2 * separation, self.screen_height - 2 * separation)
        local ab = Vector(self.screen_height + 2 * separation, 2 * separation)
        local zoom = Vector(self.screen_width - 2 * separation, half_screen_height)
        self.positions = {
          dpad + Vector(0, separation),
          dpad + Vector(0, -separation),
          dpad + Vector(-separation, 0),
          dpad + Vector(separation, 0),
          ab + Vector(0, separation),
          ab + Vector(0, -separation),
          zoom + Vector(0, separation),
          zoom + Vector(0, -separation),
          zoom + Vector(0, -3 * separation)
        }
      else
        local dpad = Vector(2 * separation, half_screen_height)
        local ab = Vector(self.screen_width - 3 * separation, half_screen_height)
        local zoom = Vector(half_screen_width, self.screen_height - 1 * separation)
        self.positions = {
          dpad + Vector(-separation, 0),
          dpad + Vector(separation, 0),
          dpad + Vector(0, -separation),
          dpad + Vector(0, separation),
          ab + Vector(-separation, 0),
          ab + Vector(separation, 0),
          zoom + Vector(-separation, 0),
          zoom + Vector(separation, 0),
          zoom + Vector(3 * separation, 0)
        }
      end
      self.sizes = {
        size,
        size,
        size,
        size,
        size,
        size,
        size,
        size,
        size / 2
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
    end,
    draw = function(self)
      for i, button in ipairs(self.positions) do
        if button then
          color(5)
          love.graphics.circle("line", button.x, button.y, self.sizes[i])
        end
      end
    end,
    get_presses = function(self, touches, delta_time)
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
    end,
    btn = function(self, number)
      return self.hold_time[number + 1] > 0
    end,
    btnp = function(self, number)
      return self.hold_frames[number + 1] == 1
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, screen_width, screen_height, portrait)
      self.screen_width, self.screen_height, self.portrait = screen_width, screen_height, portrait
      self.positions = { }
      self.hold_time = { }
      self.hold_frames = { }
      self.touch_location = Vector()
      self.touch_location_angle = 0
      self.touch_location_length = 0
      self.touch_location_length_max = 0
      self.screen_touch_active = false
      self.screen_center = Vector()
      return self:set_positions()
    end,
    __base = _base_0,
    __name = "ControlPad"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ControlPad = _class_0
end
return {
  ControlPad = ControlPad
}
