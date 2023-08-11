local g3d = require "g3d"
local earth = g3d.newModel("assets/sphere.obj", "assets/earth.png", {4,0,0})
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)
local timer = 0

local lightingShader = love.graphics.newShader(g3d.path .. "/g3d.vert", "lighting.frag")

function love.update(dt)
    timer = timer + dt
    moon:setTranslation(math.cos(timer)*5 + 4, math.sin(timer)*5, 0)
    moon:setRotation(0, 0, timer - math.pi/2)
    g3d.camera.firstPersonMovement(dt)
    if love.keyboard.isDown "escape" then
        love.event.push "quit"
    end
end

function love.draw()
    g3d.camera.updateViewMatrix(lightingShader)
    g3d.camera.updateProjectionMatrix(lightingShader)
    earth:draw(lightingShader)
    moon:draw(lightingShader)
    background:draw()
end

function love.mousemoved(x,y, dx,dy)
    g3d.camera.firstPersonLook(dx,dy)
end