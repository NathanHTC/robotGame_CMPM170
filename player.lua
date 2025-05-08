-- player.lua
local player = {
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
    hasJetpack = false,
    direction = "right", -- for flipping animation
    animations = {},
    currentAnimation = nil
}

return player