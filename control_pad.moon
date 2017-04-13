import Vector from require "vector"
import color from require "helpers"

class ControlPad
  new: (@screen_width, @screen_height, @portrait) =>
    @screen_positions = {}
    @hold_time = {}
    @set_positions!

  names: {
    "right"
    "left"
    "up"
    "down"
    "pause"
    "fire"
  }

  set_positions: (size=150, separation=150) =>
    @button_size = size
    @button_separation = separation
    -- portait
    dpad = Vector @screen_height + 2 * separation,
             @screen_height - 2 * separation
    ab = Vector @screen_height + 2 * separation,
           2 * separation
    @screen_positions = {
      dpad + Vector(0, separation)  -- right
      dpad + Vector(0, -separation) -- left
      dpad + Vector(-separation, 0) -- up
      dpad + Vector(separation, 0)  -- down
      ab + Vector(0, -separation)   -- pause
      ab + Vector(0, separation)    -- fire
    }
    @screen_positions = [p\round! for p in *@screen_positions]
    @hold_time = [0 for p in *@screen_positions]
    self

  draw: =>
    for i, button in ipairs @screen_positions
      color(5)
      love.graphics.circle "line",
        button.x, button.y,
        @button_size

  get_presses: (touches, delta_time) =>
    for bi, current_hold_time in ipairs @hold_time
      is_pressed = false
      for ti, touch in ipairs touches
        x, y = love.touch.getPosition(touch)
        if (Vector(x,y) - @screen_positions[bi])\length! < @button_size
          is_pressed = true
      if is_pressed
        @hold_time[bi] += delta_time
      else
        @hold_time[bi] = 0
    @hold_time

  btn: (number) =>
    @hold_time[number + 1] > 0

  btnp: (number) =>
    ht = @hold_time[number + 1]
    ht > 0 and ht < .04

{
  :ControlPad
}
