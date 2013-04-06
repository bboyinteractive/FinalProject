local Class = require 'lib.class'
local Utils = require 'utils'

local pi = math.pi
local MAX_DISPLACEMENT = 40

local Hex = Class{}
function Hex:init(x, y, side, apothem, color)
  self.x, self.y = Utils.edgeRandom(side)
  self._home = { x = x, y = y }
  self.side = side
  self.apothem = apothem
  self.color = color or { 0, 0, 0 }
  self.angle = 0
  self.speed = 0
  self.start = false
end

function Hex:update(dt)
  if self.start and not (self.x == self._home.x and self.y == self._home.y) then
    self.x = self.x + (self._home.x - self.x) * dt
    self.y = self.y + (self._home.y - self.y) * dt
  end

  self.angle = self.angle + dt * self.speed
  self.angle = self.angle % (pi * 2)
end

function Hex:contains(x, y)
  local a, b = x - self.x, y - self.y
  return a * a + b * b <= self.apothem * self.apothem
end

function Hex:getHomePosition()
  return self._home.x, self._home.y
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
