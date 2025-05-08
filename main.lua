-- main.lua

player = require("player")
platforms = require("platform")
collectibles = require("collectibles")


function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle("Robot Game")
    love.window.setMode(800, 600)

    --Load Player Sprite
    player.spriteSheet = love.graphics.newImage('assets/Character/PlayerSprite/Prototype_Character.png')
    player.grid = anim8.newGrid(32,32, player.spriteSheet:getWidth(),player.spriteSheet:getHeight(), 0, 0, 2)

    --Player Animation
    player.animations.right = anim8.newAnimation(player.grid('1-4', 5), 0.2) -- row 5
    player.animations.left = anim8.newAnimation(player.grid('1-4', 5), 0.2):flipH() -- flip for left
    player.animations.jump = anim8.newAnimation(player.grid('1-1', 1), 1) -- row 2, first frame
    player.currentAnimation = player.animations.right



 
    background = love.graphics.newImage("assets/background/background 3/origbig.png")
    

end

function love.draw()
   love.graphics.draw(background, 0, 0)

    -- Draw player animation
    if player.currentAnimation then
        player.currentAnimation:draw(player.spriteSheet, player.x, player.y, 0, 2, 2, 0, 0)
    end

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
    local isMoving = false

   -- Horizontal movement
   if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      player.xVel = -player.speed
      player.direction = "left"
      player.currentAnimation = player.animations.left
      isMoving = true
   elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      player.xVel = player.speed
      player.direction = "right"
      player.currentAnimation = player.animations.right
      isMoving = true
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

    -- Jetpack flying
    if player.hasJetpack and love.keyboard.isDown("w") then
        player.yVel = -200
    end

    if not player.onGround then
        player.currentAnimation = player.animations.jump
    end

    if player.currentAnimation then
        player.currentAnimation:update(dt)
    end

    if isMoving == false then
        player.currentAnimation:gotoFrame(1) 
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