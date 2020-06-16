Sandbox = {}

function Sandbox:setup()
	self:restart_()
end

function Sandbox:restart_()
	self.player1Hand = {}
	self.deck = {}
	self.board = Gameboard:new()
	self:fillDeck()
	self:deal()
	self.cursor = HandCursor:new(self.board, self.player1Hand, 1, nil)
	self.board.deck = self.player1Hand
	self.playerTurnsDone = false
	self.determineTeam = false
	self.board:refresh()
end

function Sandbox:keypressed(key)
	if self.determineTeam == true then
		if key=="left" then
			local card = self.board:getTile(self.cursor.coord)
			card.team = 3
		end
		if key == "up" then
			local card = self.board:getTile(self.cursor.coord)
			card.team = 2
		end
		if key == "down" then
			local card = self.board:getTile(self.cursor.coord)
			card.team = 1
		end
		if key=="z" then
			self.determineTeam = false
			self:endOfRound()
		end
		if key=="x" then
			self.determineTeam = false
			self.cursor = self.cursor:pickup()
		end
	else
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
						self.determineTeam = true
					end
				elseif self.cursor.place ~= nil and self.cursor.selectedCard ~= nil then
					local tookTurn = false
					self.cursor, tookTurn = self.cursor:place()
					if tookTurn == true then
						self.determineTeam = true
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
			else
				push(currentMode, PauseMode)
				currentMode[#currentMode]:setup()
			end
		end
	end
end

function Sandbox:update(dt)

end

function Sandbox:deal()
	for i=1,#self.deck do
		local card = pop(self.deck)
		card.team = 1
		push(self.player1Hand, card)
	end
end

function Sandbox:fillDeck() --the classic bots set
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

function Sandbox:endOfRound()
	if self.board:isBoardFull() then
		self.playerTurnsDone = true
		self.board.deck = self.cursor.hand
	end
	self.board:refresh()
end

function Sandbox:draw()
	drawBoard(self.board, boardOffset)
	drawCursor(self.cursor)
	drawHand(self.cursor.hand, self.cursor.index, {1, 220}, 37)

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

return Sandbox
