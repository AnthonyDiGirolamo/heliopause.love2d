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
      "zoomin"
    },
    set_positions = function(self, size, separation)
      if size == nil then
        size = 150
      end
      if separation == nil then
        separation = 150
      end
      local half_screen_height = floor(self.screen_height / 2)
      local half_screen_width = floor(self.screen_width / 2)
      self.screen_center = Vector(half_screen_width, half_screen_height)
      self.touch_location_length_max = half_screen_height
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
        zoom + Vector(0, -separation)
      }
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.positions
        for _index_0 = 1, #_list_0 do
          local p = _list_0[_index_0]
          _accum_0[_len_0] = p:round()
          _len_0 = _len_0 + 1
        end
        self.positions = _accum_0
      end
      self.sizes = {
        size,
        size,
        size,
        size,
        size,
        size,
        size,
        size
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
        color(5)
        love.graphics.circle("line", button.x, button.y, self.sizes[i])
      end
    end,
    get_presses = function(self, touches, delta_time)
      local valid_button_touches = { }
      for bi, current_hold_time in ipairs(self.hold_time) do
        local is_pressed = false
        for ti, touch in ipairs(touches) do
          local x, y = love.touch.getPosition(touch)
          local touch_location = Vector(x, y) - self.positions[bi]
          local touch_location_length = touch_location:length()
          if touch_location_length < self.sizes[bi] then
            is_pressed = true
            table.insert(valid_button_touches, ti)
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
      self.touch_location_angle = false
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
