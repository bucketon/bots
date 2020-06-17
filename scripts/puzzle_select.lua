PuzzleSelect = {}

function PuzzleSelect:setup()
	if saveData.puzzleProgress == nil then
		saveData.puzzleProgress = {}
	end
	self.puzzleList = require('scripts/puzzle_list')
	local earliestIncomplete = 0
	for i=1,#self.puzzleList do
		if saveData.puzzleProgress[i] == nil then
			saveData.puzzleProgress[i] = 0
		end
		if saveData.puzzleProgress[i] == 0 and earliestIncomplete == 0 then
			earliestIncomplete = i
		end
	end
	self.rowLength = 6
	self.menuIndex = earliestIncomplete
	self.puzzleMode = require('scripts/puzzle')
end

function PuzzleSelect:keypressed(key)
	if key == "z" then
		push(currentMode, self.puzzleMode)
		currentMode[#currentMode]:setup()
		currentMode[#currentMode]:startPuzzle(self.puzzleList[self.menuIndex])
	end
	if key == "x" then
		pop(currentMode)
		currentMode[#currentMode]:setup()
	end
	if key == "up" then
		self.menuIndex = math.max(1, self.menuIndex - self.rowLength)
	end
	if key == "down" then
		self.menuIndex = math.min(#self.puzzleList, self.menuIndex + self.rowLength)
	end
	if key == "left" then
		self.menuIndex = math.max(1, self.menuIndex - 1)
	end
	if key == "right" then
		self.menuIndex = math.min(#self.puzzleList, self.menuIndex + 1)
	end
end

function PuzzleSelect:update(dt)

end

function PuzzleSelect:draw()
	self:drawMenu()
end

function PuzzleSelect:drawMenu()
	local levelFont = love.graphics.newFont(50, "mono")
	love.graphics.setFont(levelFont)
	for i=1,#self.puzzleList do
		local row = math.floor((i-1)/self.rowLength)
		local coord = {(i-1)%self.rowLength*64+8, row*64}
		love.graphics.draw(levelBox, coord[1], coord[2])
		love.graphics.print(i, coord[1]+15, coord[2]+2)
		if saveData.puzzleProgress[i] == 1 then
			love.graphics.draw(checkmark, coord[1], coord[2])
		end
		if i == self.menuIndex then
			love.graphics.draw(puzzleCursor, coord[1], coord[2])
		end
	end
	love.graphics.setFont(font)
end

return PuzzleSelect