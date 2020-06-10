VsAIMode = {}

function VsAIMode:setup()
	self.floatingCardOffset = {0, 0}
	self.floatingCardRates = {0, 0}
	self.player1Hand = {}
	self.player2Hand = {}
	self.deck = {}
	self.board = Gameboard:new()
	self:fillDeck()
	shuffle(self.deck)
	self:deal()
	self.board.deck = self.deck
	self.frameCount = 0
	self.cursorCoord = {2, 2}
	self.handSelected = 0
	self.boardSelected = {0, 0}
	self.playerTurnsDone = false
	self.selectedCard = nil
	self.currentInstructions = 1
	self.player2TurnTimer = 0
	self.player2TurnTime = 50
	self.gameCount = 0
	self.AIWinCount = 0
	self.neutralBot = {}

	self.boardTilePositions = {}
	for x=1,self.board.boardWidth do
		self.boardTilePositions[x] = {}
		for y=1,self.board.boardHeight do
			self.boardTilePositions[x][y] = 
			{(boardTileDimensions[1]+boardTilePadding)*(x-1)+boardOffset[1],
			 (boardTileDimensions[2]+boardTilePadding)*(y-1)+boardOffset[2]}
		end
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
end

function VsAIMode:fillDeck() --the classic bots set
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
end

function VsAIMode:keypressed(key)
	if key=="left" then
		if self.handSelected > 1 then 
			self.handSelected = self.handSelected - 1 
		end
		self.cursorCoord[1] = math.max(1, self.cursorCoord[1]-1)
	end
	if key=="right" then
		if self.handSelected > 0 and self.handSelected < #self.player1Hand then 
			self.handSelected = self.handSelected + 1 
		end
		self.cursorCoord[1] = math.min(self.board.boardWidth, self.cursorCoord[1]+1)
	end
	if key=="up" then
		if self.handSelected > 0 then 
			self.handSelected = 0 
			self.cursorCoord[2] = self.board.boardHeight
			self.boardSelected = {0, 0}
		else
			self.cursorCoord[2] = math.max(1, self.cursorCoord[2]-1)
		end
	end
	if key=="down" then
		if self.cursorCoord[2] == self.board.boardHeight and self.selectedCard == nil and self.handSelected == 0 then
		 	self.handSelected = math.min(self.cursorCoord[1], #self.player1Hand)
		end
		self.cursorCoord[2] = math.min(self.board.boardHeight, self.cursorCoord[2]+1)
	end

	if key=="z" and self.player2TurnTimer == 0 then
		--run the fight
		if self.playerTurnsDone then
			if self.board.winner == 0 then
				self.currentInstructions = 3
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
		end
		--pick up card if in hand, put down card if on empty board space
		if self.handSelected > 0 and self.selectedCard == nil then
			log("Selected card number "..self.handSelected.." in hand.")
			self.floatingCardRates = {math.random()*4.0, math.random()*4.0}
			self.selectedCard = self.player1Hand[self.handSelected]
			self.player1Hand[self.handSelected] = nil
			self.handSelected = 0
			self.currentInstructions = 2
			if not areEqual(self.boardSelected, {0, 0}) then
				self.cursorCoord = {self.boardSelected[1], self.boardSelected[2]}
				self.boardSelected = {0, 0}
			end
		elseif self.selectedCard ~= nil and self.handSelected == 0 and self.board:getTile(self.cursorCoord) == nil then
			log("Player 1 placed "..self.selectedCard.name.." on the board at ["..self.cursorCoord[1]..", "..self.cursorCoord[2].."].")
			self.board:setTile(self.cursorCoord, self.selectedCard)
			self.selectedCard = nil
			self.player1Hand = defrag(self.player1Hand, 4)
			self.currentInstructions = 1
			self.player2TurnTimer = 1
			self.board:refresh()
		elseif self.selectedCard == nil and self.handSelected == 0 and self.board:getTile(self.cursorCoord) == nil then
			self.handSelected = 1
			self.boardSelected = {self.cursorCoord[1], self.cursorCoord[2]}
		end
	end

	if key=="x" then
		--put card back in hand if card picked up
		if self.selectedCard ~= nil then
			local index = self:returnCard(self.selectedCard)
			self.selectedCard = nil
			self.handSelected = index
			self.currentInstructions = 1
		else
			self.handSelected = 1
		end
	end
end

function VsAIMode:update(dt)
	self.frameCount = self.frameCount + 1

	--float the selected card around a bit
	for i=1,2 do
		self.floatingCardOffset[i] = (math.sin(self.frameCount/200.0*self.floatingCardRates[i])*2.0) - 1.0
	end

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
		saveData.score = defrag(saveData.score)
	end
end

function VsAIMode:takePlayer2Turn()
	DEBUG_LOGGING_ON = false --todo: come up with something better
	local move = AI:calculateTurn(self.player2Hand, self.board)
	DEBUG_LOGGING_ON = true
	self.board:setTile(move.space, self.player2Hand[move.index])
	local handLength = #self.player2Hand
	self.player2Hand[move.index] = nil
	defrag(self.player2Hand, handLength)
	self:endOfRound()
end

function VsAIMode:endOfRound()
	if self.board:isBoardFull() then
		self.neutralBot.facedown = false--check this
		self.playerTurnsDone = true
		self.currentInstructions = 3
		log("Combat starts!")
		log("The board at the start of combat:")
		log(self.board:toString())
	end
	self.board:refresh()
end

function VsAIMode:returnCard(card)
	for i=1,4 do
		if self.player1Hand[i] == nil then
			self.player1Hand[i] = card
			return i
		end
	end
end

function VsAIMode:draw()
	drawBoard(self.board, boardOffset)
	--draw ability
	local selectedBot = self.board:getTile(self.cursorCoord)
	if(selectedBot ~= nil and selectedBot.facedown == true) then
		love.graphics.draw(neutralBotCard, 0, 0)
	else
		if self.handSelected > 0 then
			selectedBot = self.player1Hand[self.handSelected]
		end
		if selectedBot ~= nil then
			--selectedBot is the one under the cursor, selectedCard is the one we're holding :P
			love.graphics.draw(selectedBot.image, 0, 0)
			local bonusStrength = selectedBot:getTotalStrength() - selectedBot.number
			if bonusStrength ~= 0 then
				love.graphics.draw(strengthBonus[bonusStrength], 20, 50)
			end
			if selectedBot.EMP == true then
				love.graphics.draw(empIndicator, 23, 157)
			end
		elseif self.selectedCard ~= nil then
			love.graphics.draw(self.selectedCard.image, 0, 0)
		end
	end

	--cursor
	if self.handSelected == 0 then
		local cursorCard = self.board:getTile(self.cursorCoord)
		if self.cursorCard == nil then
			love.graphics.draw(spaceCursor, self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][1], 
				self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][2])
		else
			love.graphics.draw(cardCursor, self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][1], 
				self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][2])
		end
	elseif not areEqual(self.boardSelected, {0, 0}) then
		love.graphics.draw(spaceCursor, self.boardTilePositions[self.boardSelected[1]][self.boardSelected[2]][1], 
				self.boardTilePositions[self.boardSelected[1]][self.boardSelected[2]][2])
	end

	--selected card
	if self.selectedCard ~= nil then
		local cardCoord = {self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][1]+math.floor(self.floatingCardOffset[1])+5, 
						   self.boardTilePositions[self.cursorCoord[1]][self.cursorCoord[2]][2]+math.floor(self.floatingCardOffset[2])+5}
		love.graphics.draw(shadow, cardCoord[1]-5, cardCoord[2]-5)
		drawMiniCard(self.selectedCard, cardCoord)
	end

	--hands
	for i=1,4 do --todo: allow different hand sizes
		local selectedOffset = 0
		if self.handSelected == i then
			selectedOffset = 30
		end
		local player1Bot = self.player1Hand[i]
		if player1Bot ~= nil then
			drawMiniCard(player1Bot, {player1HandPositions[i][1], player1HandPositions[i][2] - selectedOffset})
		end
		local player2Bot = self.player2Hand[i]
		if player2Bot ~= nil then
			love.graphics.draw(cardback, player2HandPositions[i][1], player2HandPositions[i][2])
		end
	end

	--instructions
	love.graphics.draw(instructions[self.currentInstructions], 0, 224)
	love.graphics.draw(arrowInstructions, 0, 0)

	--victory
	if self.board.winner ~= 0 then
		if self.board.winner == 1 then
			love.graphics.draw(player1wins, 0, 88)
		elseif self.board.winner == 2 then
			love.graphics.draw(player2wins, 0, 88)
		elseif self.board.winner == 3 then
			love.graphics.draw(nbwins, 0, 88)
		end
	end
end

return VsAIMode
