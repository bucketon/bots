Arcenbot = Bot:new()
Arcenbot.name = "Arcenbot"
Arcenbot.image = love.graphics.newImage("arcenbot.png")
Arcenbot.mini = love.graphics.newImage("arcenbot_mini.png")
Arcenbot.number = 1
function Arcenbot:score_(board)
	log(self.name.."'s special ability activated, causing it to score more points.")
	return 2
end

Recycler = Bot:new()
Recycler.name = "Recycler"
Recycler.image = love.graphics.newImage("recycler.png")
Recycler.mini = love.graphics.newImage("recycler_mini.png")
Recycler.number = 2
function Recycler:die_(board)
	board.deathsThisAttack = board.deathsThisAttack + 1
	log("NUMBER OF BOTS AVAILABLE FOR RECYCLER: "..#board.deck)
	local newBot = board.deck[#deck]
	newBot.team = self.team
	board:setTile(board:getBotPosition(self.number), newBot)
	log(self.name.."'s ability activated, causing it to come back to life as "..newBot.name..".")
end

Injector = Bot:new()
Injector.name = "Injector"
Injector.image = love.graphics.newImage("injector.png")
Injector.mini = love.graphics.newImage("injector_mini.png")
Injector.number = 3
function Injector:attack_(board, other)
	if other == nil then return end
	if self:getTotalStrength(board) >= other:getTotalStrength(board) and self.team ~= other.team then
		log(self.name.."'s ability activated, causing it to take control of "..other.name..".")
		other.team = self.team
	end
end

Ratchet = Bot:new()
Ratchet.name = "Ratchet"
Ratchet.image = love.graphics.newImage("ratchet.png")
Ratchet.mini = love.graphics.newImage("ratchet_mini.png")
Ratchet.number = 4
function Ratchet:postAttack_(board)
	if board.deathsThisAttack > 0 then
		log(self.name.."'s ability activated, causing it to attack again with strength "..self:getTotalStrength(board)..".")
		board.currentbot = self.number
		self.permMods = self.permMods + 2
	else
		self.permMods = 0
	end
end

EMPBot = Bot:new()
EMPBot.name = "EMP Bot"
EMPBot.image = love.graphics.newImage("empbot.png")
EMPBot.mini = love.graphics.newImage("empbot_mini.png")
EMPBot.number = 5
function EMPBot:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil then
			neighbors[i].EMP = true
			realNeighbors = realNeighbors + 1
		end
	end
	log(self.name.."'s ability applies EMP to "..realNeighbors.." neighbors.")
end

SpyBot = Bot:new()
SpyBot.name = "SpyBot"
SpyBot.image = love.graphics.newImage("spybot.png")
SpyBot.mini = love.graphics.newImage("spybot_mini.png")
SpyBot.number = 6
function SpyBot:attack_(board, other)
	if other == nil then return end
	if self:getTotalStrength(board) <= other:getTotalStrength(board) and self.team ~= other.team then
		log(self.name.."'s ability activated, allowing it to kill "..other.name.." even though it is smaller.")
		other:die(board)
	end
end

Booster = Bot:new()
Booster.name = "Booster"
Booster.image = love.graphics.newImage("booster.png")
Booster.mini = love.graphics.newImage("booster_mini.png")
Booster.number = 7
function Booster:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil then
			neighbors[i].tempMods = neighbors[i].tempMods + 1
			realNeighbors = realNeighbors + 1
		end
	end
	log(self.name.."'s ability gives +1 strength to "..realNeighbors.." neighbors.")
end

LaserCannon = Bot:new()
LaserCannon.name = "Laser Cannon"
LaserCannon.image = love.graphics.newImage("lasercannon.png")
LaserCannon.mini = love.graphics.newImage("lasercannon_mini.png")
LaserCannon.number = 8
function LaserCannon:preAttack_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	if neighbors == nil or neighbors.n == 0 then return end
	local strongestBotIndex = 0
	local strongestBotNumber = 0
	local strongestBotStrength = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i]:getTotalStrength(board) >= strongestBotStrength then
			if neighbors[i]:getTotalStrength(board) > strongestBotStrength or 
				(neighbors[i]:getTotalStrength(board) == strongestBotStrength and neighbors[i].number > strongestBotNumber) then
				strongestBotStrength = neighbors[i]:getTotalStrength(board)
				strongestBotNumber = neighbors[i].number
				strongestBotIndex = i
			end
		end
	end
	if neighbors[strongestBotIndex] ~= nil then
		log(self.name.."'s ability activates, killing "..neighbors[strongestBotIndex].name
			.." (strength "..neighbors[strongestBotIndex]:getTotalStrength(board)..").")
		neighbors[strongestBotIndex]:die(board)
	end
end

Thresher = Bot:new()
Thresher.name = "Thresher"
Thresher.image = love.graphics.newImage("thresher.png")
Thresher.mini = love.graphics.newImage("thresher_mini.png")
Thresher.number = 9
function Thresher:getNeighbors_(board, currentPosition)
	log(self.name.."'s ability triggers, giving it diagonal neighbors.")
	local neighbors = {}
	neighbors[1] = board:getTile({currentPosition[1]+1, currentPosition[2]+1})
	neighbors[2] = board:getTile({currentPosition[1]-1, currentPosition[2]+1})
	neighbors[3] = board:getTile({currentPosition[1]+1, currentPosition[2]-1})
	neighbors[4] = board:getTile({currentPosition[1]-1, currentPosition[2]-1})
	neighbors.n = 4
	return neighbors
end

Renegade = Bot:new()
Renegade.name = "Renegade"
Renegade.image = love.graphics.newImage("renegade.png")
Renegade.mini = love.graphics.newImage("renegade_mini.png")
Renegade.number = 10
function Renegade:attack_(board, other)
	if other == nil then return end
	if self.team == other.team then
		log(self.name.."'s ability made it attack "..other.name.." even though they are on the same team.")
	end
	if self:getTotalStrength(board) >= other:getTotalStrength(board) then
		other:die(board)
	end
end

Bots = {
	Arcenbot = Arcenbot,
	Recycler = Recycler,
	Injector = Injector,
	Ratchet = Ratchet,
	EMPBot = EMPBot,
	SpyBot = SpyBot,
	Booster = Booster,
	LaserCannon = LaserCannon,
	Thresher = Thresher,
	Renegade = Renegade
}

return Bots
