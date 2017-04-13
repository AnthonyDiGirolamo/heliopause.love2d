local Vector
Vector = require("vector").Vector
local color
color = require("pico_api").color
local ControlPad
do
  local _class_0
  local _base_0 = {
    names = {
      "left",
      "right",
      "up",
      "down",
      "pause",
      "fire"
    },
    set_positions = function(self, size, separation)
      if size == nil then
        size = 150
      end
      if separation == nil then
        separation = 150
      end
      self.button_size = size
      self.button_separation = separation
      local dpad = Vector(self.screen_height + 2 * separation, self.screen_height - 2 * separation)
      local ab = Vector(self.screen_height + 2 * separation, 2 * separation)
      self.screen_positions = {
        dpad + Vector(0, -separation),
        dpad + Vector(0, separation),
        dpad + Vector(-separation, 0),
        dpad + Vector(separation, 0),
        ab + Vector(0, -separation),
        ab + Vector(0, separation)
      }
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.screen_positions
        for _index_0 = 1, #_list_0 do
          local p = _list_0[_index_0]
          _accum_0[_len_0] = p:round()
          _len_0 = _len_0 + 1
        end
        self.screen_positions = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.screen_positions
        for _index_0 = 1, #_list_0 do
          local p = _list_0[_index_0]
          _accum_0[_len_0] = 0
          _len_0 = _len_0 + 1
        end
        self.hold_time = _accum_0
      end
      return self
    end,
    draw = function(self)
      for i, button in ipairs(self.screen_positions) do
        color(5)
        love.graphics.circle("line", button.x, button.y, self.button_size)
      end
    end,
    get_presses = function(self, touches, delta_time)
      for bi, current_hold_time in ipairs(self.hold_time) do
        local is_pressed = false
        for ti, touch in ipairs(touches) do
          local x, y = love.touch.getPosition(touch)
          if (Vector(x, y) - self.screen_positions[bi]):length() < self.button_size then
            is_pressed = true
          end
        end
        if is_pressed then
          self.hold_time[bi] = self.hold_time[bi] + delta_time
        else
          self.hold_time[bi] = 0
        end
      end
      return self.hold_time
    end,
    btn = function(self, number)
      return self.hold_time[number + 1] > 0
    end,
    btnp = function(self, number)
      local ht = self.hold_time[number + 1]
      return ht > 0 and ht < .04
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, screen_width, screen_height, portrait)
      self.screen_width, self.screen_height, self.portrait = screen_width, screen_height, portrait
      self.screen_positions = { }
      self.hold_time = { }
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
