local random = math.random

local Timer = require 'lib.timer'
local Class = require 'lib.class'

local Snake = Class{}
function Snake:init(grid, row, column, color)
  self.grid = grid
  self.row = row
  self.column = column
  self.color = color
  self.fadeSpeed = 0.1
  self.updateSpeed = 0.1
  self.handle = Timer.addPeriodic(self.updateSpeed, function () self:_update() end)
end

function Snake:changeFade(fade)
  self.fadeSpeed = fade
end

function Snake:changeUpdate(speed)
  if speed - 0.5 < self.updateSpeed and self.updateSpeed < speed + 0.5 then
    return
  end

  self.updateSpeed = speed

  Timer.cancel(self.handle)
  self.handle = Timer.addPeriodic(self.updateSpeed, function () self:_update(speed) end)
end

function Snake:_update()
  self.grid:get(self.row, self.column):fade(self.fadeSpeed)

  local lr, ur = -1, 1
  local lc, uc = -1, 1

  if self.row == 1 then
    lr = 0
  elseif self.row == self.grid:rows() then
    ur = 0
  end

  if self.column == 1 then
    lc = 0
  elseif self.column == self.grid:columns() then
    uc = 0
  end

  self.row, self.column = self.row + random(lr, ur), self.column + random(lc, uc)
  self.grid:get(self.row, self.column).color = self.color
end

return Snake
