Puzzle = {}

function Puzzle:setup()
	if saveData.currentPuzzle == nil then
		saveData.currentPuzzle = 1
	end
	self.puzzleList = require('scripts/puzzle_list')

	self:startPuzzle(self.puzzleList[saveData.currentPuzzle])
end

function Puzzle:startPuzzle(puzzle)
	self.player1Hand = deepCopy(puzzle.hand)
	for i=1,#self.player1Hand do
		self.player1Hand[i].team = 1
	end
	self.deck = deepCopy(puzzle.deck)
	self.board = Gameboard:new()--this comes from the level
	for i=1,#puzzle.board do
		local card = puzzle.board[i].bot
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
end

function Puzzle:keypressed(key)
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
					saveData.currentPuzzle = saveData.currentPuzzle + 1
					save(saveData)
				end
				self:startPuzzle(self.puzzleList[saveData.currentPuzzle])
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
			elseif self.cursor.pickup ~= nil and self.cursor.selectedCard == nil then
				self.cursor = self.cursor:pickup()
			end
		end
	end

	if key=="x" then
		--put card back in hand if card picked up
		if self.cursor.replace ~= nil and self.cursor.selectedCard ~= nil then
			self.cursor = self.cursor:replace()
		end
	end
end

function Puzzle:update(dt)

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
end

return Puzzle