import Vector from require "vector"
import color from require "pico_api"

class ControlPad
  new: (@screen_width, @screen_height, @portrait) =>
    @set_positions!

  names: {
    "left"
    "right"
    "up"
    "down"
    "pause"
    "fire"
  }

  set_positions: (size=50, separation=100) =>
    @button_size = size
    @button_separation = separation

    -- portait
    dpad = Vector @screen_height + (2 * separation),
             @screen_height - separation
    ab = Vector @screen_height + (2 * separation),
           separation

    @screen_positions = {
      dpad + Vector(0, -separation) -- left
      dpad + Vector(0, separation)  -- right
      dpad + Vector(-separation, 0) -- up
      dpad + Vector(separation, 0)  -- down
      ab + Vector(0, -separation)   -- pause
      ab + Vector(0, separation)    -- fire
    }

  draw: =>
    for button in @screen_positions
      color(5)
      love.graphics.circle("fill", button.x, button.y, @button_size)




-- stat = (args) ->
--   0
--
-- btn = (args) ->
--   false
--
-- btnp = (args) ->
--   -- touches = love.touch.getTouches()
--   -- return #touches>0
--   false
--
-- -- function rect(x1, y1, x2, y2, c)
-- --   color(c)
-- --   local w = x2-x1
-- --   local h = x2-x1
-- --   -- -- print(x1..","..y1.." - "..x2..","..y2.." - "..w..","..h.."\n")
-- --   -- if w==0 and h==0 then
-- --   --   love.graphics.points(x1, y1)
-- --   -- else
-- --     love.graphics.rectangle("line", x1, y1, w, h)
-- --   -- end
-- -- end
--
-- function rectfill(x1, y1, x2, y2, c)
--   color(c)
--   local w = x2-x1+1
--   local h = y2-y1+1
--   -- print(x1..","..y1.." - "..x2..","..y2.." - "..w..","..h.."\n")
--   -- if w==0 and h==0 then
--   --   w,h=1,1
--   --   love.graphics.points(x1, y1)
--   --   love.graphics.points(x2, y2)
--   -- else
--   -- end
--   love.graphics.rectangle("fill", x1, y1, w, h)
-- end
--

{
  :ControlPad
}
