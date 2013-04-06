local random, sqrt = math.random, math.sqrt

return {
  edgeRandom = function(buffer)
    local x, y = 1, 1
    while (0 < x and x < love.graphics.getWidth()) or
          (0 < y and y < love.graphics.getHeight()) do
      x = random(-buffer, love.graphics.getWidth() + buffer)
      y = random(-buffer, love.graphics.getHeight() + buffer)
    end
    return x, y
  end,
  dist = function(x, y)
    return sqrt(x * x + y * y)
  end,
}
