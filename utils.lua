local lf, lg = love.filesystem, love.graphics
local random, sqrt = math.random, math.sqrt

return {
  dist = function(x, y)
    return sqrt(x * x + y * y)
  end,
  createEffect = function (filename)
    local t = lf.read(filename)
    return lg.newPixelEffect(t)
  end,
}
