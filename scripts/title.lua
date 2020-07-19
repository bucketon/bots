TitleMode = {}

function TitleMode:setup()
	self.title = love.graphics.newImage("assets/title.png")
	local puzzleList = require('scripts/puzzle_list')
	self.menu = {
		{label = "Start",
			{label = "VS AI",
				{label = "Classic (High Score: "..calculateClassicScore()..")",
			 	mode = require('scripts/vsAI')},
			 	{label = "Survival (High Score: "..calculateSurvivalScore()..")",
			 	mode = require('scripts/survival')}
			},

			{label = "Puzzle ("..calculatePuzzleScore().."/"..#puzzleList.." Complete)", 
			mode = require('scripts/puzzle_select')},

			{label = "Online", 
			mode = require('scripts/classic_online')},

			{label = "Help", 
				--{label = "Autoplay", 
				--mode = require('scripts/autoplay')},
				{label = "How to Play", 
			 	mode = require('scripts/rules')},
				{label = "Sandbox", 
				mode = require('scripts/sandbox')},
				{label = "Options", 
				mode = require('scripts/options')},
				--{label = "Deckbuilder", 
				--mode = require('scripts/deckbuilder')},
			},
		}
	}
	self.menuStack = {}
	self.menuIndexStack = {}
	self.menuIndex = 1
end

function calculateClassicScore()
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

function calculateSurvivalScore()
	if saveData.survivalScore == nil then
		saveData.survivalScore = 0
	end
	return saveData.survivalScore
end

function calculatePuzzleScore()
	local score = 0
	if saveData.puzzleProgress ~= nil then
		for i=1,#saveData.puzzleProgress do
			if saveData.puzzleProgress[i] ~= nil then
				score = score + saveData.puzzleProgress[i]
			end
		end
	end
	return score
end

function TitleMode:keypressed(key)
	if key == "z" then
		if self.menu[self.menuIndex].mode ~= nil then
			push(currentMode, self.menu[self.menuIndex].mode)
			currentMode[#currentMode]:setup()
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
		end
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
end

function TitleMode:drawMenu()
	local padding = 5
	local bottomMargin = 20
	local menuItemHeight = 18
	local totalMenuHeight = menuItemHeight*#self.menu + padding*(#self.menu-1)
	for i=1,#self.menu do
		local drawable = love.graphics.newText(font, formatMenuString(self.menu[i].label, self.menuIndex == i, 
			self.menu[i].mode ==  nil))
		local position = {math.floor(400/2 - drawable:getWidth()/2), 
		math.floor(240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1))}
		local prevRed, prevGreen, prevBlue = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", position[1]-padding, position[2]-padding, 
			drawable:getWidth()+10, drawable:getHeight()+10)
		love.graphics.setColor(prevRed, prevGreen, prevBlue)
		love.graphics.draw(drawable, position[1], position[2])
	end
end

return TitleMode
