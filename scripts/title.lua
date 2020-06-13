TitleMode = {}

function TitleMode:setup()
	self.title = love.graphics.newImage("assets/title.png")
	self.score = calculateScore()
	self.menu = {
			{selected = love.graphics.newImage("assets/StartSelected.png"), 
			 unselected = love.graphics.newImage("assets/StartUnselected.png"), 
			 mode = require('scripts/vsAI')},

			{selected = love.graphics.newImage("assets/RulesSelected.png"), 
			 unselected = love.graphics.newImage("assets/RulesUnselected.png"), 
			 mode = require('scripts/rules')},

			 {selected = love.graphics.newImage("assets/AutoplaySelected.png"), 
			 unselected = love.graphics.newImage("assets/AutoplayUnselected.png"), 
			 mode = require('scripts/autoplay')},

			 {selected = love.graphics.newImage("assets/SandboxSelected.png"), 
			 unselected = love.graphics.newImage("assets/SandboxUnselected.png"), 
			 mode = require('scripts/sandbox')}
		   }
	self.menuIndex = 1
end

function calculateScore()
	local score = 0
	if saveData.score ~= nil then
		local last = math.max(1, #saveData.score - relevantScoresCount)
		for i=#saveData.score,last,-1 do
			local gamesPast = i - last + math.max(0, relevantScoresCount - #saveData.score) + 1
			score = score + saveData.score[i]*gamesPast
		end
	end
	return score
end

function TitleMode:keypressed(key)
	if key == "z" then
		push(currentMode, self.menu[self.menuIndex].mode)
		currentMode[#currentMode]:setup()
	end
	if key == "up" then
		self.menuIndex = math.max(1, self.menuIndex - 1)
	end
	if key == "down" then
		self.menuIndex = math.min(#self.menu, self.menuIndex + 1)
	end
end

function TitleMode:update(dt)

end

function TitleMode:draw()
	love.graphics.draw(self.title, 0, 0)
	self:drawMenu()
	self:drawScore()
end

function TitleMode:drawMenu()
	local padding = 5
	local bottomMargin = 20
	local menuItemHeight = self.menu[1].selected:getHeight()
	local totalMenuHeight = menuItemHeight*#self.menu + padding*(#self.menu-1)
	for i=1,#self.menu do
		local drawable
		if self.menuIndex == i then
			drawable = self.menu[i].selected
		else
			drawable = self.menu[i].unselected
		end
		local position = {400/2 - drawable:getWidth()/2, 240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1)}
		love.graphics.draw(drawable, position[1], position[2])
	end
end

function TitleMode:drawScore()
	love.graphics.print("Current Score: "..self.score, 0, 0)
end

return TitleMode
