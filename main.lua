-- main.lua

player = require("player")
platforms = require("platform")
collectibles = require("collectibles")

function love.load()
    love.window.setTitle("Robot Game")
    love.window.setMode(800, 600)
end

function love.draw()
   -- Draw player
   love.graphics.setColor(0.2, 0.6, 1.0) -- Blue
   love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

   -- Draw platforms
   love.graphics.setColor(0.5, 0.5, 0.5) -- gravity
   for _, plat in ipairs(platforms) do
        love.graphics.rectangle("fill", plat.x, plat.y, plat.width, plat.height)
   end

end