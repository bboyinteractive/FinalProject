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
  self._originalColor = self.color
  self.angle = 0
  self.speed = pi / 2
  self.start = false
  self.time = 0
end

function Hex:update(dt)
  self.angle = self.angle + dt * self.speed
  self.angle = self.angle % (pi * 2)
end

function Hex:contains(x, y)
  local a, b = x - self.x, y - self.y
  return a * a + b * b <= self.apothem * self.apothem
end

function Hex:fade(speed)
  Timer.do_for(speed, function (dt)
    self.color = {
      Utils.lerp(self._originalColor[1], 0, self.time),
      Utils.lerp(self._originalColor[2], 0, self.time),
      Utils.lerp(self._originalColor[3], 0, self.time),
    }
  end, function () self.time = 0 end)
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
