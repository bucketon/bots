AutoPlay = {}

function AutoPlay:setup()
	self.gameCount = 0
	self.AIWinCount = 0
	self:reset_()
end

function AutoPlay:reset_()
	self.player1Hand = {}
	self.player2Hand = {}
	self.deck = {}
	self.board = Gameboard:new()
	self:fillDeck()
	shuffle(self.deck)
	self:deal()
	self.board.deck = self.deck
	self.playerTurnsDone = false
	self.neutralBot = {}
end

function AutoPlay:keypressed(key)

end

function AutoPlay:update(dt)
	if self.gameCount < 1000 then
		if not self.playerTurnsDone then
			local move1 = AI:calculateTurnWeak(self.player1Hand, self.board)
			self.board:setTile(move1.space, self.player1Hand[move1.index])
			local handLength1 = #self.player1Hand
			self.player1Hand[move1.index] = nil
			defrag(self.player1Hand, handLength1)
			local move2 = AI:calculateTurn(self.player2Hand, self.board)
			self.board:setTile(move2.space, self.player2Hand[move2.index])
			local handLength2 = #self.player2Hand
			self.player2Hand[move2.index] = nil
			defrag(self.player2Hand, handLength2)
			self:endOfRound()
		else
			if self.board.winner == 0 then
				self.board:progress()
			else
				self.gameCount = self.gameCount + 1
				if self.board.winner == 2 then
					self.AIWinCount = self.AIWinCount + 1
				end
				log("AI has won "..self.AIWinCount.." times out of "..self.gameCount.." so far.")
				self:reset_()
			end
		end
	elseif self.gameCount == 100 then
		log("The AI won "..self.AIWinCount.." times out of 100!")
	end
end

function AutoPlay:deal()
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

function AutoPlay:fillDeck() --the classic bots set
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

function AutoPlay:endOfRound()
	if self.board:isBoardFull() then
		self.neutralBot.facedown = false
		self.playerTurnsDone = true
	end
end

function AutoPlay:draw()
	drawBoard(self.board, boardOffset)
	love.graphics.print("AI has won: \n"..self.AIWinCount.."/"..self.gameCount.." games.", 5, 5)
end

return AutoPlay
