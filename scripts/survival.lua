Survival = {}

function Survival:setup()
	if saveData.survivalScore == nil then
		saveData.survivalScore = 0
	end
	self.player1Hand = {}
	self.player2Hand = {}
	self.deck = {}
	self.board = Gameboard:new()
	self.deckPrototype = {
		Bots.Arcenbot,
		Bots.Recycler,
		Bots.Injector,
		Bots.Ratchet,
		Bots.EMPBot,
		Bots.SpyBot,
		Bots.Booster,
		Bots.LaserCannon,
		Bots.Thresher,
		Bots.Renegade
	}
	self:fillDeck()
	shuffle(self.deck)
	self.playerTurnsDone = false
	self.cursor = BoardCursor:new(self.board, self.player1Hand, {2, 2}, nil)
	self.player2TurnTimer = 0
	self.player2TurnTime = 50
	self.gameCount = 0
	self.neutralBot = nil
	self:deal()
	if saveData.SortHands then
		table.sort(self.player1Hand, function (left, right) return left.number < right.number end)
	end
	self.board.deck = self.deck
	self.player2HandPositions = {}
	for i=1,4 do
		self.player2HandPositions[i] = {boardOffset[1]+(i-1)*50, -50}
	end

	log("GAME START: Started a new survival game against the AI!")
end

function Survival:restart_()
	self.player1Hand = {}
	self.player2Hand = {}
	self.deck = {}
	self.board = self:copyBoard(self.board)
	self:fillDeck()
	shuffle(self.deck)
	self.playerTurnsDone = false
	self.cursor = BoardCursor:new(self.board, self.player1Hand, {2, 2}, nil)
	self.player2TurnTimer = 0
	self:deal()
	if saveData.SortHands then
		table.sort(self.player1Hand, function (left, right) return left.number < right.number end)
	end
	self.board.deck = self.deck
end

function Survival:deal()
	if self.board:getTile({2, 2}) == nil then
		local card = pop(self.deck)
		card.team = 3
		card.facedown = true
		self.neutralBot = card
		self.board:setTile({2, 2}, card)
	end
	self.deck = defrag(self.deck, 10)
	for i=1,#self.deck-1 do
		if i%2 == 1 then
			local card = pop(self.deck)
			card.team = 1
			push(self.player1Hand, card)
		else
			local card = pop(self.deck)
			card.team = 2
			push(self.player2Hand, card)
		end
	end
	self.player1Hand.maxLength = #self.player1Hand
end

function Survival:copyBoard(board)
	local ret = Gameboard:new()
	for x=1,self.board.boardWidth do
		for y=1,self.board.boardHeight do
			local card = board:getTile({x, y})
			if card ~= nil then
				local newCard = self.deckPrototype[card.number]:new()
				newCard.team = card.team
				ret:setTile({x, y}, newCard)
			end
		end
	end
	return ret
end

function Survival:fillDeck() --the classic bots set
	local unusedBots = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	for x=1,self.board.boardWidth do
		for y=1,self.board.boardHeight do
			local card = self.board:getTile({x, y})
			if card ~= nil then
				unusedBots[card.number] = nil
			end
		end
	end
	for i=1,10 do
		if unusedBots[i] ~= nil then
			push(self.deck, self.deckPrototype[unusedBots[i]]:new())
		end
	end
end

function Survival:keypressed(key)
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

	if key=="z" and self.player2TurnTimer == 0 then
		--run the fight
		if self.playerTurnsDone then
			if self.board.winner == 0 then
				self.board:progress()
			else
				--probably want to keep track of some high score biz
				if self.board.winner == 1 then
					self.gameCount = self.gameCount + 1
					if self.gameCount > saveData.survivalScore then
						saveData.survivalScore = self.gameCount
						save(saveData)
					end
					self:restart_()
				else
					--lost, kick them out all the way
					self:setup()
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
					self:endPlayer1Turn()
				end
			elseif self.cursor.place ~= nil then
				local tookTurn = false
				self.cursor, tookTurn = self.cursor:place()
				if tookTurn == true then
					self:endPlayer1Turn()
				end
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
end

function Survival:endPlayer1Turn()
	if self.board:isBoardFull() then
		self:endOfRound()
	else
		floatingCardRates = {math.random()*4.0, math.random()*4.0}
		self.player2TurnTimer = 1
		self.board:refresh()
	end
end

function Survival:update(dt)
	--make the AI player take time
	if self.player2TurnTimer > 0 then
		self.player2TurnTimer = self.player2TurnTimer + 1
		if self.player2TurnTimer > self.player2TurnTime then
			self:takePlayer2Turn()
			self.player2TurnTimer = 0
		end
	end
end

function Survival:cleanupScores()
	if #saveData.score > 2*relevantScoresCount then
		for i=1,(#saveData.score - relevantScoresCount) do
			saveData.score[i] = nil
		end
		saveData.score = defrag(saveData.score, relevantScoresCount)
	end
end

function Survival:takePlayer2Turn()
	DEBUG_LOGGING_ON = false --todo: come up with something better
	local move = AI:calculateTurn(self.player2Hand, self.board)
	DEBUG_LOGGING_ON = true
	self.board:setTile(move.space, self.player2Hand[move.index])
	local handLength = #self.player2Hand
	self.player2Hand[move.index] = nil
	defrag(self.player2Hand, handLength)
	self:endOfRound()
end

function Survival:endOfRound()
	if self.board:isBoardFull() then
		self.neutralBot.facedown = false
		self.playerTurnsDone = true
		self.currentInstructions = 3
		log("Combat starts!")
		log("The board at the start of combat:")
		log(self.board:toString())
	end
	self.board:refresh()
end

function Survival:draw()    
	drawBoard(self.board, boardOffset)
	drawCursorAndHand(self.cursor)

	--AI hand
	for i=1,4 do
		if self.player2Hand[i] ~= nil then
			love.graphics.draw(cardback, self.player2HandPositions[i][1], self.player2HandPositions[i][2])
		end
	end

	love.graphics.print("current streak: "..self.gameCount, 0, -3)

	--victory
	if self.board.winner ~= 0 then
		if self.board.winner == 1 then
			love.graphics.draw(player1wins, 0, 88)
		elseif self.board.winner == 2 then
			love.graphics.draw(player2wins, 0, 88)
		elseif self.board.winner == 3 then
			love.graphics.draw(nbwins, 0, 88)
		end
		local prevRed, prevGreen, prevBlue = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 105, 155, 210, 60)
		love.graphics.setColor(prevRed, prevGreen, prevBlue)
		love.graphics.print("you had "..self.board.scores[1].." survivors.", 115, 165)
		love.graphics.print("they had "..self.board.scores[2].." survivors.", 115, 185)
	end
end

return Survival