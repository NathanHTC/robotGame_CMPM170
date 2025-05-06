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

   -- Draw collectibles if collected is false
   if not collectibles.spring.collected then
      love.graphics.setColor(0.8, 0.9, 0.2) -- yellow
      love.graphics.rectangle("fill", collectibles.spring.x, collectibles.spring.y, collectibles.spring.width, collectibles.spring.height) 
   end

   -- Draw jetpack if not collected
    if not collectibles.jetpack.collected then
        love.graphics.setColor(1.0, 0.2, 0.2) -- red
        love.graphics.rectangle("fill", collectibles.jetpack.x, collectibles.jetpack.y, collectibles.jetpack.width, collectibles.jetpack.height)
    end

end

function love.update(dt)
   -- Horizontal movement
   if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      player.xVel = -player.speed
   elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      player.xVel = player.speed
   else
      player.xVel = 0
   end

   -- apply movement
   player.x = player.x + player.xVel * dt
   player.y = player.y + player.yVel * dt

   -- Apply gravity if not on onGround 
   if not player.onGround or player.hasJetpack then
      player.yVel = player.yVel + player.gravity * dt
   end

    -- Platform collision
    for _, plat in ipairs(platforms) do
        if checkCollision(player, plat) and player.y + player.height <= plat.y + 10 and player.yVel >= 0 then
            player.y = plat.y - player.height
            player.yVel = 0
            player.onGround = true
        end
    end

    -- Collectible collision
    if not collectibles.spring.collected and checkCollision(player, collectibles.spring) then
         collectibles.spring.collected = true
         player.hasSpring = true
    end

    if not collectibles.jetpack.collected and checkCollision(player, collectibles.jetpack) then
         collectibles.jetpack.collected = true
         player.hasJetpack = true
    end


end

function love.keypressed(key)
    if key == "space" and player.onGround and player.hasSpring then
        player.yVel = player.jumpForce
        player.onGround = false
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end