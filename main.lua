local lg, lm, lt = love.graphics, love.mouse, love.timer
local pi, sin, cos = math.pi, math.sin, math.cos

local Grid  = require 'grid'
local Snake = require 'snake'
local Timer = require 'lib.timer'
local Utils = require 'utils'

local time, grid, px, canvases, snakes

function love.load()
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
    Snake(grid, 1, 1, { 255, 0, 0 }),
    Snake(grid, grid:rows(), 1, { 0, 255, 0 }),
    Snake(grid, 1, grid:columns(), { 0, 0, 255 }),
  }
end

function love.update(dt)
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
      (lg.getWidth() / 2 + 100 * cos(time * pi * 2)) / lg.getWidth(),
      (lg.getHeight() / 2 + 100 * sin(time * pi * 2)) / lg.getHeight(),
    }
  end

  grid:update(dt)
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

  -- Switch to the ray canvas
  lg.setColor(255, 255, 255, 255)
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

  if lg.isSupported('pixeleffect') then
    lg.setBlendMode('alpha')
    lg.print(string.format([[
    Exposure: %.2f
    Decay: %.3f
    Density: %.2f
    Weight: %.2f
    Samples: %d
    Light Position: (%.2f, %.2f)
    FPS: %d
    ]], 
    px.externs.exposure,
    px.externs.decay,
    px.externs.density,
    px.externs.weight,
    px.externs.samples,
    px.externs.light[1], px.externs.light[2],
    lt.getFPS()), 10, 10)
  end
end

function love.keypressed(k, c)
  if k == 'escape' then
    love.event.quit()
  elseif k == 'q' then
    px.externs.exposure = px.externs.exposure + 0.1
  elseif k == 'a' then
    px.externs.exposure = px.externs.exposure - 0.1
  elseif k == 'w' then
    px.externs.decay = px.externs.decay + 0.005
  elseif k == 's' then
    px.externs.decay = px.externs.decay - 0.005
  elseif k == 'e' then
    px.externs.density = px.externs.density + 0.1
  elseif k == 'd' then
    px.externs.density = px.externs.density - 0.1
  elseif k == 'r' then
    px.externs.weight = px.externs.weight + 0.01
  elseif k == 'f' then
    px.externs.weight = px.externs.weight - 0.01
  elseif k == 't' then
    px.externs.samples = px.externs.samples + 1
  elseif k == 'g' then
    px.externs.samples = px.externs.samples - 1
  end
end
