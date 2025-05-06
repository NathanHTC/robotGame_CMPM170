-- robot object
player = {
   x = 100,
   y = 400,
   width = 30,
   height = 40,
   xVel = 0,
   yVel = 0,
   speed = 200,
   jumpForce = -400,
   gravity = 800,
   onGround = false,
   hasSpring = false,
   hasJetpack = false
}

-- Platforms = {
platforms = {
    {x = 0, y = 500, width = 800, height = 100},
    {x = 300, y = 400, width = 100, height = 20},
    {x = 500, y = 300, width = 100, height = 20},
    {x = 650, y = 200, width = 100, height = 20}
}

-- Upgrade parts
springPart = {x = 310, y = 370, width = 20, height = 20, collected = false}
jetpackPart = {x = 510, y = 270, width = 20, height = 20, collected = false}