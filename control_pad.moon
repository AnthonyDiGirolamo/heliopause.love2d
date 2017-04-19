import Vector from require "vector"
import color, floor from require "helpers"

class ControlPad
  new: (@screen_width, @screen_height, @portrait) =>
    @positions = {}
    @hold_time = {}
    @hold_frames = {}
    @touch_location = Vector!
    @touch_location_angle = false
    @touch_location_length = 0
    @touch_location_length_max = 0
    @set_positions!

  names: {
    "right"
    "left"
    "up"
    "down"
    "fire"
    "pause"
    "zoomout"
    "zoomin"
  }

  set_positions: (size=150, separation=150) =>
    half_screen_height = floor(@screen_height/2)
    @touch_location_length_max = half_screen_height
    -- portait
    dpad = Vector @screen_height + 2 * separation,
             @screen_height - 2 * separation
    ab = Vector @screen_height + 2 * separation,
           2 * separation
    zoom = Vector @screen_width - 2 * separation,
      half_screen_height

    @positions = {
      dpad + Vector(0, separation)  -- left
      dpad + Vector(0, -separation) -- right
      dpad + Vector(-separation, 0) -- up
      dpad + Vector(separation, 0)  -- down
      ab + Vector(0, separation)    -- fire
      ab + Vector(0, -separation)   -- pause
      zoom + Vector(0, separation)  -- zoom out
      zoom + Vector(0, -separation) -- zoom in
      Vector(half_screen_height, half_screen_height)
    }

    @positions = [p\round! for p in *@positions]

    @sizes = {
      size -- left
      size -- right
      size -- up
      size -- down
      size -- fire
      size -- pause
      size -- zoom out
      size -- zoom in
      half_screen_height
    }
    @hold_time = [0 for p in *@positions]
    @hold_frames = [0 for p in *@positions]
    self

  draw: =>
    for i, button in ipairs @positions
      color(5)
      love.graphics.circle "line",
        button.x, button.y,
        @sizes[i]


  get_presses: (touches, delta_time) =>
    for bi, current_hold_time in ipairs @hold_time
      is_pressed = false
      for ti, touch in ipairs touches
        x, y = love.touch.getPosition(touch)
        touch_location = Vector(x,y) - @positions[bi]
        touch_location_length = touch_location\length!
        if touch_location_length < @sizes[bi]
          is_pressed = true
          if bi == #@positions
            @touch_location = touch_location\clone()\rotate(-.25)
            @touch_location_angle = @touch_location\angle!
            @touch_location_length = touch_location_length
      if is_pressed
        @hold_time[bi] += delta_time
        @hold_frames[bi] += 1
      else
        @hold_time[bi] = 0
        @hold_frames[bi] = 0
    @hold_time

  btn: (number) =>
    @hold_time[number + 1] > 0

  btnp: (number) =>
    @hold_frames[number + 1] == 1

{
  :ControlPad
}
