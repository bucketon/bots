ClassicOnlineMode = {}

function ClassicOnlineMode:setup()
	push(currentMode, require("scripts/network"))
	currentMode[#currentMode]:setup()
	self.lastEvent = {}
end

function ClassicOnlineMode:start(host, peer)
	self.host = host
	self.player1Hand = {}
	self.player1Hand.n = 4
	self.player2Hand = {}
	self.player2Hand.n = 4
	self.deck = {}
	self.board = Gameboard:new()
	self.neutralBot = nil
	self.lastMove = {}
	self.enemyTurn = false
	self.peer = nil
	self.isHost = false
	if self.gameCount == nil then self.gameCount = 0 end
	if self.playerWinCount == nil then self.playerWinCount = 0 end
	local rand = math.random(2)-1
	local second = rand == 1

	if peer ~= nil then
		self.peer = peer
		if saveData.deck == nil then
			saveData.deck = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
			save(saveData)
		end
		self.deckPrototype = deepCopy(saveData.deck)
		shuffle(self.deckPrototype)
		self:fillDeck()
		peer:send(self:serializeStart(self.deckPrototype, second))
		self:deal(1)
		if second then
			self.enemyTurn = true
		else
			self.enemyTurn = false
		end
	else
		self.isHost = true
		local first = 0
		if self.lastEvent[1] == nil then
			self.deck, first = self:deserializeStart(self:waitForReceive())
		else
			self.peer = self.lastEvent[1].peer
			self.deck, first = self:deserializeStart(self.lastEvent[1].data)
			local size = #self.lastEvent
			self.lastEvent[1] = nil
			defrag(self.lastEvent, size)
		end
		self:deal(0)
		if first == true then
			self.enemyTurn = false
		else
			self.enemyTurn = true
		end
	end

	if saveData.SortHands then
		table.sort(self.player1Hand, function (left, right) return left.number < right.number end)
	end

	self.board.deck = self.deck
	self.playerTurnsDone = false
	self.cursor = BoardCursor:new(self.board, self.player1Hand, {2, 2}, nil)

	self.player2HandPositions = {}
	for i=1,4 do
		self.player2HandPositions[i] = {boardOffset[1]+(i-1)*50, -50}
	end	
end

function ClassicOnlineMode:waitForReceive()
	local event = nil
	while event == nil do
		event = self.host:service()
		if event ~= nil and event.type == "receive" then
			if self.peer == nil then self.peer = event.peer end
			log(event.data)
			return event.data
		end
	end
end

function ClassicOnlineMode:deal(mod)
	for i=1,#self.deck-1 do
		if i == 1 then
			local card = pop(self.deck)
			card.team = 3
			card.facedown = true
			self.neutralBot = card
			self.board:setTile({2, 2}, card)
		elseif i%2 == mod then
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

function ClassicOnlineMode:fillDeck() --the classic bots set
	for i=1,#self.deckPrototype do
		self.deck[i] = AllBots[self.deckPrototype[i]]:new()
	end
	--[[self.deck[1] = Bots.Arcenbot:new()
	self.deck[2] = Bots.Recycler:new()
	self.deck[3] = Bots.Injector:new()
	self.deck[4] = Bots.Ratchet:new()
	self.deck[5] = Bots.EMPBot:new()
	self.deck[6] = Bots.SpyBot:new()
	self.deck[7] = Bots.Booster:new()
	self.deck[8] = Bots.LaserCannon:new()
	self.deck[9] = Bots.Thresher:new()
	self.deck[10] = Bots.Renegade:new()]]--
end

function ClassicOnlineMode:keypressed(key)
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

	if key=="z" and self.enemyTurn == false then
		--run the fight
		if self.playerTurnsDone then
			if self.board.winner == 0 then
				self.board:progress()
			else
				self.gameCount = self.gameCount + 1
				if self.board.winner == 1 then
					self.playerWinCount = self.playerWinCount + 1
				end
				if self.lastEvent[#self.lastEvent] == nil then
					self:start(self.host, self.peer)
				else
					self:start(self.host, nil)
				end
			end
		else
			--pick up card if in hand, put down card if on empty board space
			if self.cursor.bookmark ~= nil and self.cursor.board:getTile(self.cursor.coord) == nil and 
				self.cursor.selectedCard == nil then
					self.cursor = self.cursor:bookmark()
			elseif self.cursor.grab ~= nil then
				local tookTurn = false
				self.lastMove.space = self.cursor.mark
				self.lastMove.number = self.cursor.hand[self.cursor.index].number
				self.cursor, tookTurn = self.cursor:grab()
				if tookTurn == true then
					self:endPlayer1Turn()
				end
			elseif self.cursor.place ~= nil and self.cursor.selectedCard ~= nil then
				local tookTurn = false
				self.lastMove.x = self.cursor.coord[1]
				self.lastMove.y = self.cursor.coord[2]
				self.lastMove.number = self.cursor.selectedCard.number
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

function ClassicOnlineMode:endPlayer1Turn()
	local move = self:serializeMove(self.lastMove.number, {self.lastMove.x, self.lastMove.y})
	self.peer:send(move)
	floatingCardRates = {math.random()*4.0, math.random()*4.0}
	self:endOfRound()
	self.enemyTurn = true
end

function ClassicOnlineMode:update(dt)
	if self.enemyTurn == true then
		local event = pop(self.lastEvent)
		if event == nil then
			event = self.host:service()
		end
		while event ~= nil do
			if event ~= nil and event.type == "receive" then
				self:finishPlayer2Turn(self:deserializeMove(event.data))
			end
			event = pop(self.lastEvent)
			if event == nil then
				event = self.host:service()
			end
		end
	else
		if frameCount % 100 == 0 then
			--call service to keep alive
			local event = self.host:service()
			if event ~= nil then
				push(self.lastEvent, event)
			end
		end
	end
	if self.board:isBoardFull() == true then
		self.enemyTurn = false
	end
end

function ClassicOnlineMode:finishPlayer2Turn(move)
	self.enemyTurn = false
	local index = 0
	for i=1,4 do
		if self.player2Hand[i] ~= nil and self.player2Hand[i].number == move.number then
			index = i
		end
	end
	self.board:setTile(move.space, self.player2Hand[index])
	self.player2Hand[index] = nil
	self.player2Hand = defrag(self.player2Hand, 4)
	self:endOfRound()
end

function ClassicOnlineMode:endOfRound()
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

function ClassicOnlineMode:draw()    
	drawBoard(self.board, boardOffset)
	drawCursorAndHand(self.cursor)

	--opponent turn indicator
	if self.enemyTurn == true then
		love.graphics.draw(busyIndicator, 400/2 - busyIndicator:getWidth()/2, 240/2 - busyIndicator:getHeight()/2)
	end

	--score
	love.graphics.print("Won "..self.playerWinCount.."/"..self.gameCount.."games.", 0, 0)

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
		love.graphics.rectangle("fill", 105, 155, 210, 60)
		love.graphics.setColor(prevRed, prevGreen, prevBlue)
		love.graphics.print("you had "..self.board.scores[1].." survivors.", 115, 165)
		love.graphics.print("they had "..self.board.scores[2].." survivors.", 115, 185)
	end
end

function ClassicOnlineMode:onExit()
	self.peer:disconnect()
end

function ClassicOnlineMode:serializeStart(deck, first)
	local ret = ""
	for i=1,#deck do
		ret = ret..deck[i]..","
	end
	local firstString = "0"
	if first == true then firstString = "1" end
	ret = ret..firstString
	return ret
end

function string:split(pattern)
  local ret = {}
  local start = 1
  local index = string.find(self, pattern, start)
  while index do
    push(ret, string.sub(self, start, index - 1))
    start = index + 1
    index = string.find(self, pattern, start)
  end
  push(ret, string.sub(self, start, #self))
  return ret
end

function ClassicOnlineMode:deserializeStart(deck)
	log("deck is "..deck)
	local list = deck:split(",")
	local first = pop(list) == "1"
	local retDeck = self:toBots(list)
	return retDeck, first
end

function ClassicOnlineMode:toBots(list)
	local ret = {}
	for i=1,#list do
		push(ret, self:toBot(list[i]))
	end
	return ret
end

function ClassicOnlineMode:toBot(number)
	log("toBot called with "..number..".")
	return AllBots[tonumber(number)]:new()
	--[[if number == "1" or number == 1 then
		return Bots.Arcenbot:new()
	elseif number == "2" or number == 2 then
		return Bots.Recycler:new()
	elseif number == "3" or number == 3 then
		return Bots.Injector:new()
	elseif number == "4" or number == 4 then
		return Bots.Ratchet:new()
	elseif number == "5" or number == 5 then
		return Bots.EMPBot:new()
	elseif number == "6" or number == 6 then
		return Bots.SpyBot:new()
	elseif number == "7" or number == 7 then
		return Bots.Booster:new()
	elseif number == "8" or number == 8 then
		return Bots.LaserCannon:new()
	elseif number == "9" or number == 9 then
		return Bots.Thresher:new()
	elseif number == "10" or number == 10 then
		return Bots.Renegade:new()
	else
		return nil
	end]]--
end

function ClassicOnlineMode:serializeMove(number, space)
	local ret = number..","..space[1]..","..space[2]
	log("Send move: "..ret)
	return ret
end

function ClassicOnlineMode:deserializeMove(move)
	log("Receive move: "..move)
	local ret = {}
	local message = move:split(",")
	ret.number = tonumber(message[1])
	ret.space = {tonumber(message[2]), tonumber(message[3])}
	return ret
end

return ClassicOnlineMode
