local picocolors = {
  {
    0x1D,
    0x2B,
    0x53
  },
  {
    0x7E,
    0x25,
    0x53
  },
  {
    0x00,
    0x87,
    0x51
  },
  {
    0xAB,
    0x52,
    0x36
  },
  {
    0x5F,
    0x57,
    0x4F
  },
  {
    0xC2,
    0xC3,
    0xC7
  },
  {
    0xFF,
    0xF1,
    0xE8
  },
  {
    0xFF,
    0x00,
    0x4D
  },
  {
    0xFF,
    0xA3,
    0x00
  },
  {
    0xFF,
    0xEC,
    0x27
  },
  {
    0x00,
    0xE4,
    0x36
  },
  {
    0x29,
    0xAD,
    0xFF
  },
  {
    0x83,
    0x76,
    0x9C
  },
  {
    0xFF,
    0x77,
    0xA8
  },
  {
    0xFF,
    0xCC,
    0xAA
  }
}
picocolors[0] = {
  0,
  0,
  0
}
local cls
cls = function()
  return love.graphics.clear()
end
local color
color = function(c)
  return love.graphics.setColor(unpack(picocolors[c] or {
    0,
    0,
    0
  }))
end
local circfill
circfill = function(x, y, radius, c)
  color(c)
  return love.graphics.circle("fill", x, y, radius)
end
local rectfill
rectfill = function(x1, y1, x2, y2, c)
  color(c)
  local w = x2 - x1 + 1
  local h = y2 - y1 + 1
  return love.graphics.rectangle("fill", x1, y1, w, h)
end
return {
  rectfill = rectfill,
  circfill = circfill,
  cls = cls,
  color = color
}
