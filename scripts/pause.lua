Pause = {}

function Pause:setup()
	self.menu = {
			{label = "Back to Menu", 
			 method = Pause.toTitle},

			{label = "How to Play", 
			 mode = require('scripts/rules')}
		   }
	self.menuStack = {}
	self.menuIndexStack = {}
	self.menuIndex = 1
end

function Pause:keypressed(key)
	if key == "z" then
		if self.menu[self.menuIndex].mode ~= nil then
			push(currentMode, self.menu[self.menuIndex].mode)
			currentMode[#currentMode]:setup()
		elseif self.menu[self.menuIndex].method ~= nil then
			self.menu[self.menuIndex]:method()
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

function Pause:toTitle()
	pop(currentMode)
	if currentMode[#currentMode].onExit ~= nil then
		currentMode[#currentMode]:onExit()
	end
	for i=2,#currentMode do
		pop(currentMode)
	end
end

function Pause:update(dt)

end

function Pause:draw()
	self:drawMenu()
end

function Pause:drawMenu()
	local padding = 5
	local bottomMargin = 20
	local menuItemHeight = 18
	local totalMenuHeight = menuItemHeight*#self.menu + padding*(#self.menu-1)
	for i=1,#self.menu do
		local drawable = love.graphics.newText(font, formatMenuString(self.menu[i].label, self.menuIndex == i, false))
		local position = {math.floor(400/2 - drawable:getWidth()/2), 
		math.floor(240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1))}
		love.graphics.draw(drawable, position[1], position[2])
	end
end

return Pause
