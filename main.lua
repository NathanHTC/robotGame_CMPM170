-- main.lua

player = require("player")
platforms = require("platform")
collectibles = require("collectibles")
inventory = require("inventory")


function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle("Robot Game")
    love.window.setMode(800, 600)

    local gameWon = false

    inventory.init()

    --Load Collectables
    springImage = love.graphics.newImage("assets/collectibles/spring.png")
    jetpackImage = love.graphics.newImage("assets/collectibles/jetpack.png")

    -- Set item icons in inventory
    inventory.itemDefinitions.spring.icon = springImage
    inventory.itemDefinitions.jetpack.icon = jetpackImage
    
    -- Get original image sizes
    local springW, springH = springImage:getWidth(), springImage:getHeight()
    local jetpackW, jetpackH = jetpackImage:getWidth(), jetpackImage:getHeight()
    
    -- Calculate scale to fit 20x20
    springScaleX = 30 / springW
    springScaleY = 30 / springH
    
    jetpackScaleX = 30 / jetpackW
    jetpackScaleY = 30 / jetpackH
    


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

    -- Draw spring if not collected
    if not collectibles.spring.collected then
        love.graphics.setColor(1, 1, 1) -- reset color
        love.graphics.draw(springImage, collectibles.spring.x, collectibles.spring.y, 0, springScaleX, springScaleY)
    end

    -- Draw jetpack if not collected
    if not collectibles.jetpack.collected then
        love.graphics.setColor(1, 1, 1) -- reset color
        love.graphics.draw(jetpackImage, collectibles.jetpack.x, collectibles.jetpack.y, 0, jetpackScaleX, jetpackScaleY)

    end

    -- Draw win box
    if not collectibles.winBox.reached then
        love.graphics.setColor(1.0, 1.0, 0.0) -- bright yellow
        love.graphics.rectangle("fill", collectibles.winBox.x, collectibles.winBox.y, collectibles.winBox.width, collectibles.winBox.height)
    end

    if gameWon then
        -- Create a centered, large message box
        local winMsg = "YOU WIN!"
        local msgWidth = love.graphics.getFont():getWidth(winMsg) * 2
        local msgHeight = love.graphics.getFont():getHeight() * 2
        
        -- Semi-transparent background
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 
            love.graphics.getWidth()/2 - msgWidth/2 - 20, 
            love.graphics.getHeight()/2 - msgHeight/2 - 20, 
            msgWidth + 40, 
            msgHeight + 40)
        
        -- Draw border
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", 
            love.graphics.getWidth()/2 - msgWidth/2 - 20, 
            love.graphics.getHeight()/2 - msgHeight/2 - 20, 
            msgWidth + 40, 
            msgHeight + 40)
        
        -- Draw win text
        love.graphics.setColor(1, 1, 0) -- Bright yellow text
        love.graphics.print(winMsg, 
            love.graphics.getWidth()/2 - msgWidth/2, 
            love.graphics.getHeight()/2 - msgHeight/2, 
            0, 2, 2) -- Scale text to be larger
    end

    -- Draw instructions in top right corner
    if not inventory.visible then
        love.graphics.setColor(1, 1, 1) -- Set text color to white
        local instructions = {
            "Controls:",
            "A/Left Arrow - Move Left",
            "D/Right Arrow - Move Right",
            "Space - Jump (with Spring)",
            "W - Fly (with Jetpack)",
            "",
            "Items:",
            "Yellow Box - Spring",
            "Red Box - Jetpack"
        }
    
        local x = love.graphics.getWidth() - 220 -- Position from right edge
        local y = 20 -- Position from top
        local lineHeight = 18
    
        -- Draw a semi-transparent background for better readability
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x - 10, y - 10, 210, #instructions * lineHeight + 10)
    
        -- Draw the instructions text
        love.graphics.setColor(1, 1, 1)
        for i, line in ipairs(instructions) do
            love.graphics.print(line, x, y + (i-1) * lineHeight)
        end
    end

    -- Draw equipped items indicators
    love.graphics.setColor(1, 1, 1)
    local statusY = 50
    
    -- Show equipped status
    if inventory.isEquipped("spring") then
        love.graphics.draw(springImage, 20, statusY, 0, 0.05, 0.05)
        love.graphics.print("Spring: Equipped", 0, statusY + 50)
        statusY = statusY + 80
    end
    
    if inventory.isEquipped("jetpack") then
        love.graphics.draw(jetpackImage, 20, statusY, 0, 0.05, 0.05)
        love.graphics.print("Jetpack: Equipped", 0, statusY + 50)
    end
    
    -- Draw the inventory UI if visible
    inventory.draw()
end

function love.update(dt)
    local isMoving = false

    if inventory.visible then
        return
    end

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

   -- Apply gravity regardless of jetpack - we'll just counteract it when using jetpack
    player.yVel = player.yVel + player.gravity * dt
    
    -- Jetpack flying - only works if equipped
    if inventory.isEquipped("jetpack") and love.keyboard.isDown("w") then
        -- Apply upward thrust that counteracts gravity and provides some lift
        -- This creates a more realistic jetpack feel with limited ascension speed
        player.yVel = player.yVel - (player.gravity * 1.5) * dt
        
        -- Limit maximum upward velocity
        if player.yVel < -250 then
            player.yVel = -250
        end
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
         inventory.addItem("spring")
    end

    if not collectibles.jetpack.collected and checkCollision(player, collectibles.jetpack) then
         collectibles.jetpack.collected = true
         inventory.addItem("jetpack")
    end

    -- Jetpack flying
    if inventory.isEquipped("jetpack") and love.keyboard.isDown("w") then
        player.yVel = -200
    end

    if not player.onGround then
        player.currentAnimation = player.animations.jump
    end

    if player.currentAnimation then
        player.currentAnimation:update(dt)
    end

    if not collectibles.winBox.reached and checkCollision(player, collectibles.winBox) then
        collectibles.winBox.reached = true
        gameWon = true
    end

    if isMoving == false then
        player.currentAnimation:gotoFrame(1) 
    end

end

function love.keypressed(key)
    if key == "i" then
        inventory.toggleVisibility()
    end

    if key == "space" and player.onGround and inventory.isEquipped("spring") then
        player.yVel = player.jumpForce
        player.onGround = false
    end
end

function love.mousepressed(x, y, button)
    -- Handle inventory clicks
    inventory.mousepressed(x, y, button)
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end