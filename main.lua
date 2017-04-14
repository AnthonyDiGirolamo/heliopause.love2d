-- debug = true
local shine = require("shine")
local lume = require("lume")


local round, randomseed, random, random_int, cos, sin, sqrt, sub, add, del, abs, min, max, floor, ceil, rectfill, circfill, cls, color, sset, band, bor, bxor, bnot, shl, shr

do
  local _obj_0 = require("helpers")
  rectfill, circfill, cls, color, round, randomseed, random, random_int, cos, sin, sqrt, sub, add, del, abs, min, max, floor, ceil, sset, band, bor, bxor, bnot, shl, shr = _obj_0.rectfill, _obj_0.circfill, _obj_0.cls, _obj_0.color, _obj_0.round, _obj_0.randomseed, _obj_0.random, _obj_0.random_int, _obj_0.cos, _obj_0.sin, _obj_0.sqrt, _obj_0.sub, _obj_0.add, _obj_0.del, _obj_0.abs, _obj_0.min, _obj_0.max, _obj_0.floor, _obj_0.ceil, _obj_0.sset, _obj_0.band, _obj_0.bor, _obj_0.bxor, _obj_0.bnot, _obj_0.shl, _obj_0.shr
end

-- load vector.moon
local Vector
do
  local _obj_0 = require("vector")
  Vector = _obj_0.Vector
end

local ControlPad
do
  local _obj_0 = require("control_pad")
  ControlPad = _obj_0.ControlPad
end

function stat(args)
  return 0
end


-- black       = 0
-- dark_blue   = 1
-- dark_purple = 2
-- dark_green  = 3
-- brown       = 4
-- dark_gray   = 5
-- light_gray  = 6
-- white       = 7
-- red         = 8
-- orange      = 9
-- yellow      = 10
-- green       = 11
-- blue        = 12
-- indigo      = 13
-- pink        = 14
-- peach       = 15

function vector_distance(a,b)
  return (b-a):scaled_length()
end

local time = 0
local screen_width, screen_height = 1366, 768
-- local pixel_screen_width, pixel_screen_height = 128, 128
local pixel_screen_width, pixel_screen_height = 160, 160
-- local pixel_screen_width, pixel_screen_height = 256, 256
local starfield_count = 40 * (pixel_screen_width*pixel_screen_height) / (128*128)
local screen_center = Vector(floor(pixel_screen_width/2),floor(pixel_screen_height/2))
local buttons

function btn(number, player)
  return buttons:btn(number)
end

function btnp(number, player)
  return buttons:btnp(number)
end

-- titlestarv=Vector(3,-7)
--star_color_index=0
--star_color_monochrome=0
--split_start=1
--star_colors=nsplit"xaecd76|x98d165|x421051|x767676|x656565|x515151|"
---- star_colors={{0xa,0xe,0xc,0xd,0x7,0x6},{0x9,0x8,0xd,0x1,0x6,0x5},{0x4,0x2,0x1,0x0,0x5,0x1},{0x7,0x6,0x7,0x6,0x7,0x6},{0x6,0x5,0x6,0x5,0x6,0x5},{0x5,0x1,0x5,0x1,0x5,0x1}}
--sect = sector.new()

function love.load(arg)
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  buttons = ControlPad(screen_width, screen_height, true)

  pixelfont = love.graphics.newFont("PICO-8.ttf", 5)
  -- pixelfont = love.graphics.newFont("Droid Sans Mono.ttf", 12)
  -- debugfont = love.graphics.newFont(32)
  -- debugfont = love.graphics.newFont("small_font.ttf", 8)
  debugfont = love.graphics.newFont("PragmataProMono.ttf", 32)
  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")
  -- love.graphics.setLineStyle("smooth")

  game_screen_canvas = love.graphics.newCanvas(pixel_screen_width, pixel_screen_height)
  game_screen_canvas:setFilter("nearest", "nearest")
  -- game_screen_canvas:setFilter("linear", "linear", 1)

  -- local grain = shine.filmgrain()
  -- grain.opacity = 0.2
  -- local vignette = shine.vignette()
  -- vignette.parameters = {radius = 0.9, opacity = 0.7}
  -- local desaturate = shine.desaturate{strength = 0.6, tint = {255,250,200}}
  -- post_effect = desaturate:chain(grain):chain(vignette)
  -- post_effect.opacity = 0.5 -- affects both vignette and film grain
  -- post_effect = shine.scanlines()
  -- post_effect.opacity = 0.5 -- affects both vignette and film grain

  _init()
end

local touches
function love.update(dt)
  time = time + dt
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()

  touches = love.touch.getTouches()
  buttons:get_presses(touches, love.timer.getDelta())

  _update()
end

local deg270 = math.pi*1.5
local debug_messages


function love.draw()

  love.graphics.setCanvas(game_screen_canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(pixelfont)

  debug_messages = {
    ("FPS:     " .. love.timer.getFPS()),
    ("dt:      " .. love.timer.getDelta()),
    ("time:    " .. time),
    ("os.time: " .. os.time()),
    ("screen:  " .. screen_width.." x "..screen_height),
  }

  _draw()

  love.graphics.setCanvas()
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(255, 255, 255, 255)

  -- post_effect:draw(function()

  -- top portait
  love.graphics.draw(
    game_screen_canvas,
    0,
    screen_height,
    deg270,
    screen_height/pixel_screen_height, -- scale x
    screen_height/pixel_screen_height -- scale y
    -- 0, -- Origin offset (x-axis).
    -- 0, -- Origin offset (y-axis).
    -- 0, -- Shearing factor (x-axis).
    -- 0 -- Shearing factor (y-axis).
  ) -- scale y

  -- -- center landscape
  -- love.graphics.draw(
  --   game_screen_canvas,
  --   (screen_width-screen_height)/2, -- x
  --   0, -- y
  --   0, -- radians
  --   -- deg270, -- radians
  --   screen_height/pixel_screen_height, -- scale x
  --   screen_height/pixel_screen_height -- scale y
  --   -- 0, -- Origin offset (x-axis).
  --   -- 0, -- Origin offset (y-axis).
  --   -- 0, -- Shearing factor (x-axis).
  --   -- 0 -- Shearing factor (y-axis).
  -- ) -- scale y

  -- end)

  -- positionx, positiony, rotation, scalex, scaley


  -- -- Observe the difference if the Canvas is drawn with the regular alpha blend mode instead.
  -- love.graphics.setBlendMode("alpha")
  -- love.graphics.draw(canvas, 100, 0)

  -- -- Rectangle is drawn directly to the screen with the regular alpha blend mode.
  -- love.graphics.setBlendMode("alpha")
  -- love.graphics.setColor(255, 255, 0, 128)
  -- love.graphics.rectangle('fill', 200, 0, 100, 100)

  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  buttons:draw()

  color(7)
  love.graphics.setFont(debugfont)

  for i, is_pressed in ipairs(buttons.hold_time) do
    if is_pressed > 0 then
      table.insert(debug_messages, "button "..(i-1).." is pressed for "..is_pressed)
    end
  end

  if #touches > 0 then
    for i, id in ipairs(touches) do
      local x, y = love.touch.getPosition(id)
      add(debug_messages, "touch "..i..": "..x..", "..y)
    end
  end

  for i, message in ipairs(debug_messages) do
    love.graphics.print(
      message,
      i*36+screen_height,
      screen_height-50,
      deg270)
  end

end


function split(s)
  local t,start_index,ti={},2,split_start or 0
  local mode=sub(s,1,1)
  for i=2,#s do
    local c=sub(s,i,i)
    if mode=="x" then
      t[ti]=("0x"..c)+0
      ti = ti + 1
    elseif c=="," then
      local sstr=sub(s,start_index,i-1)
      if mode=="a" then
        if sstr=="nil" then sstr=nil end
        t[ti]=sstr
      else
        t[ti]=sstr+0
      end
      ti = ti + 1
      start_index=i+1
    end
  end
  return t
end

function nsplit(s)
  local t,start_index,ti={},1,split_start or 0
  for i=1,#s do
    if sub(s,i,i)=="|" then
      t[ti]=split(sub(s,start_index,i-1))
      ti = ti + 1
      start_index=i+1
    end
  end
  return t
end

function rotated_angle(len)
  return rotated_vector(random(),len)
end
function rotated_vector(angle,x,y)
  return Vector(x or 1,y):rotate(angle)
end
function round(i)
  return floor(i+.5)
end
function format(num)
  local n=floor(num*10+0.5)/10
  return floor(n).."."..round((n%1)*10)
end

ship={}
ship.__index=ship
function ship.new(h)
  local shp={
    npc=false,
    hostile=h,
    screen_position=screen_center,
    sector_position=Vector(),
    cur_deltav=0,
    cur_gees=0,
    angle=0,
    angle_radians=0,
    heading=90,
    velocity_angle=0,
    velocity_angle_opposite=180,
    velocity=0,
    velocity_vector=Vector(),
    orders={},
    last_fire_time=-6
  }
  setmetatable(shp,ship)
  return shp
end

function ship:buildship(seed,stype)
  self.ship_type_index=stype or random_int(#ship_types)+1

  local seed_value=seed or random_int(32767)
  randomseed(seed_value)
  self.seed_value=seed_value
  self.name=ship_names[self.ship_type_index]
  local shape=ship_types[self.ship_type_index]

  local ship_colors=split"x6789abcdef"
  for i=1,6 do
    del(ship_colors,ship_colors[random_int(#ship_colors)+1])
  end

  local hp=0
  local ship_mask={}
  local rows=random_int(shape[#shape]+1,shape[#shape-1])
  local cols=floor(rows/2)

  for y=1,rows do
    add(ship_mask,{})
    for x=1,cols do
      add(ship_mask[y],ship_colors[4])
    end
  end

  local slopei,slope=2,Vector(1,shape[1])

  for y=2,rows-1 do

    for x=1,cols do

      local color=ship_colors[1+floor((y+random_int(3)-1)/rows*3)]

      if cols-x<max(0,floor(slope.y)) then
        if random()<.6 then
          ship_mask[y][x]=color
          hp = hp + 1
          if ship_mask[y-1][x]==ship_colors[4] then
            ship_mask[y][x]=darkshipcolors[color]
          end
        end
      end

    end

    if y>=floor(shape[slopei+1]*rows) then
      slopei = slopei + 2
    end
    slope=slope+Vector(1,shape[slopei])

    if slope.y>0 and y>3 and y<rows-1 then
      for i=1,random_int(round(slope.y/4)+1) do
        ship_mask[y][cols-i]=5
        hp = hp + 2
      end
    end

  end

  local odd_columns=random_int(2)
  for y=rows,1,-1 do
    for x=cols-odd_columns,1,-1 do
      add(ship_mask[y],ship_mask[y][x])
    end
  end

  if self.ship_type_index==#ship_types then
    hp = hp * 4
  end

  self.hp=hp
  self.max_hp=hp
  self.hp_percent=1
  self.deltav=max(hp*-0.0188+4.5647,1)*0.0326
  local turn_factor=1
  if self.ship_type_index==4 then
    turn_factor = turn_factor * .5
  end
  self.turn_rate=round(turn_factor*max(hp*-0.0470+11.4117,2))
  self.sprite_rows=rows
  self.sprite_columns=#ship_mask[1]
  self.transparent_color=ship_colors[4]
  self.sprite=ship_mask
  return self
end

function ship:set_position_near_object(obj)
  local radius=obj.radius or obj.sprite_rows
  self.sector_position=rotated_angle(1.2*radius)+obj.sector_position
  self:reset_velocity()
end

function ship:clear_target()
  self.target_index=nil
  self.target=nil
end

function ship:targeted_color()
  if self.hostile then
    return 8,2
  else
    return 11,3
  end
end

function ship:draw_sprite_rotated(offscreen_pos,angle)
  if self.dead then return end
  local screen_position=offscreen_pos or self.screen_position
  local a=angle or self.angle_radians
  local rows,cols=self.sprite_rows,self.sprite_columns
  local tcolor=self.transparent_color
  local projectile_hit_by
  local close_projectiles={}

  if self.targeted then
    local targetcircle_radius=round(rows/2)+4
    local circlecolor,circleshadow=self:targeted_color()
    if offscreen_pos then
      (screen_position+Vector(1,1)):draw_circle(targetcircle_radius,circleshadow,true)
      screen_position:draw_circle(targetcircle_radius,0,true)
    end
    screen_position:draw_circle(targetcircle_radius,circlecolor)
  end

  for index, p in ipairs(projectiles) do
    if p.firing_ship~=self then
      if (p.sector_position and offscreen_pos and (self.sector_position-p.sector_position):scaled_length()<=rows) or
      vector_distance(p.screen_position,screen_position)<rows then
        add(close_projectiles,p)
      end
    end
  end

  for y=1,cols do
    for x=1,rows do
      local color=self.sprite[x][y]
      if color~=tcolor and color~=nil then

        local pixel1=Vector(
          rows-x-floor(rows/2),
          y-floor(cols/2)-1)
        local pixel2=Vector(pixel1.x+1,pixel1.y)
        pixel1:rotate(a):add(screen_position):round()
        pixel2:rotate(a):add(screen_position):round()

        if self.hp<1 and random()<.8 then
          make_explosion(pixel1,rows/2,18,self.velocity_vector)
          -- sfx(55,2)
          if not offscreen_pos then
            add(particles,spark.new(pixel1,rotated_angle(random(.25)+.25)+self.velocity_vector,color,128+random_int(32)))
          end

        else

          for index, projectile in ipairs(close_projectiles) do

            local impact=false
            if not offscreen_pos
              and (pixel1:about_equals(projectile.screen_position)
                     or (projectile.position2
                         and pixel1:about_equals(projectile.position2))) then
                impact=true
            elseif offscreen_pos
              and projectile.last_offscreen_pos
            and pixel1:about_equals(projectile.last_offscreen_pos) then
              impact=true
            end

            if impact then
              projectile_hit_by=projectile.firing_ship
              local damage=projectile.damage or 1
              self.hp = self.hp - damage
              if damage>10 then
                make_explosion(pixel1,8,12,self.velocity_vector)
                -- sfx(57,1)
              else
                make_explosion(pixel1,2,6,self.velocity_vector)
                -- sfx(56,2)
              end
              local old_hp_percent=self.hp_percent
              self.hp_percent=self.hp/self.max_hp
              if not self.npc and old_hp_percent>.1 and self.hp_percent<=.1 then
                note_add("thruster malfunction")
              end
              if random()<.5 then
                add(particles,spark.new(pixel1,rotated_angle(random(2)+1)+self.velocity_vector,color,128))
              end
              del(projectiles,projectile)
              self.sprite[x][y]=-5
              color=-5
              break
            end

          end

          if color<0 then color=5 end

          rectfill(
            pixel1.x,pixel1.y,
            pixel2.x,pixel2.y,
            color)
          -- pixel1:draw_line(pixel2, color)

        end

      end
    end
  end

  if projectile_hit_by then
    self.last_hit_time=secondcount
    self.last_hit_attacking_ship=projectile_hit_by
  end
end

function ship:turn_left()
  self:rotate(self.turn_rate)
end

function ship:turn_right()
  self:rotate(-self.turn_rate)
end

function ship:rotate(signed_degrees)
  self.angle=(self.angle+signed_degrees)%360
  self.angle_radians=self.angle/360
  self.heading=(450-self.angle)%360
end

function ship:draw()
  text(self:hp_string(),0,0,self:hp_color())
  local o=nil
  local co=self.orders[#self.orders]
  if co==self.full_stop then
    o="stopping"
  elseif co==self.seek then
    o="following"
  elseif co==self.fly_towards_destination then
    o="flying to nearest planet"
  end
  if o then
    text(o,1,22,12,true)
  end
  if self.last_fire_time+5>=secondcount then
    text("reloading",1,31,10,true)
  end
  text("pixels/sec "..format(10*self.velocity),0,7)
  if self.accelerating then
    text(format(self.cur_gees).." g",0,14)
  end
  -- text((self.angle).." deg", 0,21)
  -- text((self.angle_radians).." rad", 0,28)
  -- text((self.heading).." heading", 0,35)
  -- text((self.velocity_angle).." vel-a", 0,42)
  -- text((self.velocity_angle_opposite).." vel-a-o", 0,49)
  self:draw_sprite_rotated()
end

function ship:hp_color()
  return health_colormap[ceil(10*self.hp_percent)]
end

function ship:hp_string()
  return "hp "..round(100*self.hp_percent).."% "..self.hp.."/"..self.max_hp
end

function ship:data(y)
  rectfill(0,y+34,127,y,0)
  rect(0,y+34,127,y,6)
  self:draw_sprite_rotated(Vector(104,y+17),0)
  text(self.name.."\nmodel "..self.seed_value.."\nmax hull‡ "..self.max_hp.."\nmax thrust "..format(self.deltav*30.593514175).." g\nturn rate  "..self.turn_rate.." deg/sec",3,y+3)
end

function ship:is_visible(player_ship_pos)
  local size=round(self.sprite_rows/2)
  local screen_position=(self.sector_position-player_ship_pos+screen_center):round()
  self.screen_position=screen_position
  return screen_position.x<pixel_screen_width+size and
    screen_position.x>0-size and
    screen_position.y<pixel_screen_height+size and
    screen_position.y>0-size
end

function ship:update_location()
  if self.velocity>0 then
    self.sector_position:add(self.velocity_vector)
  end
end

function ship:reset_velocity()
  self.velocity_vector=Vector()
  self.velocity=0
end

function ship:predict_sector_position()
  if self.velocity>0 then
    return self.sector_position+self.velocity_vector*4
  else
    return self.sector_position
  end
end

function ship:set_destination(dest)
  self.destination=dest.sector_position
  self:update_steering_velocity()
  self.max_distance_to_destination=self.distance_to_destination
end

function ship:flee()
  self:set_destination(self.last_hit_attacking_ship)
  self:update_steering_velocity(1)
  local away_from_enemy=self.steer_vel:angle()
  local toward_enemy=(away_from_enemy+.5) % 1
  if self.distance_to_destination<55 then
    self:rotate_towards_heading(away_from_enemy)
    self:apply_thrust()
  else
    self:full_stop()
    if self.hostile and
      self.angle_radians<toward_enemy+.1 and
    self.angle_radians>toward_enemy-.1 then
      self:fire_weapon()
    end
  end
end

function ship:update_steering_velocity(modifier)
  local desired_velocity=self.sector_position-self.destination
  self.distance_to_destination=desired_velocity:scaled_length()
  self.steer_vel=(desired_velocity-self.velocity_vector)*(modifier or -1)
end

function ship:seek()
  if self.seektime%20==0 then
    self:set_destination(self.target)
  end
  self.seektime = self.seektime + 1

  local target_offset=self.destination-self.sector_position
  local distance=target_offset:scaled_length()
  self.distance_to_destination=distance
  local maxspeed=distance/50
  local ramped_speed=(distance/(self.max_distance_to_destination*.7))*maxspeed
  local clipped_speed=min(ramped_speed,maxspeed)
  local desired_velocity=target_offset*(ramped_speed/distance)
  self.steer_vel=desired_velocity-self.velocity_vector

  if self:rotate_towards_heading(self.steer_vel:angle()) then
    self:apply_thrust(self.steer_vel:scaled_length())
  end
  if self.hostile then
    if distance<128 then
      self:fire_weapon()
      self:fire_missile()
    end
  end
end

function ship:fly_towards_destination()
  self:update_steering_velocity()
  if self.distance_to_destination>self.max_distance_to_destination*.9 then
    if self:rotate_towards_heading(self.steer_vel:angle()) then
      self:apply_thrust()
    end
  else
    self.accelerating=false
    self:reverse_direction()
    if self.distance_to_destination<=self.max_distance_to_destination*.11 then
      self:order_done(self.full_stop)
    end
  end
end

function ship:approach_object(obj)
  local obj=obj or sect.planets[random_int(#sect.planets)+1]
  self:set_destination(obj)
  self:reset_orders(self.fly_towards_destination)
  if self.velocity>0 then
    add(self.orders,self.full_stop)
  end
end

function ship:follow_cur_order()
  local order=self.orders[#self.orders]
  if order then order(self) end
end

function ship:order_done(new_order)
  self.orders[#self.orders]=new_order
end

function ship:reset_orders(new_order)
  self.orders={}
  if new_order then add(self.orders,new_order) end
end

function ship:cut_thrust()
  self.accelerating=false
  self.cur_deltav=0
end

function ship:wait()
  if secondcount>self.wait_duration+self.wait_time then
    self:order_done()
  end
end

function ship:full_stop()
  if self.velocity>0 and self:reverse_direction() then
    self:apply_thrust()
    if self.velocity<1.2*self.deltav then
      self:reset_velocity()
      self:order_done()
    end
  end
end

function ship:fire_missile(weapon)
  if self.target and secondcount>5+self.last_fire_time then
    self.last_fire_time=secondcount
    add(projectiles,missile.new(self,self.target))
    -- self:pilotsfx(54)
  end
end

-- function ship:pilotsfx(n,c)
--   if self==pilot then sfx(n,c or 1) end
-- end

function ship:fire_weapon()
  local hardpoints={1,-1}
  if self.ship_type_index~=2 then hardpoints={0} end
  local rate=3
  if self.npc then rate=5 end
  if framecount%rate==0 then
    for index, y in ipairs(hardpoints) do
      add(projectiles,cannon.new(
            rotated_vector(self.angle_radians,self.sprite_rows/2-1,y*(self.sprite_columns/4))+self.screen_position,
            rotated_vector(self.angle_radians,6)+self.velocity_vector,12,self))
    end
    -- self:pilotsfx(36)
  end
end

function ship:apply_thrust(max_velocity)
  self.accelerating=true
  if self.cur_deltav<self.deltav then
    self.cur_deltav = self.cur_deltav + self.deltav/30
  else
    self.cur_deltav=self.deltav
  end
  local dv=self.cur_deltav
  -- self:pilotsfx(38+floor(12*dv/self.deltav),2)
  if max_velocity and dv>max_velocity then
    dv=max_velocity
  end
  if self.hp_percent<=random(.1) then
    dv=0
  end
  self.cur_gees=dv*30.593514175
  local a=self.angle_radians
  local additional_velocity_vector=Vector(cos(a)*dv,sin(a)*dv)
  local velocity_vector=self.velocity_vector
  local velocity
  local engine_location=rotated_vector(a,self.sprite_rows*-.5)+self.screen_position
  add(particles,thrustexhaust.new(
        engine_location,
        additional_velocity_vector*-1.3*self.sprite_rows))
  velocity_vector:add(additional_velocity_vector)
  velocity=velocity_vector:length()
  self.velocity_angle=velocity_vector:angle()
  self.velocity_angle_opposite=(self.velocity_angle+0.5)%1
  self.velocity=velocity
  self.velocity_vector=velocity_vector
end

function ship:reverse_direction()
  if self.velocity>0 then
    return self:rotate_towards_heading(self.velocity_angle_opposite)
  end
end

function ship:rotate_towards_heading(heading)
  local delta=(heading*360-self.angle+180)%360-180
  if delta~=0 then
    local r=self.turn_rate*delta/abs(delta)
    if abs(delta)>abs(r) then delta=r end
    self:rotate(delta)
  end
  return delta<0.1 and delta>-.1
end

function nearest_planet()
  local planet
  local dist=32767
  for index, p in ipairs(sect.planets) do
    if p.planet_type then
      local d=vector_distance(pilot.sector_position,p.sector_position)
      if d<dist then
        dist=d
        planet=p
      end
    end
  end
  return planet,dist
end

function land_at_nearest_planet()
  local planet,dist=nearest_planet()
  if dist<planet.radius*1.4 then
    if pilot.velocity<.5 then
      -- sect:reset_planet_visibility()
      landed_front_rendered=false
      landed_back_rendered=false
      landed_planet=planet
      landed=true
      landed_menu()
      -- draw_rect(128,128,0)
    else
      note_add("moving too fast to land")
    end
  else
    note_add("too far to land")
  end
  return false
end

function takeoff()
  -- sect:reset_planet_visibility()
  pilot:set_position_near_object(landed_planet)
  landed=false
  return false
end

function clear_targeted_ship_flags()
  for index, ship in ipairs(npcships) do
    ship.targeted=false
  end
end

function next_hostile_target(ship)
  local targeting_ship=ship or pilot
  local hostile
  for i=1,#npcships do
    next_ship_target(ship)
    if targeting_ship.target.hostile then break end
  end
  return true
end

function next_ship_target(ship,random)
  local targeting_ship=ship or pilot
  if random then
    targeting_ship.target_index=random_int(#npcships)+1
  else
    targeting_ship.target_index=(targeting_ship.target_index or #npcships)%#npcships+1
  end
  targeting_ship.target=npcships[targeting_ship.target_index]
  if targeting_ship==targeting_ship.target then
    targeting_ship.target=pilot
  end
  if not ship then
    clear_targeted_ship_flags()
    targeting_ship.target.targeted=true
  end
  return true
end

missile={}
missile.__index=missile
function missile.new(fship,t)
  return setmetatable({
      sector_position=fship.sector_position:clone(),
      screen_position=fship.screen_position:clone(),
      velocity_vector=fship.velocity_vector:clone(),
      velocity=fship.velocity,
      target=t,
      sprite_rows=1,
      firing_ship=fship,
      cur_deltav=.1,
      deltav=.1,
      hp_percent=1,
      duration=512,
      damage=20
                      },missile)
end

function missile:update()
  self.destination=self.target:predict_sector_position()
  self:update_steering_velocity()
  self.angle_radians=self.steer_vel:angle()
  self:apply_thrust(self.steer_vel:scaled_length())
  self.duration = self.duration - 1
  self:update_location()
end

function missile:draw(shipvel,offscreen_pos)
  local screen_position=offscreen_pos or self.screen_position
  self.last_offscreen_pos=offscreen_pos
  if self:is_visible(pilot.sector_position) or offscreen_pos then
    screen_position:draw_line(screen_position+rotated_vector(self.angle_radians,4),6)
  end
end

setmetatable(missile,{__index=ship})

star={}
star.__index=star
function star.new()
  return setmetatable({
      position=Vector(),
      color=7,
      speed=1},star)
end

function star:reset(x,y)
  self.position=Vector(x or random_int(pixel_screen_width),y or random_int(pixel_screen_height))
  self.color=random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
  self.speed=(random(.75)+0.25)
  return self
end

sun={}
sun.__index=sun
function sun.new(radius,x,y)
  local r=radius or 64+random_int(128)
  local c=random_int(6,1)
  return setmetatable({
      screen_position=Vector(),
      radius=r,
      sun_color_index=c,
      color=sun_colors[c+5],
      sector_position=Vector(x or 0,y or 0),
                      },sun)
end

function sun:draw(ship_pos)
  if stellar_object_is_visible(self,ship_pos) then
    for i=0,1 do
      self.screen_position:draw_circle(
        self.radius-i*3,
        sun_colors[i*5+self.sun_color_index],true)
    end
  end
end

function stellar_object_is_visible(obj,ship_pos)
  obj.screen_position=obj.sector_position-ship_pos+screen_center
  return
    obj.screen_position.x<pixel_screen_width+obj.radius and
    obj.screen_position.x>0-obj.radius and
    obj.screen_position.y<pixel_screen_width+obj.radius and
    obj.screen_position.y>0-obj.radius
end

-- starfield_count=40
sector={}
sector.__index=sector
function sector.new()
  local sec={
    seed=random_int(32767),
    planets={},
    starfield={}
  }
  randomseed(sec.seed)
  for i=1,starfield_count do
    add(sec.starfield,star.new():reset())
  end
  setmetatable(sec,sector)
  return sec
end

function sector:reset_planet_visibility()
  for index, p in ipairs(self.planets) do
    p.rendered_circle=false
    p.rendered_terrain=false
  end
end

function sector:new_planet_along_elipse()
  local x,y,sdist
  local planet_nearby=true
  while(planet_nearby) do
    x=random(150)
    y=sqrt((random(35)+40)^2*(1-x^2/(random(50)+100)^2))
    if random()<.5 then x = x * -1 end
    if random()<.75 then y = y * -1 end
    if #self.planets==0 then break end
    sdist=32767
    for index, p in ipairs(self.planets) do
      sdist=min(sdist,
                vector_distance(Vector(x,y),p.sector_position/33))
    end
    planet_nearby=sdist<15
  end
  return planet.new(x*33,y*33,((1-Vector(x,y):angle())-.25)%1)
end

function sector:draw_starfield(shipvel)
  local lstart, lend
  for index,star in ipairs(self.starfield) do
    lstart=star.position+(shipvel*star.speed*-.5)
    lend=star.position+(shipvel*star.speed*.5)
    local i=star_color_monochrome+star_color_index+1
    local star_color_count=#star_colors[i]
    local color_index=1+((star.color-1)%star_color_count)
    -- debug.debug()
    -- print(lstart.x..","..lstart.y.." - "..star.position.x..","..star.position.y.." - "..lend.x..","..lend.y.."\n")
    star.position:draw_line(
      lend,
      star_colors[i+1][color_index])
    lstart:draw_line(
      star.position,
      star_colors[i][color_index])
  end
end

function sector:scroll_starfield(shipvel)
  local diff=starfield_count-#self.starfield
  for i=1,diff do
    add(self.starfield,star.new():reset())
  end
  local margin = 12
  local width, height = pixel_screen_width, pixel_screen_height
  for index,star in ipairs(self.starfield) do
    star.position:add(shipvel*star.speed*-1)
    if diff<0 then
      del(self.starfield,star)
      diff = diff + 1
    elseif star.position.x > width + margin then
      star:reset(-margin)
    elseif star.position.x < -margin then
      star:reset(width + margin)
    elseif star.position.y > height + margin then
      star:reset(false,-margin)
    elseif star.position.y < -margin then
      star:reset(false,height + margin)
    end
  end
end

function is_offscreen(p,m)
  local margin=m or 0
  local mincoord=0-margin
  local maxcoord=pixel_screen_width+margin
  local x,y=p.screen_position.x,p.screen_position.y
  local duration_up=p.duration<0
  if p.deltav then
    return duration_up
  else
    return duration_up or x>maxcoord or x<mincoord or y>maxcoord or y<mincoord
  end
end

spark={}
spark.__index=spark
function spark.new(p,pv,c,d)
  return setmetatable({
      screen_position=p,
      particle_velocity=pv,
      color=c,
      duration=d or random_int(7,2)
                      },spark)
end

function spark:update(shipvel)
  self.screen_position:add(self.particle_velocity-shipvel)
  self.duration = self.duration - 1
end

function spark:draw(shipvel)
  self.screen_position:draw_point(self.color)
  self:update(shipvel)
end

function make_explosion(pixel1,size,colorcount,center_velocity)
  add(particles,explosion.new(
        pixel1,size,colorcount,
        center_velocity))
end

explosion={}
explosion.__index=explosion
function explosion.new(position,size,colorcount,shipvel)
  local explosion_size_factor=random()
  return setmetatable({
      screen_position=position:clone(),
      particle_velocity=shipvel:clone(),
      radius=explosion_size_factor*size,
      radius_delta=explosion_size_factor*random(.5),
      len=colorcount-3,
      duration=colorcount
                      },explosion)
end

function explosion:draw(shipvel)
  local r=round(self.radius)
  for i=r+3,r,-1 do
    local c=damage_colors[self.len-self.duration+i]
    if c then
      self.screen_position:draw_circle(i,c,true)
    end
  end
  self:update(shipvel)
  self.radius = self.radius - self.radius_delta
end

setmetatable(explosion,{__index=spark})

cannon={}
cannon.__index=cannon
function cannon.new(p,pv,c,ship)
  return setmetatable({
      screen_position=p,
      position2=p:clone(),
      particle_velocity=pv+pv:perpendicular():normalize()*(random(2)-1),
      color=c,
      firing_ship=ship,
      duration=16
                      },cannon)
end

function cannon:update(shipvel)
  self.position2=self.screen_position:clone()
  self.screen_position:add(self.particle_velocity-shipvel)
  self.duration = self.duration - 1
end
function cannon:draw(shipvel)
  self.position2:draw_line(self.screen_position,self.color)
end

thrustexhaust={}
thrustexhaust.__index=thrustexhaust
function thrustexhaust.new(p,pv)
  return setmetatable({
      screen_position=p,
      particle_velocity=pv,
      duration=0
                      },thrustexhaust)
end

function thrustexhaust:draw(shipvel)
  local c,pv=random_int(11,9),self.particle_velocity
  local deflection,flicker=pv:perpendicular()*0.7,pv*(random(2)+2)
  flicker = flicker + deflection*(random()-.5)
  local p0,p1a=self.screen_position+flicker,self.screen_position+pv
  for index, a in ipairs{p1a+deflection,p1a+deflection*-1} do
    for index, b in ipairs{p0,self.screen_position} do
      a:draw_line(b,c)
    end
  end
  if random()>.4 then
    add(particles,spark.new(p0,shipvel+(flicker*.25),c))
  end
  self.screen_position:add(pv-shipvel)
  self.duration = self.duration - 1
end

function draw_rect(w,h,c)
  rectfill(0,0,w,h,c)
end

function draw_sprite_circle(xc,yc,radius,filled,c)
  local xvalues={}
  local fx,fy=0,0
  local x,y=-radius,0
  local err=2-2*radius
  color(c)
  while(x<0) do
    xvalues[1+x*-1]=y

    if not filled then
      fx,fy=x,y
    end
    for i=x,fx do
      sset(xc-i,yc+y)
      sset(xc+i,yc-y)
    end
    for i=fy,y do
      sset(xc-i,yc-x)
      sset(xc+i,yc+x)
    end

    radius=err
    if radius<=y then
      y = y + 1
      err = err + y*2+1
    end
    if radius>x or err>y then
      x = x + 1
      err = err + x*2+1
    end
  end
  xvalues[1]=xvalues[2]
  return xvalues
end

perms={}
for i=0,255 do perms[i]=i end
for i=0,255 do
  local r=random_int(32767)%256
  perms[i],perms[r]=perms[r],perms[i]
end

perms12={}
for i=0,255 do
  local x=perms[i]%12
  perms[i+256],perms12[i],perms12[i+256]=perms[i],x,x
end

function getn_3d(ix,iy,iz,x,y,z)
  local t=.6-x*x-y*y-z*z
  local index=perms12[ix+perms[iy+perms[iz]]]
  return max(0,(t*t)*(t*t))*(grads3[index][0]*x+grads3[index][1]*y+grads3[index][2]*z)
end

function simplex3d(x,y,z)
  local s=(x+y+z)*0.333333333
  local ix,iy,iz=floor(x+s),floor(y+s),floor(z+s)
  local t=(ix+iy+iz)*0.166666667
  local x0,y0,z0=x+t-ix,y+t-iy,z+t-iz
  ix,iy,iz=band(ix,255),band(iy,255),band(iz,255)
  local n0=getn_3d(ix,iy,iz,x0,y0,z0)
  local n3=getn_3d(ix+1,iy+1,iz+1,x0-0.5,y0-0.5,z0-0.5)
  local ijk
  if x0>=y0 then
    if y0>=z0 then
      ijk=ijks[1]
    elseif x0>=z0 then
      ijk=ijks[2]
    else
      ijk=ijks[3]
    end
  else
    if y0<z0 then
      ijk=ijks[4]
    elseif x0<z0 then
      ijk=ijks[5]
    else
      ijk=ijks[6]
    end
  end
  local n1=getn_3d(ix+ijk[1],iy+ijk[2],iz+ijk[3],x0+0.166666667-ijk[1],y0+0.166666667-ijk[2],z0+0.166666667-ijk[3])
  local n2=getn_3d(ix+ijk[4],iy+ijk[5],iz+ijk[6],x0+0.333333333-ijk[4],y0+0.333333333-ijk[5],z0+0.333333333-ijk[6])
  return 32*(n0+n1+n2+n3)
end

function new_planet(a)
  local p=nsplit(a)
  local args=p[2]
  return{
    class_name=p[1][1],
    noise_octaves=args[1],
    noise_zoom=args[2],
    noise_persistance=args[3],
    mmap_color=args[4],
    full_shadow=args[5] or 1,
    transparent_color=args[6] or 14,
    minc=args[7] or 1,
    maxc=args[8] or 1,
    min_size=args[9] or 16,
    color_map=p[3]
}end

planet={}
planet.__index=planet
function planet.new(x,y,phase,r)
  local planet_type=planet_types[random_int(#planet_types)+1]

  local radius=r or random_int(130,planet_type.min_size)
  local planet_canvas = love.graphics.newCanvas(radius*2+1, radius*2+1)
  planet_canvas:setFilter("nearest", "nearest")
  return setmetatable({
      planet_canvas=planet_canvas,
      screen_position=Vector(),
      radius=radius,
      sector_position=Vector(x,y),
      bottom_right_coord=2*radius-1,
      phase=phase,
      planet_type=planet_type,
      noise_factor_vert=random_int(planet_type.maxc+1,planet_type.minc),
      noisedx=random(1024),
      noisedy=random(1024),
      noisedz=random(1024),
      rendered_circle=false,
      rendered_terrain=false,
      color=planet_type.mmap_color},planet)
end

function planet:draw(ship_pos)
  if stellar_object_is_visible(self,ship_pos) then
    -- self.screen_position:draw_circle(
    --   self.radius,
    --   self.color,true)

    self:render_planet()

    -- sspr(
    --   0,0,self.bottom_right_coord,self.bottom_right_coord,
    --   self.screen_position.x-self.radius,
    --   self.screen_position.y-self.radius)

    love.graphics.draw(
      self.planet_canvas,
      self.screen_position.x-self.radius,
      self.screen_position.y-self.radius
      -- deg270,
      -- screen_height/pixel_screen_height, -- scale x
      -- screen_height/pixel_screen_height -- scale y
      -- 0, -- Origin offset (x-axis).
      -- 0, -- Origin offset (y-axis).
      -- 0, -- Shearing factor (x-axis).
      -- 0 -- Shearing factor (y-axis).
    )

  end
end

function planet:render_planet(fullmap,renderback)
  local radius=self.radius-1
  if fullmap then radius=47 end

  love.graphics.setCanvas(self.planet_canvas)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  if not self.rendered_circle then
    self.width=self.radius*2
    self.height=self.radius*2
    self.x=0
    self.yfromzero=0
    self.y=radius-self.yfromzero
    self.phi=0
    -- sect:reset_planet_visibility()
    -- pal()
    -- palt(0,false)
    -- palt(self.planet_type.transparent_color,true)
    love.graphics.clear()
    if fullmap then
      self.width,self.height=114,96
    else
      self.xvalues=draw_sprite_circle(radius,radius,radius,true,0)
      draw_sprite_circle(radius,radius,radius,false,self.planet_type.mmap_color)
    end
    self.rendered_circle=true
  end

  local m = ""
  for i, x in ipairs(self.xvalues) do
    m = m..x..", "
  end

  table.insert(debug_messages, m)

  if (not self.rendered_terrain) and self.rendered_circle then

    local theta_start,theta_end=0,.5
    local theta_increment=theta_end/self.width
    if fullmap and renderback then
      theta_start=.5
      theta_end=1
    end

    if self.phi>.25 then
      self.rendered_terrain=true
    else

      local partialshadow=self.planet_type.full_shadow~=1
      local phase_values,phase={},self.phase

      local x,doublex,x1,x2,i,c1,c2
      local y=radius-self.y
      local xvalueindex=abs(y)+1
      if xvalueindex<=#self.xvalues then
        x=floor(sqrt(radius*radius-y*y))
        doublex=2*x
        if phase<.5 then
          x1=-self.xvalues[xvalueindex]
          x2=floor(doublex-2*phase*doublex-x)
        else
          x1=floor(x-2*phase*doublex+doublex)
          x2=self.xvalues[xvalueindex]
        end
        for i=x1,x2 do
          if partialshadow
            or (phase<.5 and i>x2-2)
          or (phase>=.5 and i<x1+2) then
            phase_values[radius+i] = 1
          else
            phase_values[radius+i] = 0
          end
        end
      end

      for theta=theta_start,theta_end-theta_increment,theta_increment do

        local phasevalue=phase_values[self.x]
        local c=0

        -- if fullmap or phasevalue==1 then
        if fullmap or
          phasevalue ~= 0
        then
          -- and sget(self.x,self.y)~=self.planet_type.transparent_color then
          local freq=self.planet_type.noise_zoom
          local max_amp=0
          local amp=1
          local value=0
          for n=1,self.planet_type.noise_octaves do
            -- value=value+love.math.noise(
            value=value+simplex3d(
              self.noisedx+freq*cos(self.phi)*cos(theta),
              self.noisedy+freq*cos(self.phi)*sin(theta),
              self.noisedz+freq*sin(self.phi)*self.noise_factor_vert)
            max_amp = max_amp + amp
            amp = amp * self.planet_type.noise_persistance
            freq = freq * 2
          end
          value = value / max_amp
          if value>1 then value=1 end
          if value<-1 then value=-1 end
          value = value + 1
          value = value * (#self.planet_type.color_map-1)/2
          value=round(value)

          c=self.planet_type.color_map[value+1]
          if not fullmap and phasevalue==1 then
            c=dark_planet_colors[c+1]
          end
        end
        color(c)
        sset(self.x,self.y)
        self.x = self.x + 1
      end
      self.x=0
      if self.phi>=0 then
        self.yfromzero = self.yfromzero + 1
        self.y=radius+self.yfromzero
        self.phi = self.phi + .5/(self.height-1)
      else
        self.y=radius-self.yfromzero
      end
      self.phi = self.phi * -1
    end

  end

  love.graphics.setCanvas(game_screen_canvas)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, 255)

  return self.rendered_terrain
end

function add_npc(pos,pirate)
  local t=random_int(#ship_types)+1
  if pirate or random()<.2 then
    t=random_int(3,1)
    pirate=true
    pirates = pirates + 1
  end
  local npc=ship.new(pirate):buildship(nil,t)
  npc:set_position_near_object(pos)
  npc:rotate(random_int(360))
  npc.npc=true
  add(npcships,npc)
  npc.index=#npcships
end

function load_sector()
  warpsize=pilot.sprite_rows
  sect=sector.new()
  note_add("arriving in system ngc "..sect.seed)
  add(sect.planets,sun.new())
  for i=0,random_int(12,1) do
    add(sect.planets,sect:new_planet_along_elipse())
  end
  pilot:set_position_near_object(sect.planets[2])
  pilot:clear_target()
  pirates=0
  npcships={}
  shipyard={}
  projectiles={}
  for index, p in ipairs(sect.planets) do
    for i=1,random_int(4) do
      add_npc(p)
    end
  end
  if pirates==0 then
    add_npc(sect.planets[2],true)
  end
  return true
end

function _init()
  grads3=nsplit"n1,1,0,|n-1,1,0,|n1,-1,0,|n-1,-1,0,|n1,0,1,|n-1,0,1,|n1,0,-1,|n-1,0,-1,|n0,1,1,|n0,-1,1,|n0,1,-1,|n0,-1,-1,|"
  mmap_sizes=split"n24,48,128,0,"
  mmap_sizes = {floor(pixel_screen_width*.375), pixel_screen_width, 0}
  mmap_sizes[0] = floor(pixel_screen_width*.1875)
  music_tracks=split"n13,0,-1,"
  mousemodes=split"agamepad,two button mouse,stylus (pocketchip),"
  framecount,secondcount,mousemode,mmap_size_index,music_track=0,0,0,0,0
  split_start=1
  btnv=split"x2031"
  ijks=nsplit"n1,0,0,1,1,0,|n1,0,0,1,0,1,|n0,0,1,1,0,1,|n0,0,1,0,1,1,|n0,1,0,0,1,1,|n0,1,0,1,1,0,|"
  outlinedindex=split"n2,2,1,2,0,2,2,0,2,1,1,1,-1,-1,1,-1,-1,1,-1,0,1,0,0,-1,0,1,"
  star_color_index=0
  star_color_monochrome=0
  star_colors=nsplit"xaecd76|x98d165|x421051|x767676|x656565|x515151|"
  -- star_colors={{0xa,0xe,0xc,0xd,0x7,0x6},{0x9,0x8,0xd,0x1,0x6,0x5},{0x4,0x2,0x1,0x0,0x5,0x1},{0x7,0x6,0x7,0x6,0x7,0x6},{0x6,0x5,0x6,0x5,0x6,0x5},{0x5,0x1,0x5,0x1,0x5,0x1}}
  darkshipcolors=split"x01221562493d189"
  dark_planet_colors=split"x0011055545531121"
  health_colormap=split"x8899aaabbb"
  damage_colors=split"x7a98507a98507a9850"
  sun_colors=split"x6ea9d789ac"
  ship_names=split"afighter,cruiser,freighter,superfreighter,station,"
  ship_types=nsplit"n1.5,.25,.7,.75,.8,-2,1,14,18,|n3.5,.5,.583333,0,.8125,-1,1,18,24,|n3,2,.2125,0,.8125,-3,1,16,22,|n6,0,.7,-.25,.85,.25,1,32,45,|n4,1,.1667,-1,.3334,0,.6668,1,.8335,-1,1,30,40,|"
  planet_types={
    new_planet("atundra,|n5,.5,.6,6,|x76545676543|"),
    new_planet("adesert,|n5,.35,.3,9,|x449944994499b1949949949949949|"),
    new_planet("abarren,|n5,.55,.35,5,|x565056765056|"),
    new_planet("alava,|n5,.55,.65,4,|x040504049840405040|"),
    new_planet("agas giant,|n1,.4,.75,2,1,14,4,20,50,|x76d121c|"),
    new_planet("agas giant,|n1,.4,.75,8,1,12,4,20,50,|x7fe21288|"),
    new_planet("agas giant,|n1,.7,.75,10,1,14,4,20,50,|xfa949a|"),
    new_planet("aterran,|n5,.3,.65,11,0,|x1111111dcfbb3334567|"),
    new_planet("aisland,|n5,.55,.65,12,0,|x11111111dcfb3|"),
    new_planet("arainbow giant,|n1,.7,.75,15,1,4,4,20,50,|x1dcba9e82|"),
  }

  -- poke(0x5f2d,1)
  note_text=nil
  note_display_time=4
  paused=false
  landed=false
  particles={}
  pilot=ship.new()
  pilot.npc = true
  pilot:buildship(nil,2)
  load_sector()
  setup_mmap()
  -- music(13)
  -- local titlestarv=Vector(0,-3)
  titlestarv=Vector(3,-7)

  -- while(not btnp(4)) do
  --   cls()
  --   sect:scroll_starfield(titlestarv)
  --   sect:draw_starfield(titlestarv)
  --   circfill(64,135,90,2)
  --   circfill(64,172,122,0)
  --   map(0,0,6,-15)
  --   map(16,0,0,70)
  --   flip()
  -- end
end

function setup_mmap()
  mmap_size=mmap_sizes[mmap_size_index]
  if mmap_size>0 then
    mmap_size_halved=mmap_size/2
    mmap_offset=Vector(pixel_screen_width-2-mmap_size_halved,mmap_size_halved+1)
  end
end

function draw_mmap_ship(obj)
  if obj.deltav then
    local p=(obj.sector_position/mmap_denominator):add(mmap_offset):round()
    local x,y=p.x,p.y
    local c=obj:targeted_color()
    if obj.npc then
      p:draw_point(c)
      if obj.targeted then
        p:draw_circle(2,c)
      end
    else
      if obj.damage then
        p:draw_circle(1,9)
      else
        rect(x-1,y-1,x+1,y+1,7)
      end
    end
  end
end

function draw_mmap()
  local text_height=mmap_size
  if mmap_size>0 then
    if mmap_size<100 then
      text_height = text_height + 4
      rectfill(pixel_screen_width-3-mmap_size,0,pixel_screen_width-1,mmap_size+2,1)
    else
      text_height=0
    end

    local x,y=abs(pilot.sector_position.x),abs(pilot.sector_position.y)
    if y>x then x=y end
    mmap_denominator=min(6,ceil(x/5000))*5000/mmap_size_halved
    for index, obj in ipairs(sect.planets) do
      local p=obj.sector_position+screen_center
      if obj.planet_type then p:add(Vector(-obj.radius,-obj.radius)) end
      p=p/mmap_denominator+mmap_offset
      if mmap_size>100 then
        p:draw_circle(ceil(obj.radius/32)+1,obj.color)
      else
        p:draw_point(obj.color)
      end
    end

    if framecount%3~=0 then
      for index, p in ipairs(projectiles) do
        draw_mmap_ship(p)
      end

      for index, s in ipairs(npcships) do
        draw_mmap_ship(s)
      end

      draw_mmap_ship(pilot)
    end

  end
  text("s "..#npcships-pirates,pixel_screen_width-16,text_height)
  text("s "..pirates,pixel_screen_width-16,text_height+7,8)
end

function text(text,x,y,textcolor,outline)
  local c=textcolor or 6
  local s=darkshipcolors[c]
  if outline then
    for i=1,#outlinedindex,2 do
      if i>10 then s=c end
      color(s)
      love.graphics.print(text,
                          x+outlinedindex[i],
                          y+outlinedindex[i+1]+1)
    end
    c=0
  else
    color(s)
    love.graphics.print(text,x+1,y+1+1)
  end
  color(c)
  love.graphics.print(text,x,y+1)
end

function note_add(text)
  note_text=text
  note_display_time=4
end

function note_draw()
  if note_display_time>0 then
    text(note_text,0,pixel_screen_height-7)
    if framecount>=29 then
      note_display_time = note_display_time - 1
    end
  end
end

function myship_menu()
  showyard=false
  shipinfo=true
  menu("x6b66|aback,repair,|",
       {landed_menu,
        function()
          pilot:buildship(pilot.seed_value,pilot.ship_type_index)
          note_add("hull damage repaired")
        end
  })
end

function addyardships()
  shipyard={}
  for i=1,2 do
    add(shipyard,ship.new():buildship(nil,random_int(#ship_types,1)))
  end
end

function buyship(i)
  pilot:buildship(shipyard[i].seed_value,shipyard[i].ship_type_index)
  shipyard[i]=nil
  note_add("purchased!")
  myship_menu()
end

function call_option(i)
  if cur_option_callbacks[i] then
    local return_value=cur_option_callbacks[i]()
    paused=false
    if return_value==nil then
      paused=true
    elseif return_value then
      if type(return_value)=="string" then
        note_add(return_value)
      end
      paused=true
    end
  end
  if paused then
    -- sfx(53,2)
  else
    -- sfx(52,2)
  end
end

function menu(coptions,callbacks)
  if coptions then
    local c=nsplit(coptions)
    cur_menu_colors=c[1]
    cur_options=c[2]
    cur_option_callbacks=callbacks
  end

  if shipinfo then
    pilot:data(0)
  elseif showyard then
    for i=0,1 do
      local s=shipyard[i+1]
      if s then s:data(i*36) end
    end
  end

  for a=.25,1,.25 do
    local i=a*4
    local text_color=cur_menu_colors[i]
    if i==pressed then text_color=darkshipcolors[text_color] end
    if cur_options[i] then
      local p=rotated_vector(a,15)+Vector(64,90)
      if a==.5 then
        p.x = p.x - 4*#cur_options[i]
      elseif a~=1 then
        p.x = p.x - round(4*(#cur_options[i]/2))
      end
      text(
        cur_options[i],
        p.x,p.y,text_color,true)
    end
  end

  text("  ^  \n<  >\n  v",52,84,6,true)
end

function main_menu()
  menu("xc8b7|aautopilot,fire missile,options,system,|",
       {
         function()
           menu("xcc6c|afull stop,near planet,back,follow,|",
                {
                  function()
                    if pilot.velocity>0 then
                      pilot:reset_orders(pilot.full_stop)
                    end
                    return false
                  end,
                  function()
                    local planet,dist=nearest_planet()
                    pilot:approach_object(planet)
                    return false
                  end,
                  main_menu,
                  function()
                    if pilot.target then
                      pilot:reset_orders(pilot.seek)
                      pilot.seektime=0
                    end
                    return false
                  end,
           })
         end,

         function()
           pilot:fire_missile()
           return false
         end,

         function()
           menu("x6fba|aback,starfield,minimap size,mouse,|",
                {
                  main_menu,

                  function()
                    menu("x7f6a|amore stars,~dimming,less stars,~colors,|",
                         {
                           function()
                             starfield_count = starfield_count + 5
                             return "star count: "..starfield_count
                           end,
                           function()
                             star_color_index = star_color_index + 1
                             star_color_index = star_color_index % 2
                             return true
                           end,
                           function()
                             starfield_count=max(0,starfield_count-5)
                             return "star count: "..starfield_count
                           end,
                           function()
                             star_color_monochrome = star_color_monochrome + 1
                             star_color_monochrome = star_color_monochrome % 2
                             star_color_monochrome = star_color_monochrome * 3
                             return true
                           end
                    })
                  end,

                  function()
                    mmap_size_index = mmap_size_index + 1
                    mmap_size_index = mmap_size_index % #mmap_sizes
                    setup_mmap()
                    return true
                  end,

                  function()
                    menu("xc698|acontrol mode,back,music,|",
                         {
                           function()
                             mousemode = mousemode + 1
                             mousemode = mousemode % 3
                             note_add(mousemodes[mousemode])
                           end,
                           main_menu,
                           function()
                             music_track = music_track + 1
                             music_track = music_track % 3
                             music(music_tracks[music_track])
                           end
                    })
                  end
           })
         end,

         function()
           menu("x86cb|atarget next pirate,back,land,target next,|",
                {
                  next_hostile_target,
                  main_menu,
                  land_at_nearest_planet,
                  next_ship_target
           })
         end
  })
end

function landed_menu()
  shipinfo=false
  showyard=false
  menu("xc67a|atakeoff,nil,my ship,shipyard,|",
       {
         takeoff,
         nil,
         myship_menu,
         function()
           showyard=true
           if #shipyard==0 then addyardships() end
           menu("x767a|abuy top,back,buy bottom,more,|",
                {
                  function()
                    buyship(1)
                  end,
                  landed_menu,
                  function()
                    buyship(2)
                  end,
                  addyardships
           })
         end
  })
end

-- pos=0
-- mtbl={}
-- for i=1,96 do
--   mtbl[i]={floor(-sqrt(-sin(i/193))*48+64)}
--   mtbl[i][2]=(64-mtbl[i][1])*2
-- end
-- for i=0,95 do
--   poke(64*i+56,peek(64*i+0x1800))
-- end
-- cs={}
-- for i=0,15 do
--   cs[i]={(cos(0.5+0.5/16*i)+1)/2}
--   cs[i][2]=(cos(0.5+0.5/16*(i+1))+1)/2-cs[i][1]
-- end

-- function shift_sprite_sheet()
--   for i=0,95 do
--     poke(64*i+0x1838,peek(64*i))
--     memcpy(64*i,64*i+1,56)
--     memcpy(64*i+0x1800,64*i+0x1801,56)
--     poke(64*i+56,peek(64*i+0x1800))
--   end
-- end

function landed_update()
  local p=landed_planet
  if not landed_front_rendered then
    landed_front_rendered=p:render_planet(true)
    if landed_front_rendered then
      p.rendered_circle=false
      p.rendered_terrain=false
      -- for j=1,56 do
      --   shift_sprite_sheet()
      -- end
    end
  else
    if not landed_back_rendered then
      landed_back_rendered=p:render_planet(true,true)
    else
      pos=1-pos
      if pos==0 then
        -- shift_sprite_sheet()
      end
    end
  end
end

function render_landed_screen()
  -- cls()
  if landed_front_rendered and landed_back_rendered then
    for i=1,96 do
      local a,b=mtbl[i][1],mtbl[i][2]
      pal()
      local lw=ceil(b*cs[15][2])
      for j=15,0,-1 do
        if j==4 then
          for ci=0,#dark_planet_colors-1 do
            pal(ci,dark_planet_colors[ci+1])
          end
        end
        if j<15 then lw=floor(a+b*cs[j+1][1])-floor(a+b*cs[j][1]) end
        sspr(pos+j*7,i-1,7,1,floor(a+b*cs[j][1]),i+16,lw,1)
      end
    end
    pal()
    text(landed_planet.planet_type.class_name,1,1)
  else
    sspr(0,0,127,127,0,0)
    text("scanning for a\nsuitable landing site...",1,1,6)
  end
end

function _update()
  framecount = framecount + 1
  framecount = framecount % 30
  if framecount==0 then
    secondcount = secondcount + 1
  end

  mbtn=stat(34)
  local m=Vector(stat(32),stat(33))
  mv=m-screen_center

  if not landed and btnp(4,0) then
    paused=not paused
    if paused then
      -- sfx(51,2)
      main_menu()
    else
      -- sfx(52,2)
    end
    pressed=nil
  end

  if landed then
    landed_update()
  end

  if paused or landed then

    mi=m-Vector(64,90)
    mi.x = mi.x * .4
    mi=mi:angle()-.375
    mi=floor(4*mi)+1
    mi = mi % 4

    for i=1,4 do
      if btn(btnv[i]) or (mousemode>0 and mbtn==1 and i==mi+1 and secondcount>msel) then
        pressed=i
      end
      if pressed then
        if pressed==i and not btn(btnv[i]) then
          pressed=nil
          msel=secondcount
          call_option(i)
        end
      end
    end

  else
    -- pilot:apply_thrust()
    -- pilot:turn_left()

    local no_orders=not pilot.orders[1]
    if no_orders and (mousemode==1 or (mousemode==2 and mbtn>0)) then
      pilot:rotate_towards_heading(mv:angle())
    end

    if (mousemode==1 and mbtn>1)
      or (mousemode==2 and mbtn>0 and mv:length()>38)
    or btn(2,0) then
      pilot:apply_thrust()
    else
      if pilot.accelerating and no_orders then
        pilot:cut_thrust()
      end
    end

    if btn(0,0) then pilot:turn_left() end
    if btn(1,0) then pilot:turn_right() end
    if btn(3,0) then pilot:reverse_direction() end
    if btn(5,0)
    or (mousemode==1 and mbtn==1 or mbtn==3) then pilot:fire_weapon() end

    for index, p in ipairs(projectiles) do
      p:update(pilot.velocity_vector)
    end

    for index, s in ipairs(npcships) do
      if s.ship_type_index==#ship_types then
        s:rotate(.1)
      else

        if s.last_hit_time and s.last_hit_time+30>secondcount then

          s:reset_orders()
          s:flee()
          if s.hostile then
            s.target=s.last_hit_attacking_ship
            s.target_index=s.target.index
          end

        else

          if #s.orders==0 then
            if s.hostile then
              s.seektime=0
              if not s.target then
                next_ship_target(s,true)
              end
              add(s.orders,s.seek)
            else
              s:approach_object()
              s.wait_duration=random_int(46,10)
              s.wait_time=secondcount
              add(s.orders,s.wait)
            end
          end
          s:follow_cur_order()

        end

      end

      s:update_location()
      if s.hp<1 then

        if s.hostile then
          pirates = pirates - 1
          if pirates<1 then
            note_add("sector cleared!")
            note_display_time=8
          end
        end

        del(npcships,s)
        pilot:clear_target()
      end
    end

    pilot:follow_cur_order()
    pilot:update_location()
    if pirates<1 and note_display_time<=0 then
      note_add("fly to system edge for ftl jump")
      note_display_time=8
    end
    if pilot.sector_position.x>32000 or pilot.sector_position.y>32000 then
      load_sector()
    end

    sect:scroll_starfield(pilot.velocity_vector)
  end
end

function render_game_screen()
  cls()
  sect:draw_starfield(pilot.velocity_vector)
  for index, p in ipairs(sect.planets) do
    p:draw(pilot.sector_position)
  end
  for index, s in ipairs(npcships) do
    if s:is_visible(pilot.sector_position) then
      s:draw_sprite_rotated()
    end
  end

  if pilot.target then
    last_offscreen_pos=nil
    local player_screen_position=pilot.screen_position
    local targeted_ship=pilot.target
    if targeted_ship then
      if not targeted_ship:is_visible(pilot.sector_position) then
        local distance=""..floor((targeted_ship.screen_position-player_screen_position):scaled_length())
        local color,shadow=targeted_ship:targeted_color()
        local hull_radius=floor(targeted_ship.sprite_rows*.5)
        local d=rotated_vector((targeted_ship.screen_position-player_screen_position):angle())
        local draw_dist_from_center = floor(pixel_screen_width/2-8)
        last_offscreen_pos=d*(draw_dist_from_center-hull_radius)+screen_center
        local p2=last_offscreen_pos:clone():add(Vector(-4*(#distance/2)))
        targeted_ship:draw_sprite_rotated(last_offscreen_pos)
        if p2.y>floor(pixel_screen_width/2-1) then
          p2:add(Vector(1,-12-hull_radius))
        else
          p2:add(Vector(1,7+hull_radius))
        end
        text(distance,round(p2.x),round(p2.y),color)
      end
      text(targeted_ship.name..targeted_ship:hp_string(),0,pixel_screen_height-14,targeted_ship:hp_color())
    end
  end

  pilot:draw()

  if pilot.hp<1 then
    paused=true
    pilot.dead=true
    menu("x78bb|acontinue?,nil,yes,|",
         {
           nil,
           nil,
           function()
             pilot.dead=false
             pilot:buildship(pilot.seed_value,pilot.ship_type_index)
             return false
           end
    })
  end

  for index, p in ipairs(particles) do
    if is_offscreen(p,32) then
      del(particles,p)
    else
      if paused then
        p:draw(Vector())
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  for index, p in ipairs(projectiles) do
    if is_offscreen(p,63) then
      del(projectiles,p)
    else
      if last_offscreen_pos and p.sector_position and pilot.target and
      (pilot.target.sector_position-p.sector_position):scaled_length()<=pilot.target.sprite_rows then
        p:draw(nil,(p.sector_position-pilot.target.sector_position)+last_offscreen_pos)
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  draw_mmap()
  if warpsize>0 then
    -- camera(random_int(2)-1, random_int(2)-1)
    circfill(63,63,warpsize,7)
    warpsize = warpsize - 1
    -- if warpsize==0 then camera() end
  end

end

function _draw()
  if landed then
    render_landed_screen()
  else
    render_game_screen()
  end
  if paused or landed then
    menu()
  end
  note_draw()
  if mousemode>0 then
    (mv+screen_center):draw_circle(1,8)
  end
end
