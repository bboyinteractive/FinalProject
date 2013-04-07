local random = math.random

local Timer = require 'lib.timer'
local Class = require 'lib.class'

local Snake = Class{}
function Snake:init(grid, row, column, color)
  self.grid = grid
  self.row = row
  self.column = column
  self.color = color
  self.handle = Timer.addPeriodic(0.1, function () self:_update(0.1) end)
end

function Snake:changeSpeed(speed)
  Timer.cancel(self.handle)
  self.handle = Timer.addPeriodic(speed, function () self:_update(speed) end)
end

function Snake:_update(speed)
  --self.grid:get(self.row, self.column):fade(speed * 50)

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
