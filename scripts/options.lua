OptionsMode = {}

function OptionsMode:setup()
	self:refresh()
	self.menuStack = {}
	self.menuIndexStack = {}
	self.menuIndex = 1
end

function OptionsMode:refresh()
	local DoubleResolutionValue = ""
	if saveData.DoubleResolution ~= nil and saveData.DoubleResolution == true then
		DoubleResolutionValue = "True"
	else
		DoubleResolutionValue = "False"
	end
	self.menu = {
				{label = "2x Resolution: "..DoubleResolutionValue,
			 	method = self.toggle2xResolution},
			 	{label = "Clear Save Data",
			 		{label = "Are you sure? Z:yes, X:no",
			 		method = self.clearSave},
			 	}
		   }
end

function OptionsMode:toggle2xResolution()
	saveData.DoubleResolution = not saveData.DoubleResolution
	save(saveData)
	if saveData.DoubleResolution == true then
		love.window.setMode(800, 480)
    else
    	love.window.setMode(400, 240)
    end
    self:refresh()
end

function OptionsMode:clearSave()
	backUp(saveData)
	saveData = {}
	save(saveData)
	if saveData.DoubleResolution == true then
		love.window.setMode(800, 480)
    else
    	love.window.setMode(400, 240)
    end
    self:refresh()
end

function OptionsMode:keypressed(key)
	if key == "z" then
		if self.menu[self.menuIndex].method ~= nil then
			self.menu[self.menuIndex].method(self)
		else
			push(self.menuStack, self.menu)
			push(self.menuIndexStack, self.menuIndex)
			self.menu = self.menu[self.menuIndex]
			self.menuIndex = 1
		end
	end
	if key == "x" then
		if #self.menuStack > 0 then
			self.menu = pop(self.menuStack)
			self.menuIndex = pop(self.menuIndexStack)
		else
			pop(currentMode)
		end
	end
	if key == "up" then
		self.menuIndex = math.max(1, self.menuIndex - 1)
	end
	if key == "down" then
		self.menuIndex = math.min(#self.menu, self.menuIndex + 1)
	end
end

function OptionsMode:update(dt)

end

function OptionsMode:draw()
	self:drawMenu()
end

function OptionsMode:drawMenu()
	local padding = 5
	local bottomMargin = 20
	local menuItemHeight = 18
	local totalMenuHeight = menuItemHeight*#self.menu + padding*(#self.menu-1)
	for i=1,#self.menu do
		local drawable = love.graphics.newText(font, formatMenuString(self.menu[i].label, self.menuIndex == i, self.menu[i].method ==  nil))
		local position = {math.floor(400/2 - drawable:getWidth()/2), 
		math.floor(240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1))}
		love.graphics.draw(drawable, position[1], position[2])
	end
end

return OptionsMode
