Puzzle = {}

function Puzzle:setup()
	self.puzzleList = require('scripts/puzzle_list')
end

function Puzzle:startPuzzle(puzzle)
	for i=1,#self.puzzleList do
		if self.puzzleList[i] == puzzle then
			self.index = i
		end
	end
	self.player1Hand = {}
	for i=1,#puzzle.hand do
		self.player1Hand[i] = deepCopy(puzzle.hand[i].bot)
		self.player1Hand[i].team = puzzle.hand[i].team
	end
	self.deck = deepCopy(puzzle.deck)
	self.board = Gameboard:new()--this comes from the level
	for i=1,#puzzle.board do
		local card = deepCopy(puzzle.board[i].bot)
		if card ~= nil then
			card.team = puzzle.board[i].team
			self.board:setTile(puzzle.board[i].coord, card)
		end
	end
	self:reset_()
end

function Puzzle:reset_()
	self.cursor = HandCursor:new(self.board, self.player1Hand, 1, nil)
	self.board.deck = self.deck
	self.playerTurnsDone = false
	if saveData.SortHands then
		table.sort(self.player1Hand, function (left, right) return left.number < right.number end)
	end
	self.result = 0
	self.board:refresh()
end

function Puzzle:keypressed(key)
	if self.result == 0 then
		if key=="left" then
			self.cursor = self.cursor:left()
		end
		if key == "right" then
			self.cursor = self.cursor:right()
		end
		if key == "up" then
			self.cursor = self.cursor:up()
		end
		if key == "down" then
			self.cursor = self.cursor:down()
		end

		if key=="z" then
			--run the fight
			if self.playerTurnsDone then
				if self.board.winner == 0 then
					self.board:progress()
				else
					if self.board.winner == 1 then
						--player won!
						--update saveData
						saveData.puzzleProgress[self.index] = 1
						save(saveData)
						self.result = 1
					else
						--player lost.
						self.result = 2
					end
				end
			else
				--pick up card if in hand, put down card if on empty board space
				if self.cursor.bookmark ~= nil and self.cursor.board:getTile(self.cursor.coord) == nil and self.cursor.selectedCard == nil then
					self.cursor = self.cursor:bookmark()
				elseif self.cursor.grab ~= nil then
					local tookTurn = false
					self.cursor, tookTurn = self.cursor:grab()
					if tookTurn == true then
						self:endOfRound()
					end
				elseif self.cursor.place ~= nil and self.cursor.selectedCard ~= nil then
					local tookTurn = false
					self.cursor, tookTurn = self.cursor:place()
					if tookTurn == true then
						self:endOfRound()
					end
				elseif self.cursor.pickup ~= nil and self.cursor.selectedCard == nil and not self:isPuzzleCard(self.cursor.coord) then
					self.cursor = self.cursor:pickup()
				end
			end
		end

		if key=="x" then
			--put card back in hand if card picked up
			if self.cursor.replace ~= nil and self.cursor.selectedCard ~= nil then
				self.cursor = self.cursor:replace()
			else
				push(currentMode, PauseMode)
				currentMode[#currentMode]:setup()
			end
		end
	else
		if key=="z" then
			if self.result == 1 then
				pop(currentMode)
			else
				self:startPuzzle(self.puzzleList[self.index])
			end
		end
	end
end

function Puzzle:update(dt)

end

function Puzzle:isPuzzleCard(coord)
	local puzzle = self.puzzleList[self.index]
	for i=1,#puzzle.board do
		if areEqual(puzzle.board[i].coord, coord) then
			return true
		end
	end
	return false
end

function Puzzle:endOfRound()
	if self.board:isBoardFull() then
		self.playerTurnsDone = true
	end
	self.board:refresh()
end

function Puzzle:draw()
	drawBoard(self.board, boardOffset)
	drawCursor(self.cursor)
	drawHand(self.cursor.hand, self.cursor.index, {boardOffset[1], 220}, 50)

	--victory/failure
	if self.result == 1 then
		love.graphics.draw(clear, 0, 88)
	elseif self.result == 2 then
		love.graphics.draw(tooBad, 0, 88)
	end
	if self.result ~= 0 then
		local prevRed, prevGreen, prevBlue = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 105, 155, 210, 60)
		love.graphics.setColor(prevRed, prevGreen, prevBlue)
		love.graphics.print("you had "..self.board.scores[1].." survivors.", 115, 165)
		love.graphics.print("they had "..self.board.scores[2].." survivors.", 115, 185)
	end
end

return Puzzle