local Class = require 'lib.class'
local Timer = require 'lib.timer'
local Utils = require 'utils'

local pi = math.pi
local MAX_DISPLACEMENT = 40

local Hex = Class{}
function Hex:init(x, y, side, apothem, color)
  self.x = x
  self.y = y
  self.side = side
  self.apothem = apothem
  self.color = color or { 0, 0, 0 }
  --self._originalColor = self.color
  self.angle = 0
  self.speed = pi / 2
  self.start = false
  self.time = 0
  self.fadeFlag = false
  self.fadeSpeed = 0
end

function Hex:update(dt)
  self.time = self.time + dt
  if self.fadeFlag and Utils.sum(self.color) > 0 then
    self.color = {
      Utils.lerp(self.color[1], 0, self.fadeSpeed),
      Utils.lerp(self.color[2], 0, self.fadeSpeed),
      Utils.lerp(self.color[3], 0, self.fadeSpeed),
    }
  end

  self.angle = self.angle + dt * self.speed
  self.angle = self.angle % (pi * 2)
end

function Hex:contains(x, y)
  local a, b = x - self.x, y - self.y
  return a * a + b * b <= self.apothem * self.apothem
end

function Hex:fade(speed)
  self.fadeFlag = true
  self.fadeSpeed = speed
end

function Hex:draw()
  love.graphics.push()

  -- Rotate the hexagon about its center
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self.x, -self.y)

  love.graphics.setColor(self.color)
  love.graphics.circle(
    'fill',
    self.x,
    self.y,
    self.side,
    6)
  love.graphics.setColor(love.graphics.getBackgroundColor())
  love.graphics.circle(
    'line',
    self.x,
    self.y,
    self.side,
    6)
  love.graphics.pop()
end

return Hex
