picocolors = {
  {0x1D, 0x2B, 0x53}, -- 1 dark_blue
  {0x7E, 0x25, 0x53}, -- 2 dark_purple
  {0x00, 0x87, 0x51}, -- 3 dark_green
  {0xAB, 0x52, 0x36}, -- 4 brown
  {0x5F, 0x57, 0x4F}, -- 5 dark_gray
  {0xC2, 0xC3, 0xC7}, -- 6 light_gray
  {0xFF, 0xF1, 0xE8}, -- 7 white
  {0xFF, 0x00, 0x4D}, -- 8 red
  {0xFF, 0xA3, 0x00}, -- 9 orange
  {0xFF, 0xEC, 0x27}, -- 10 yellow
  {0x00, 0xE4, 0x36}, -- 11 green
  {0x29, 0xAD, 0xFF}, -- 12 blue
  {0x83, 0x76, 0x9C}, -- 13 indigo
  {0xFF, 0x77, 0xA8}, -- 14 pink
  {0xFF, 0xCC, 0xAA}, -- 15 peach
}
picocolors[0] = {0,0,0} -- 0 black

cls = ->
  love.graphics.clear()

color = (c) ->
  love.graphics.setColor(unpack(picocolors[c] or {0,0,0}))

circfill = (x, y, radius, c) ->
  color c
  love.graphics.circle("fill", x, y, radius)

-- function rect(ax, ay, bx, by, c)
--   color(c)
--   local w = bx-ax
--   local h = bx-ax
--   -- -- print(ax..","..ay.." - "..bx..","..by.." - "..w..","..h.."\n")
--   -- if w==0 and h==0 then
--   --   love.graphics.points(ax, ay)
--   -- else
--     love.graphics.rectangle("line", ax, ay, w, h)
--   -- end
-- end

rectfill = (ax, ay, bx, by, c) ->
  color c if c
  if bx < ax
    ax, bx = bx, ax
  if by < ay
    ay, by = by, ay

  if ax == bx or ay == by
    -- rectangle is only one pixel tall or wide
    love.graphics.line ax, ay, bx, by
  else
    love.graphics.rectangle("fill",
      math.floor(ax),
      math.floor(ay),
      math.floor(bx - ax) + 1,
      math.floor(by - ay) + 1)

{
  :rectfill
  :circfill
  :cls
  :color
}
