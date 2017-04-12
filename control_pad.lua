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
        size = 50
      end
      if separation == nil then
        separation = 100
      end
      self.button_size = size
      self.button_separation = separation
      local dpad = Vector(self.screen_height + (2 * separation), self.screen_height - separation)
      local ab = Vector(self.screen_height + (2 * separation), separation)
      self.screen_positions = {
        dpad + Vector(0, -separation),
        dpad + Vector(0, separation),
        dpad + Vector(-separation, 0),
        dpad + Vector(separation, 0),
        ab + Vector(0, -separation),
        ab + Vector(0, separation)
      }
    end,
    draw = function(self)
      for button in self.screen_positions do
        color(5)
        love.graphics.circle("fill", button.x, button.y, self.button_size)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, screen_width, screen_height, portrait)
      self.screen_width, self.screen_height, self.portrait = screen_width, screen_height, portrait
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
