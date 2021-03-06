import Vector from require "vector"
import color, floor from require "helpers"

class ControlPad
  new: (@screen_width, @screen_height, @portrait) =>
    @positions = {}
    @hold_time = {}
    @hold_frames = {}
    @touch_location = Vector!
    @touch_location_angle = 0
    @touch_location_length = 0
    @touch_location_length_max = 0
    @screen_touch_active = false
    @screen_center = Vector!
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
    "rotate"
    "debug"
  }


  rotate: () =>
    @portrait = not @portrait
    @set_positions!


  set_screen_size: (w, h) =>
    @screen_width = w
    @screen_height = h
    @set_positions!


  set_positions: (size_ratio=.063, separation_ratio=.063) =>
    size = floor(size_ratio * @screen_width)
    separation = floor(separation_ratio * @screen_width)

    half_screen_height = floor(@screen_height/2)
    half_screen_width = floor(@screen_width/2)
    @screen_center = Vector(half_screen_width, half_screen_height)
    @touch_location_length_max = half_screen_height

    if @portrait
      -- portrait base positions
      dpad = Vector(@screen_height + 2 * separation, @screen_height - 2 * separation)
      ab = Vector(@screen_height + 2 * separation, 2 * separation)
      zoom = Vector(@screen_width - 2 * separation, half_screen_height)
      @positions = {
        dpad + Vector(0, separation)  -- left
        dpad + Vector(0, -separation) -- right
        dpad + Vector(-separation, 0) -- up
        dpad + Vector(separation, 0)  -- down
        ab + Vector(0, separation)    -- fire
        ab + Vector(0, -separation)   -- pause
        zoom + Vector(0, 0.5*separation)  -- zoom out
        zoom + Vector(0, -0.5*separation) -- zoom in
        zoom + Vector(0, -3*0.5*separation) -- rotate
        zoom + Vector(0, 3*0.5*separation) -- debug
      }
    else
      -- landscape base positions
      dpad = Vector(2*separation, half_screen_height)
      ab = Vector(@screen_width - 3 * separation, half_screen_height)
      zoom = Vector(half_screen_width, @screen_height - 1 * separation)
      @positions = {
        dpad + Vector(-separation, 0) -- left
        dpad + Vector(separation, 0)  -- right
        dpad + Vector(0, -separation) -- up
        dpad + Vector(0, separation)  -- down
        ab + Vector(-separation, 0)   -- fire
        ab + Vector(separation, 0)    -- pause
        zoom + Vector(-0.5*separation, 0) -- zoom out
        zoom + Vector(0.5*separation, 0)  -- zoom in
        zoom + Vector(3*0.5*separation, 0) -- rotate
        zoom + Vector(-3*0.5*separation, 0) -- debug
      }


    @sizes = {
      size -- left
      size -- right
      size -- up
      size -- down
      size -- fire
      size -- pause
      size/2 -- zoom out
      size/2 -- zoom in
      size/2 -- rotate
      size/2 -- debug
    }
    @hold_time = [0 for p in *@positions]
    @hold_frames = [0 for p in *@positions]
    self

  draw: =>
    for i, button in ipairs @positions
      if button
        color(5)
        -- unless i == #@positions
        love.graphics.circle "line",
          button.x, button.y,
          @sizes[i]


  get_presses: (touches, delta_time) =>
    valid_button_touches = {}
    for bi, current_hold_time in ipairs @hold_time
      if @positions[bi]
        is_pressed = false
        for ti, touch in ipairs touches
          x, y = love.touch.getPosition(touch)
          touch_location = Vector(x,y) - @positions[bi]
          touch_location_length = touch_location\length!
          if touch_location_length < @sizes[bi]
            is_pressed = true
            valid_button_touches[ti] = true
        if is_pressed
          @hold_time[bi] += delta_time
          @hold_frames[bi] += 1
        else
          @hold_time[bi] = 0
          @hold_frames[bi] = 0
    @screen_touch_active = false
    for ti, touch in ipairs touches
      if not valid_button_touches[ti]
        @screen_touch_active = true
        x, y = love.touch.getPosition(touch)
        touch_location = Vector(x,y) - @screen_center
        @touch_location = touch_location\clone()
        if @portrait
          @touch_location\rotate(-.25)
        @touch_location_angle = @touch_location\angle!
        @touch_location_length = touch_location\length!
    @hold_time

  btn: (number) =>
    @hold_time[number + 1] > 0

  btnp: (number) =>
    @hold_frames[number + 1] == 1

{
  :ControlPad
}
