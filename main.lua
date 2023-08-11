local republica = require("src.republicanova")
local exit = false
local options = require('data.config')

local g3d = require "g3d"

local earth = g3d.newModel("assets/sphere.obj", "assets/earth.png", {4,0,0})
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)
local timer = 0
local image = love.graphics.newImage("assets/dirt.jpg")
image:setWrap("repeat", "repeat")
local box = g3d.newModel("assets/cube.obj", image, {0,0,0}, nil, {1,1,1})

local g3d = require "g3d"
local earth = g3d.newModel("assets/sphere.obj", "assets/earth.png", {4,0,0})
local moon = g3d.newModel("assets/sphere.obj", "assets/moon.png", {4,5,0}, nil, 0.5)
--local background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", nil, nil, 500)
local timer = 0

--local myShader = love.graphics.newShader(g3d.shaderpath, "data/luzfixa.frag") not configurable
local myShader = love.graphics.newShader(g3d.shaderpath, "data/luzposicionavel.frag")
myShader:send("lightPosition",{32,16,32})
myShader:send("light_dist",256)
myShader:send("ambient",0.3)

world = republica.world(options.mapsize,options.mapquality,options.mappolish)

g3d.camera.fov = options.fov
g3d.camera.nearClip = 0.01
g3d.camera.farClip = 1000
g3d.camera.aspectRatio = love.graphics.getWidth()/love.graphics.getHeight()
g3d.camera.position = {options.cameraposition.x,options.cameraposition.y,options.cameraposition.x}
g3d.camera.target = {}
g3d.camera.up = {0,-1,0}
g3d.camera.lookAt(0,0,0,#world.map.height/2, republica.util.matrix.average(world.map.height), #world.map.height/2)
local function y_rgba(index, min_val, max_val, invert)
    local range = max_val - min_val
    local val = (index - min_val) / range
    local r = math.floor(255 * val)
    local b = math.floor(255 * (1 - val))
    local g = 128
    if(invert) then
        b,r,g = g,r,b
    end
    return r,g,b
end

local function ytoz(vec3)
    return {x = vec3.x, y = vec3.z, z = vec3.y}
end

local function simplify(arr)
    local b = {}
    local dY = false
    local chk = {}
    for i=1,#arr do
        chk[i]={}
        for j=1,#arr[1] do chk[i][j]=false end
    end
    for x=1,#arr do
        for y=1,#arr[1] do
            if chk[x][y] then goto continue else
                local v = arr[x][y]
                local cB = {min={x=x,y=y},max={x=x,y=y},value=v}
                local cX = 0
                local exit = false
                while not exit do
                    if arr[x+cX] and arr[x+cX][y]==v then chk[x+cX][y]=true cX=cX+1 else exit=true end
                end
                exit = false
                local cY = 0
                while not exit and y+cY<#arr[1] do
                    if arr[x][y+cY]==v then
                        local cks={}
                        for xx=0,cX-1 do for yy=0,cY-1 do table.insert(cks,(arr[cB.max.x+xx][cB.max.y+yy]==v) and 1 or 0) end end
                        if republica.util.array.sum(cks)==#cks then
                            for xx=0,cX-1 do for yy=0,cY-1 do chk[cB.max.x+xx][cB.max.y+yy]=true end end
                            cY=cY+1
                        else exit=true end
                    else exit=true end
                end
                cB.max.y = cB.max.y + cY - 1
                cB.max.x = cB.max.x + cX - 1
                exit=false
                table.insert(b, cB)
            end
            ::continue::
        end
    end

    local blocks = {}
    for i=1,#b do 
        local min,max = republica.util.matrix.minmax(arr)
        b[i]={
            position = {
            x = b[i].min.x-0.5+(b[i].max.x-b[i].min.x+1)/2,
            y = b[i].value-min+1,
            z = b[i].min.y-0.5+(b[i].max.y-b[i].min.y+1)/2},
            size = { x = b[i].max.x-b[i].min.x+1, y = 1 , z = (b[i].max.y-b[i].min.y+1)},
            color = y_rgba(b[i].value,min,max),
            value = b[i].value
        }
        table.insert(blocks,b[i])
    end
    
    return blocks;
end 

local simpler = simplify(world.map.height)

function love.draw()
    world:frame()
	--prepare for rendering
    for k, v in pairs(simpler) do
        box:setTranslation(v.position.x,v.position.y,v.position.z)
        box:setScale(v.size.x,v.size.y,v.size.z)
        box:draw(myShader)
    end
    --background:draw()
end
