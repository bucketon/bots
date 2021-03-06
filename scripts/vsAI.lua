VsAIMode = {}

function VsAIMode:setup()
	self.player1Hand = {}
	self.player2Hand = {}
	self.deck = {}
	self.board = Gameboard:new()
	self:fillDeck()
	shuffle(self.deck)
	self.board.deck = self.deck
	self.playerTurnsDone = false
	self.cursor = BoardCursor:new(self.board, self.player1Hand, {2, 2}, nil)
	self.player2TurnTimer = 0
	self.player2TurnTime = 50
	self.gameCount = 0
	self.AIWinCount = 0
	self.neutralBot = nil
	self:deal()
	if saveData.SortHands then
		table.sort(self.player1Hand, function (left, right) return left.number < right.number end)
	end
	self.player2HandPositions = {}
	for i=1,4 do
		self.player2HandPositions[i] = {boardOffset[1]+(i-1)*50, -50}
	end

	log("GAME START: Started a new game against the AI!")
end

function VsAIMode:restart_()
	self:setup()
end

function VsAIMode:deal()
	for i=1,#self.deck-1 do
		if i == 1 then
			local card = pop(self.deck)
			card.team = 3
			card.facedown = true
			self.neutralBot = card
			self.board:setTile({2, 2}, card)
		elseif i%2 == 1 then
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

function VsAIMode:fillDeck() --the classic bots set
	if saveData.deck == nil then
		self.deck[1] = Bots.Arcenbot:new()
		self.deck[2] = Bots.Recycler:new()
		self.deck[3] = Bots.Injector:new()
		self.deck[4] = Bots.Ratchet:new()
		self.deck[5] = Bots.EMPBot:new()
		self.deck[6] = Bots.SpyBot:new()
		self.deck[7] = Bots.Booster:new()
		self.deck[8] = Bots.LaserCannon:new()
		self.deck[9] = Bots.Thresher:new()
		self.deck[10] = Bots.Renegade:new()
	else
		for i=1,#saveData.deck do
			self.deck[i] = AllBots[saveData.deck[i]]:new()
		end
	end
end

function VsAIMode:keypressed(key)
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
				self.gameCount = self.gameCount + 1
				if self.board.winner == 2 then
					self.AIWinCount = self.AIWinCount + 1
				end
				--log("AI has won "..AIWinCount.." times out of "..gameCount.." so far.")
				if saveData.score == nil then
					saveData.score = {}
				end
				if self.board.winner == 1 then
					saveData.score[#saveData.score+1] = 1
				else
					saveData.score[#saveData.score+1] = 0
				end
				self:cleanupScores()
				save(saveData)
				self:restart_()
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
		elseif self.board.combatStep > 1 then
			self.board:regress()
		else
			push(currentMode, PauseMode)
			currentMode[#currentMode]:setup()
		end
	end
end

function VsAIMode:endPlayer1Turn()
	floatingCardRates = {math.random()*4.0, math.random()*4.0}
	self.player2TurnTimer = 1
	self.board:refresh()
end

function VsAIMode:update(dt)
	--make the AI player take time
	if self.player2TurnTimer > 0 then
		self.player2TurnTimer = self.player2TurnTimer + 1
		if self.player2TurnTimer > self.player2TurnTime then
			self:takePlayer2Turn()
			self.player2TurnTimer = 0
		end
	end
end

function VsAIMode:cleanupScores()
	if #saveData.score > 2*relevantScoresCount then
		for i=1,(#saveData.score - relevantScoresCount) do
			saveData.score[i] = nil
		end
		saveData.score = defrag(saveData.score, relevantScoresCount)
	end
end

function VsAIMode:takePlayer2Turn()
	DEBUG_LOGGING_ON = false --todo: come up with something better
	local move = AI:calculateTurn(self.player2Hand, self.board)
	DEBUG_LOGGING_ON = true
	self.board:setTile(move.space, self.player2Hand[move.index])
	local handLength = #self.player2Hand
	self.player2Hand[move.index] = nil
	self.player2Hand = defrag(self.player2Hand, handLength)
	self:endOfRound()
end

function VsAIMode:endOfRound()
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

function VsAIMode:draw()    
	drawBoard(self.board, boardOffset)
	drawCursorAndHand(self.cursor)

	--AI hand
	for i=1,4 do
		if self.player2Hand[i] ~= nil then
			love.graphics.draw(cardback, self.player2HandPositions[i][1], self.player2HandPositions[i][2])
		end
	end

	--victory
	if self.board.winner ~= 0 then
		if self.board.winner == 1 then
			love.graphics.draw(player1wins, 0, 70)
		elseif self.board.winner == 2 then
			love.graphics.draw(player2wins, 0, 70)
		elseif self.board.winner == 3 then
			love.graphics.draw(nbwins, 0, 70)
		end
		local prevRed, prevGreen, prevBlue = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 55, 135, 274, 85)
		love.graphics.setColor(prevRed, prevGreen, prevBlue)
		love.graphics.rectangle("line", 55, 135, 274, 85)
		love.graphics.print("you had "..self.board.scores[1].." survivors.", 60, 156)
		love.graphics.print("they had "..self.board.scores[2].." survivors.", 60, 176)
		love.graphics.print("Lowbot", 260, 135)
		drawMiniCard(self.board:getTile(self.board:getBotPosition(self.board.lowestLowBot)), {262, 153})
	end
end

return VsAIMode
