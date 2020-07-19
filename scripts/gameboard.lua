Gameboard = {
	board = {{}, {}, {}},
	currentbot = 1,
	boardWidth = 3,
	boardHeight = 3,
	deathsThisAttack = {},
	winner = 0,
	scores = {0, 0, 0},
	nextAttacker = 0,
	deck = nil,
	combatStep = 0,
	lowestLowBot = 10,
	combatFrames = {}
}

function Gameboard:new()
    o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = function (table, key)
      return self[key]
    end
    o.board = {{}, {}, {}}
    o.nextAttacker = 0
    o.winner = 0
    o.scores = {0, 0, 0}
    o.lowestLowBot = 10
    o.combatStep = 0
    o.combatFrames = {}
    return o
end

function Gameboard:getTile(coord)
	if coord == nil or coord[1] < 1 or coord[1] > self.boardWidth or coord[2] < 1 or coord[2] > self.boardHeight then return nil end
	return self.board[coord[1]][coord[2]] 
end

function Gameboard:getBotPosition(number)
	for x=1,self.boardWidth do
		for y=1,self.boardHeight do
			if self:getTile({x, y}) ~= nil and self:getTile({x, y}).number == number then
				return {x, y}
			end
		end
	end
	return nil
end

function Gameboard:setTile(coord, value)
	if coord[1] < 1 or coord[1] > self.boardWidth or coord[2] < 1 or coord[2] > self.boardHeight then return false end
	self.board[coord[1]][coord[2]] = value
	return true
end

function Gameboard:getEmptySpaces()
	local emptySpaces = {}
	for x=1,self.boardWidth do
		for y=1,self.boardHeight do
			if self.board[x][y] == nil then
				emptySpaces[#emptySpaces+1] = {x, y}
			end
		end
	end
	return emptySpaces
end

function Gameboard:isBoardFull()
	for x=1,self.boardWidth do
		for y=1,self.boardHeight do
			if self.board[x][y] == nil then return false end
		end
	end
	self:startCombat()
	return true
end

function Gameboard:startCombat()
	self.combatStep = 1
end

function Gameboard:progress()--solve one turn of combat
	push(self.combatFrames, 
	{
		board = deepCopy(self.board),
		deck = deepCopy(self.deck),
		currentbot = self.currentbot,
		winner = self.winner,
		combatStep = self.combatStep,
		nextAttacker = self.nextAttacker
	}
	)
	self.combatStep = self.combatStep + 1
	log("TURN START: Starting a new turn for bot number "..self.currentbot..".")

	local recall = false

	self:refresh()

	self.deathsThisAttack = {}

	local currentBotPosition = self:findNextBotPosition_()
	if currentBotPosition ~= nil then
		local currentBotStruct = self:getTile(currentBotPosition)
		if currentBotStruct ~= nil then
			log("Turn "..self.currentbot.."'s bot is "..currentBotStruct.name..".")

			currentBotStruct:preAttack(self)

			--get all of the current bots neighbors
			local neighbors = currentBotStruct:getNeighbors(self, currentBotPosition)
			neighbors = defrag(neighbors, neighbors.n)
			neighbors.n = #neighbors

			--debug stuff
			local neighborsLog = ""
			for i=1,neighbors.n do
				if neighbors[i] ~= nil then
					local delimiter = ", "
					if i == neighbors.n then
						delimiter = ""
					elseif i == neighbors.n-1 then
						delimiter = ", and "
					end
					neighborsLog = neighborsLog..neighbors[i].name..delimiter
				end
			end
			log(currentBotStruct.name.."'s neighbors are: "..neighborsLog..".")

			--compute each attack
			for i=1,neighbors.n do
				local neighbor = neighbors[i]
				if neighbor ~= nil then

					--debug stuff
					neighbor.animation = true

					currentBotStruct:attack(self, neighbor)

				end
			end

			self:refresh()
			currentBotStruct:postAttack(self)
		else
			recall = true
		end
	else
		recall = true
	end

	if self.currentbot > 10 then
		if self.winner == 0 then
			self:declareWinner()
			return
		end
	end

	self:refresh()

	if recall ~= true then return end
	log("Automatically progressing because bot number "..(self.currentbot-1).." wasn't on the board.")
	self:progress()
end

function Gameboard:regress()--go backwards one turn of combat
	local previousBoard = pop(self.combatFrames)
	self.board = previousBoard.board
	self.currentbot = previousBoard.currentbot
	self.winner = previousBoard.winner
	self.deck = previousBoard.deck
	self.combatStep = previousBoard.combatStep
	self.nextAttacker = previousBoard.nextAttacker
end

function Gameboard:refresh()
	log("Clearing all buffs and debuffs.")
	local botList = {}
	for x=1,self.boardWidth do 
		for y=1,self.boardHeight do
			if self:getTile({x, y}) ~= nil then 
				self.board[x][y].tempMods = 0
				self.board[x][y].EMP = false
				self.board[x][y].paralysis = false
				self.board[x][y].animation = false
				push(botList, self.board[x][y])
			end 
		end
	end

	table.sort (botList, function (left, right) return left.number < right.number end )

	for i=1,#botList do
		if botList[i].facedown == false then
			botList[i]:tick(self)
		end
	end

	if #botList > 0 and self.combatStep > 0 then
		for i=1,#botList do
			if botList[i].number >= self.currentbot then
				self.nextAttacker = botList[i].number
				break
			end
		end
	end
end

function Gameboard:declareWinner()
	local lowestBots = {10, 10, 10}
	for x=1,self.boardWidth do
		for y=1,self.boardHeight do
			local bot = self:getTile({x, y})
				if bot ~= nil then
					self.scores[bot.team] = self.scores[bot.team] + bot:score(self)
				if bot.number < lowestBots[bot.team] then lowestBots[bot.team] = bot.number end
			end
		end
	end

	local highest = math.max(self.scores[1], self.scores[2], self.scores[3])
	local tiedPlayers = {}

	for i=1,3 do
		if highest == self.scores[i] then
			tiedPlayers[#tiedPlayers+1] = i 
		end
	end

	self.lowestLowBot = 10
	for i=1,#tiedPlayers do
		if lowestBots[tiedPlayers[i]] < self.lowestLowBot then
			self.lowestLowBot = lowestBots[tiedPlayers[i]]
			self.winner = tiedPlayers[i]
		end
	end

	if self.winner == 0 then self.winner = 4 end

	if self.winner == 4 then
		log("A tie game! How rare!")
	elseif winner == 3 then
		log("The neutral bot wins with "..highest.." survivors!")
	elseif #tiedPlayers > 1 then
		log("Since two or more players had "..highest.." survivors, the lowest number survivor wins, so player "
			..self.winner.." wins with "..self.lowestLowBot.."!")
	else
		log("Since player one had "..self.scores[1].." survivors, and player two had "..
			self.scores[2].." survivors, player "..self.winner.." wins!")
	end
end

function Gameboard:toString()
	local boardString = "\n"
	boardString = boardString..self:printLine_()
	for y=1,self.boardHeight do
		local row = {}
		for x=1,self.boardWidth do
			row[x] = self:getTile({x, y})
		end
		boardString = boardString..self:printSquares_(row)
		boardString = boardString..self:printLine_()
	end
	return boardString
end

function Gameboard:printLine_()
	--prints a solid divider line for the board
	local line = "|"
	for i=1,self.boardWidth do
		line = line.."---|"
	end
	return line.."\n"
end

function Gameboard:printSquares_(row)
	--prints a row of bot structs
	local rowString = ""
	--print the top row of characters
	local line = "|"
	for i=1,self.boardWidth do
		local teamIndicator = " "
		if row[i].team == 2 then
			teamIndicator = "^"
		end
		line = line.." "..teamIndicator.." |"
	end
	rowString = rowString..line.."\n"
	--print the second row of characters
	line = "|"
	for i=1,self.boardWidth do
		local teamIndicator = " "
		if row[i].team == 3 then
			teamIndicator = "<"
		end
		line = line..teamIndicator..(row[i].number%10).." |"
	end
	rowString = rowString..line.."\n"
	--print the bottom row of characters
	line = "|"
	for i=1,self.boardWidth do
		local teamIndicator = " "
		if row[i].team == 1 then
			teamIndicator = "v"
		end
		line = line.." "..teamIndicator.." |"
	end
	rowString = rowString..line.."\n"
	return rowString
end

function Gameboard:findNextBotPosition_()
	local position = self:getBotPosition(self.currentbot)
	self.currentbot = self.currentbot + 1
	return position
end

return Gameboard