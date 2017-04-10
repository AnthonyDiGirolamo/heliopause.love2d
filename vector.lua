local Vector={}
Vector.__index=Vector
function Vector.new(x,y)
  return setmetatable({x=x or 0,y=y or 0},Vector)
end

function Vector:add(v)
  self.x = self.x + v.x
  self.y = self.y + v.y
  return self
end

function Vector.__add(a,b)
  return Vector.new(a.x+b.x,a.y+b.y)
end
function Vector.__sub(a,b)
  return Vector.new(a.x-b.x,a.y-b.y)
end
function Vector.__mul(a,b)
  return Vector.new(a.x*b,a.y*b)
end
function Vector.__div(a,b)
  return Vector.new(a.x/b,a.y/b)
end

function Vector:clone()
  return Vector.new(self.x,self.y)
end
function Vector:about_equals(v)
  return round(v.x)==self.x and round(v.y)==self.y end
function Vector:angle()
  return math.atan2(self.x,self.y) / math.pi*2
end

function Vector:length()
  return math.sqrt(self.x^2+self.y^2)
end
function Vector:scaled_length()
  return 182*math.sqrt((self.x/182)^2+(self.y/182)^2)
end
function scaled_dist(a,b)
  return (b-a):scaled_length()
end

function Vector:perpendicular()
  return Vector.new(-self.y,self.x)
end

function Vector:normalize()
  local l=self:length()
  self.x = self.x / l
  self.y = self.y / l
  return self
end

function Vector:rotate(phi)
  local c=math.cos(phi)/math.pi*2
  local s=math.sin(phi)/math.pi*2
  local x=self.x
  local y=self.y
  self.x=c*x-s*y
  self.y=s*x+c*y
  return self
end

function Vector:round()
  self.x=round(self.x)
  self.y=round(self.y)
  return self
end

function Vector:draw_point(c)
  pset(
    round(self.x),
    round(self.y),c)
end

function Vector:draw_line(v,c)
  love.graphics.setColor( unpack(picocolors[c]) )
  love.graphics.line(self.x, self.y, v.x, v.y)

  -- line(
  --   round(self.x),
  --   round(self.y),
  --   round(v.x),
  --   round(v.y),c)
end

function Vector:draw_circle(radius,c,fill)
  local method=circ
  if fill then method=circfill end
  method(
    round(self.x),
    round(self.y),
    round(radius),c)
end

setmetatable(Vector,{__call=function(_,...) return Vector.new(...) end})

return Vector
