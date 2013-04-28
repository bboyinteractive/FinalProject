local lg, lm, lt = love.graphics, love.mouse, love.timer
local pi, sin, cos = math.pi, math.sin, math.cos

local Grid   = require 'grid'
local Snake  = require 'snake'
local Socket = require 'socket'
local Timer  = require 'lib.timer'
local Utils  = require 'utils'

local time, grid, px, canvases, snakes
local udp
local address, port = 'localhost', 9000

local flex1, flex2, accel, pressure = 0, 0, 0, 0

local SCALES = {
  flex1 = { 500, 700 },
  flex2 = { 500, 700 },
  accel = { 0, 230 },
}

function love.load()
  udp = Socket.udp()
  udp:settimeout(0)
  local err, msg = udp:setsockname(address, port)
  assert(err, msg)

  lg.setBackgroundColor(25, 25, 25)

  time = 0
  grid = Grid(24, 37, 15)

  if lg.isSupported('pixeleffect') then
    px = {
      externs = {
        exposure = 0.3,
        decay = 0.95,
        density = 0.7,
        weight = 0.29,
        samples = 70,
        light = { 0, 0 },
      },
      effect = Utils.createEffect('effects/light.glsl'),
    }
  end

  canvases = {
    bg = lg.newCanvas(),
    rays = lg.newCanvas(lg.getWidth() / 2, lg.getHeight() / 2),
  }

  snakes = {
    Snake(grid, 1, 1, { Utils.HSLtoRGB(41, 89, 66) }),
    Snake(grid, grid:rows(), grid:columns(), { Utils.HSLtoRGB(235, 71, 62) }),
    --Snake(grid, 1, grid:columns(), { 0, 0, 255 }),
  }
end

local function pollUDP()
  local data, msg
  repeat
    data, msg, address, port = udp:receivefrom()
    if data then
      flex1, flex2, accel, pressure =
        data:match('(%d+) (%d+) (%d+) (%d+)')
      print(flex1, flex2, accel, pressure)

      flex1 = Utils.rescale(SCALE.flex1[1], SCALE.flex1[2], 0, 1, flex1)
      flex2 = Utils.rescale(SCALE.flex2[1], SCALE.flex2[2], 0, 1, flex2)
      accel = Utils.rescale(SCALE.accel, SCALE.accel, 0, 1, accel)

      -- Decide how pitch affects the light
    elseif msg ~= 'timeout' then
      error(string.format('Network error: %s', tostring(msg)))
    end
  until not data
end

function love.update(dt)
  pollUDP()

  Timer.update(dt)

  time = time + dt

  if lm.isDown('l') then
    local v = grid:select(lm.getPosition())
    if v then
      v.color = { 255, 0, 0 }
      v.speed = pi * 2
      v:fade(5)
    end
  elseif lm.isDown('r') then
    local v = grid:select(lm.getPosition())
    if v then
      v.color = { 0, 0, 0 }
      v.speed = 0
    end
  end

  if lg.isSupported('pixeleffect') then
    px.externs.light = {
      --lm.getX() / lg.getWidth(),
      --1 - lm.getY() / lg.getHeight(),
      (lg.getWidth() / 2 + 200 * cos(time * pi * 2 / 10)) / lg.getWidth(),
      (lg.getHeight() / 2 + 200 * sin(time * pi * 2 / 10)) / lg.getHeight(),
    }
  end

  grid:update(dt)

  for _,v in ipairs(snakes) do
    v:update(dt)
  end
end

function love.draw()
  lg.reset()
  for _,v in pairs(canvases) do
    v:clear()
  end

  -- Activate the background canvas
  lg.setCanvas(canvases.bg)

  -- Set background color of canvas
  lg.setColor(lg.getBackgroundColor())
  lg.rectangle(
    'fill',
    0,
    0,
    lg.getWidth(),
    lg.getHeight())

  -- Draw the grid
  lg.setColor(0, 0, 0, 255)
  grid:draw()

  lg.setColor(255, 255, 255, 255)
  --lg.circle('fill', px.externs.light[1] * lg.getWidth(), px.externs.light[2] * lg.getHeight(), 3)

  -- Switch to the ray canvas
  lg.setCanvas(canvases.rays)

  if lg.isSupported('pixeleffect') then
    -- Activate the pixel effect
    lg.setPixelEffect(px.effect)

    -- Send parameters into the effect
    px.effect:send('exposure', px.externs.exposure)
    px.effect:send('decay', px.externs.decay)
    px.effect:send('density', px.externs.density + sin(time * 60) * 0.02)
    px.effect:send('weight', px.externs.weight)
    px.effect:send('samples', px.externs.samples)

    -- Draw a scaled down version of the background onto the
    -- half-sized ray canvas
    px.effect:send('light', px.externs.light)

    lg.draw(canvases.bg, 0, 0, 0, 0.5, 0.5)

    -- Turn off the pixel effect
    lg.setPixelEffect()
  end

  -- Stop drawing to any canvas
  lg.setCanvas()

  -- Draw the unaltered background
  lg.draw(canvases.bg)

  -- Draw the ray canvas twice, scaled up to the screen size
  lg.setBlendMode('additive')
  lg.draw(canvases.rays, 0, 0, 0, 2, 2)
  lg.draw(canvases.rays, 0, 0, 0, 2, 2)

  lg.setBlendMode('alpha')
  lg.print(string.format([[
  Flex 1: %.2f
  Flex 2: %.2f
  Accelerometer: %.2f
  Pressure: %.2f
  FPS: %d
  ]],
  flex1,
  flex2,
  accel,
  pressure,
  lt.getFPS()), 10, 10)

  --if lg.isSupported('pixeleffect') then
    --lg.setBlendMode('alpha')
    --lg.print(string.format([[
    --Exposure: %.2f
    --Decay: %.3f
    --Density: %.2f
    --Weight: %.2f
    --Samples: %d
    --Light Position: (%.2f, %.2f)
    --FPS: %d
    --]], 
    --px.externs.exposure,
    --px.externs.decay,
    --px.externs.density,
    --px.externs.weight,
    --px.externs.samples,
    --px.externs.light[1], px.externs.light[2],
    --lt.getFPS()), 10, 10)
  --end
end

function love.keypressed(k, c)
  if k == 'escape' then
    love.event.quit()
  elseif k == 'q' then
    flex1 = flex1 + 0.01
    snakes[1]:changeSpeed(flex1)
    --px.externs.exposure = px.externs.exposure + 0.1
  elseif k == 'a' then
    flex1 = flex1 - 0.01
    snakes[1]:changeSpeed(flex1)
    --px.externs.exposure = px.externs.exposure - 0.1
  elseif k == 'w' then
    flex2 = flex2 + 0.01
    snakes[1]:changeSpeed(flex2)
    --px.externs.decay = px.externs.decay + 0.005
  elseif k == 's' then
    flex2 = flex2 - 0.01
    snakes[1]:changeSpeed(flex2)
    --px.externs.decay = px.externs.decay - 0.005
  elseif k == 'e' then
    accel = accel + 0.01
    if accel > 1 then
      accel = 0.9
    elseif accel < 0 then
      accel = 0.1
    end
    snakes[1]:changeFade(accel)
    snakes[2]:changeFade(accel)
    --px.externs.density = px.externs.density + 0.1
  elseif k == 'd' then
    accel = accel - 0.01
    if accel > 1 then
      accel = 0.9
    elseif accel < 0 then
      accel = 0.1
    end
    snakes[1]:changeFade(accel)
    snakes[2]:changeFade(accel)
    --px.externs.density = px.externs.density - 0.1
  elseif k == 'r' then
    pressure = pressure + 0.1
    --px.externs.weight = px.externs.weight + 0.01
  elseif k == 'f' then
    pressure = pressure - 0.1
    --px.externs.weight = px.externs.weight - 0.01
  elseif k == 't' then
    --px.externs.samples = px.externs.samples + 1
  elseif k == 'g' then
    --px.externs.samples = px.externs.samples - 1
  end
end
