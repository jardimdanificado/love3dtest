--Mouse Centered Graphical User Interface(MoCeGUI)
local mocegui={version="0.1.0"}
package.path = 'mocegui/util/?.lua' .. ";" .. package.path
local util = require "mocegui.util"
local mouse =
{
	draggin = false
}

local window = {}

function mocegui.closeWindow()
	window[1] = nil
	window = util.array.clear(window)
end

function mocegui.newWindow(title,position,size,color)
	local win = 
	{
		color= color or {0.3,0.3,0.4,1},
		position= position or {16,16},
		size=size or {16,16},
		text = {},
		button = not title and 
		{
		} or
		{
			{
				position = {(size and size[1] or 50)-12,0},
				size = {12,12},
				color = {1,0.5,0.5,1},
				pcolor = {0.5,0.1,0.1,1},
				func = mocegui.closeWindow,
				args = {}
			}
		},
		hide = false,
		title = title
	}
	win.text.new = function(text,position,size,color,pcolor)
		local txt = {
			position = position or {0,0},
			size = size or 12,
			color = color or {1,1,1,1},
			text = text or 'blank'
		}
		table.insert(win.text,1,txt)
		return win.text[1]
	end
	win.button.new = function(position,size,func,args,color,pcolor)
		local btn = {
			position = position,
			size = size or {12,12},
			color = color or {0,0.5,0.5,1},
			pcolor = pcolor or {0.5,0.1,0.1,1},
			func = func or mocegui.closeWindow,
			args = args or {}
		}
		btn.position = position or {size[1]-12,0}
		table.insert(win.button,1,btn)
		return win.button[1]
	end
	table.insert(window,2,win)
	util.array.clear(window)
	return win
end

local function bRect(px,py,sx,sy,color,bordercolor)
	love.graphics.setColor(bordercolor or {1,1,1,1})
	love.graphics.rectangle( 'fill', px-1, py-1, sx+2, sy+2)
	love.graphics.setColor(unpack(color))
	love.graphics.rectangle( 'fill', px, py, sx, sy)
end

function mocegui.load()
	local iconImageData = love.image.newImageData("mocegui/png/icon.png")
    love.window.setIcon(iconImageData)
	love.window.setTitle("MoCeGUI" .. mocegui.version)
	mocegui.titlecache = love.window.getTitle()
end

function mocegui.keypressed(key)
end

function mocegui.mousemoved( x, y, dx, dy, istouch )
	if mouse.draggin then
		mouse.draggin[1] = mouse.draggin[1] + dx
		mouse.draggin[2] = mouse.draggin[2] + dy
	end
end

function mocegui.mousereleased(x, y, button)
	if window[1] then
		if button == 1 then
			window[1].button = util.array.clear(window[1].button)
			for index, _button in ipairs(window[1].button) do
				if _button and _button.position and window[1] and window[1].position then
					if x >= window[1].position[1] + _button.position[1]  and
					   x <= window[1].position[1] + _button.position[1] + _button.size[1]  and
					   y >= window[1].position[2] + _button.position[2]  and
					   y <= window[1].position[2] + _button.position[2] + _button.size[2]  then
						_button.func(window)
						_button.pressed = false
					end
				end
			end
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif button == 3 then
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif button == 2 then
			if x >= window[1].position[1]  and
			x <= window[1].position[1] + window[1].size[1]  and
			y >= window[1].position[2]  and
			y <= window[1].position[2] + window[1].size[2]  then
				mocegui.closeWindow()
			end
		end
	end
end

function mocegui.mousepressed(x, y, button, istouch)
	if window[1] then
		if not (x >= window[1].position[1]  and
		x <= window[1].position[1] + window[1].size[1]  and
		y >= window[1].position[2]  and
		y <= window[1].position[2] + window[1].size[2] ) then
			for index, win in pairs(window) do
				if x >= win.position[1]  and
				x <= win.position[1] + win.size[1]  and
				y >= win.position[2]  and
				y <= win.position[2] + win.size[2]  then
					util.table.move(window,index,1)
					break
				end
			end
		end
		if button == 1 then
			if window[1].title and
			x >= window[1].position[1]  and
			x <= window[1].position[1] + window[1].size[1]  and
			y >= window[1].position[2]  and
			y <= window[1].position[2] + 20 then
				mouse.draggin = window[1].position
				mouse.current = 2
			end
			for index, _button in ipairs(window[1].button) do
				if x >= window[1].position[1] + _button.position[1]  and
				x <= window[1].position[1] + _button.position[1] + _button.size[1]  and
				y >= window[1].position[2] + _button.position[2]  and
				y <= window[1].position[2] + _button.position[2] + _button.size[2]  then
					_button.pressed = true
				end
			end
		elseif button == 3 then
			if x >= window[1].position[1]  and
			x <= window[1].position[1] + window[1].size[1]  and
			y >= window[1].position[2]  and
			y <= window[1].position[2] + window[1].size[2]  then
				mouse.draggin = window[1].position
				mouse.current = 2
			end
		end
	end
end

function mocegui.update()
end

function mocegui.draw()
	window = util.array.clear(window)
	love.graphics.push()
	for index = #window, 1, -1 do
		local v = window[index]
		bRect(v.position[1], v.position[2], v.size[1], v.size[2], v.color)
		if v.title then
			bRect(v.position[1], v.position[2], v.size[1], 12, {1,1,1,1})
			love.graphics.setColor(unpack(v.color))
			love.graphics.print(v.title,v.position[1],v.position[2],0,0.8,0.8)
		end
		for key, button in ipairs(v.button) do
			bRect(v.position[1]+button.position[1], v.position[2]+button.position[2], button.size[1], button.size[2],(button.pressed and button.pcolor or button.color))
		end
		for key, text in ipairs(v.text) do
			love.graphics.setColor(unpack(text.color))
			love.graphics.print(text.text, v.position[1]+text.position[1], v.position[2]+text.position[2])
		end
	end
	love.graphics.setColor(1,1,1,1)
	love.graphics.pop()
	love.graphics.print(mocegui.titlecache .. "\nCurrent FPS: " .. tostring(love.timer.getFPS()) .. "\nWindow amount:" .. #window, 1, 1)
end

mocegui.window = window
mocegui.mouse = mouse
return mocegui