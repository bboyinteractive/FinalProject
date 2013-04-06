local sqrt, pi = math.sqrt, math.pi
local Utils = require 'utils'

local Hex = {}
Hex.__index = Hex

local MAX_DISPLACEMENT = 40

function Hex:new(x, y, side, apothem, color)
  local o = {}
  o.x, o.y = Utils.edgeRandom(side)
  o.home = { x = x, y = y }
  o.side = side
  o.apothem = apothem
  o.color = color
  o.angle = 0
  o.speed = 0
  return setmetatable(o, self)
end

function Hex:update(dt)
  if not (self.x == self.home.x and self.y == self.home.y) then
    self.x = self.x + (self.home.x - self.x) * dt
    self.y = self.y + (self.home.y - self.y) * dt
  end

  self.angle = self.angle + dt * self.speed
  self.angle = self.angle % (pi * 2)
end

function Hex:contains(x, y)
  local a, b = x - self.x, y - self.y
  return a * a + b * b <= self.apothem * self.apothem
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

return setmetatable(Hex, { __call = Hex.new })
