StraitJacket = Bot:new()
StraitJacket.name = "StraitJacket"
StraitJacket.text = "The biggest adjacent enemy doesn't attack."
StraitJacket.image = love.graphics.newImage("assets/temp_raw.png")
StraitJacket.mini = love.graphics.newImage("assets/temp_mini.png")
StraitJacket.number = 1
function StraitJacket:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	local biggestBots = {}
	local highestStrength = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].number >= highestStrength then
			if neighbors[i].number == highestStrength then
				push(biggestBots, i)
			else
				highestStrength = neighbors[i].number
				biggestBots = {i}
			end
		end
	end
	for i=1,#biggestBots do
		neighbors[biggestBots[i]].paralyzed = true
	end
	log(self.name.."'s ability applies paralysis to "..#biggestBots.." neighbors.")
end

LilOleMe = Bot:new()
LilOleMe.name = "Lil Ole Me"
LilOleMe.text = "Attacks all enemy bots."
LilOleMe.image = love.graphics.newImage("assets/temp_raw.png")
LilOleMe.mini = love.graphics.newImage("assets/temp_mini.png")
LilOleMe.number = 1
function LilOleMe:getNeighbors_(board, currentPosition)
	local neighbors = {}
	local i = 0
	for x=1,board.boardWidth do
		for y=1,board.boardHeight do
			if x ~= currentPosition[1] or y ~= currentPosition[2] then
				i = i + 1
				neighbors[i] = board:getTile({x, y})
			end
		end
	end
	neighbors.n = i
	return neighbors
end

Speedbot = Bot:new()
Speedbot.name = "Speedbot"
Speedbot.text = "Gets +3 strength while attacking."
Speedbot.image = love.graphics.newImage("assets/temp_raw.png")
Speedbot.mini = love.graphics.newImage("assets/temp_mini.png")
Speedbot.number = 2
function Speedbot:preAttack_(board)
	self.tempMods = self.tempMods + 3
end

BlackJack = Bot:new()--todo: move death trigger to start of attacks.
BlackJack.name = "BlackJack"
BlackJack.text = "Add adjacent bots' strength to this. If >10, dies."
BlackJack.image = love.graphics.newImage("assets/temp_raw.png")
BlackJack.mini = love.graphics.newImage("assets/temp_mini.png")
BlackJack.number = 2
function BlackJack:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	for i=1,neighbors.n do
		if neighbors[i] ~= nil then
			self.tempMods = self.tempMods + neighbors[i]:getTotalStrength()
		end
	end
	if self:getTotalStrength(board) > 10 then
		self:die(board, self)
	end
end

FearBot = Bot:new()
FearBot.name = "FearBot"
FearBot.text = "If this is smaller than all of its neighbors it gets +4 strength."
FearBot.image = love.graphics.newImage("assets/temp_raw.png")
FearBot.mini = love.graphics.newImage("assets/temp_mini.png")
FearBot.number = 2
function FearBot:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local smallest = true
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i]:getTotalStrength() < self:getTotalStrength() then
			smallest = false
		end
	end
	if smallest == true then
		self.tempMods = self.tempMods + 4
	end
end

RadiationBot = Bot:new()
RadiationBot.name = "RadiationBot"
RadiationBot.text = "Adjacent bots have -2 strength."
RadiationBot.image = love.graphics.newImage("assets/temp_raw.png")
RadiationBot.mini = love.graphics.newImage("assets/temp_mini.png")
RadiationBot.number = 3
function RadiationBot:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil then
			neighbors[i].tempMods = neighbors[i].tempMods - 2
			realNeighbors = realNeighbors + 1
		end
	end
	log(self.name.."'s ability gives -2 strength to "..realNeighbors.." neighbors.")
end

DavidDestroyer = Bot:new()
DavidDestroyer.name = "Davidestroyer"
DavidDestroyer.text = "Only kills neighbors within 2 strength of it."
DavidDestroyer.image = love.graphics.newImage("assets/temp_raw.png")
DavidDestroyer.mini = love.graphics.newImage("assets/temp_mini.png")
DavidDestroyer.number = 4
function DavidDestroyer:attack_(board, other)
	if other == nil then return end
	local delta = self:getTotalStrength(board) - other:getTotalStrength(board)
	if delta >= -2 and delta <= 2 and self.team ~= other.team then
		log(self.name.."'s ability activated, allowing it to kill "..other.name.." because it is within 2 strength.")
		other:die(board, self)
	end
end

Faraday = Bot:new()
Faraday.name = "Faraday"
Faraday.text = "This bot cannot be modified."
Faraday.image = love.graphics.newImage("assets/temp_raw.png")
Faraday.mini = love.graphics.newImage("assets/temp_mini.png")
Faraday.number = 5
Faraday.priority = 10
function Faraday:tick_(board)
	self.EMP = false
	self.paralyzed = false
	self.tempMods = 0
	self.permMods = 0
end

Eater = Bot:new()
Eater.name = "Eater"
Eater.text = "After this attacks it gets +1 strength for each kill."
Eater.image = love.graphics.newImage("assets/temp_raw.png")
Eater.mini = love.graphics.newImage("assets/temp_mini.png")
Eater.number = 5
function Eater:postAttack_(board)
	self.permMods = self.permMods + #board.deathsThisAttack
end

Bouncer = Bot:new()
Bouncer.name = "Bouncer"
Bouncer.text = "The biggest adjacent bot becomes strength 7."
Bouncer.image = love.graphics.newImage("assets/temp_raw.png")
Bouncer.mini = love.graphics.newImage("assets/temp_mini.png")
Bouncer.number = 5
function Bouncer:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local biggestBots = {}
	local highestStrength = 0
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].number >= highestStrength then
			if neighbors[i].number == highestStrength then
				push(biggestBots, i)
			else
				highestStrength = neighbors[i].number
				biggestBots = {i}
			end
		end
	end
	for i=1,#biggestBots do
		neighbors[biggestBots[i]].tempMods = neighbors[biggestBots[i]].tempMods + 7 - 
		neighbors[biggestBots[i]]:getTotalStrength()
	end
	log(self.name.."'s ability applies paralysis to "..#biggestBots.." neighbors.")
end

TurtleBot = Bot:new()
TurtleBot.name = "TurtleBot"
TurtleBot.text = "Has +2 strength during other bots' turns."
TurtleBot.image = love.graphics.newImage("assets/temp_raw.png")
TurtleBot.mini = love.graphics.newImage("assets/temp_mini.png")
TurtleBot.number = 6
function TurtleBot:tick_(board)
	self.tempMods = self.tempMods + 2
end
function TurtleBot:preAttack_(board)
	self.tempMods = self.tempMods - 2
end

Pacifist = Bot:new()
Pacifist.name = "Pacifist"
Pacifist.text = "If there is an adjacent enemy this is worth one more survivor."
Pacifist.image = love.graphics.newImage("assets/temp_raw.png")
Pacifist.mini = love.graphics.newImage("assets/temp_mini.png")
Pacifist.number = 6
function Pacifist:score_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local hasEnemyNeighbor = false
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].team ~= self.team then
			hasEnemyNeighbor = true
		end
	end
	if hasEnemyNeighbor then
		log(self.name.."'s special ability activated, causing it to score more points.")
		return 2
	else
		return 1
	end
end

AutoLadder = Bot:new()
AutoLadder.name = "Auto Ladder"
AutoLadder.text = "The smallest adjacent bot gets +4 strength."
AutoLadder.image = love.graphics.newImage("assets/temp_raw.png")
AutoLadder.mini = love.graphics.newImage("assets/temp_mini.png")
AutoLadder.number = 6
function AutoLadder:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	local smallestBots = {}
	local lowestStrength = 10
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].number <= lowestStrength then
			if neighbors[i].number == lowestStrength then
				push(smallestBots, i)
			else
				lowestStrength = neighbors[i].number
				smallestBots = {i}
			end
		end
	end
	for i=1,#smallestBots do
		neighbors[smallestBots[i]].tempMods = neighbors[smallestBots[i]].tempMods + 4
	end
	log(self.name.."'s ability applies +5 str to "..#smallestBots.." neighbors.")
end

Herobot = Bot:new()
Herobot.name = "Herobot"
Herobot.text = "As long as your opponent has more living bots, this is unkillable."
Herobot.image = love.graphics.newImage("assets/temp_raw.png")
Herobot.mini = love.graphics.newImage("assets/temp_mini.png")
Herobot.number = 7
function Herobot:die_(board, killer)
	local counts = {0, 0, 0}
	for x=1,board.boardWidth do
		for y=1,board.boardHeight do
			local bot = board:getTile({x, y})
			if bot ~= nil then
				counts[bot.team] = counts[bot.team] + 1
			end
		end
	end
	local biggest = {}
	local most = 0
	for i=1,3 do
		if counts[i] >= most then
			if counts[i] == most then
				push(biggest, counts[i])
			else
				most = counts[i]
				biggest = {counts[i]}
			end
		end
	end
	local invulnerable = true
	for i=1,#biggest do
		if biggest[i] == self.team then
			invulnerable = false
		end
	end
	if not invulnerable then
		push(board.deathsThisAttack, self)
		local position = board:getBotPosition(self.number)
		if position == nil then return end
		board:setTile(position, nil)
	else
		log(self.name.."'s ability activated, causing it to be invulnerable.")
	end
end

StraightShooter = Bot:new()
StraightShooter.name = "Straight Shooter"
StraightShooter.text = "If 3 bots in line with this form a straight, convert all of them."
StraightShooter.image = love.graphics.newImage("assets/temp_raw.png")
StraightShooter.mini = love.graphics.newImage("assets/temp_mini.png")
StraightShooter.number = 8
function StraightShooter:tick_(board)
	for i=1,4 do
		local line = {}
		local deltx = 0
		local delty = 0
		if i == 1 then --diagonal down
			deltx = 1
			delty = 1
		elseif i == 2 then --horizontal
			deltx = 1
			delty = 0
		elseif i == 3 then --vertical
			deltx = 0
			delty = 1
		else --diagonal up
			deltx = -1
			delty = 1
		end
		for j=-board.boardWidth,board.boardWidth do
			local bot = board:getTile({j*deltx,j*delty})
			if bot ~= nil then
				push(line, bot)
			end
		end
		if #line >= board.boardWidth then
			local isStraight = true
			table.sort (line, function (left, right) return left.number < right.number end )
			for j=1,#line-1 do
				local delta = line[j+1].number - line[j].number
				if delta > 1 then
					isStraight = false
				end
			end
			if isStraight then
				for j=1,#line do
					line[j].team = self.team
				end
			end
		end
	end
end

Cultist = Bot:new()
Cultist.name = "Cultist"
Cultist.text = "Bots that would be killed by it join its team. Is worth 3 fewer survivors"
Cultist.image = love.graphics.newImage("assets/temp_raw.png")
Cultist.mini = love.graphics.newImage("assets/temp_mini.png")
Cultist.number = 8
function Cultist:attack_(board, other)
	if other == nil then return end
	if self:getTotalStrength(board) >= other:getTotalStrength(board) and self.team ~= other.team then
		log(self.name.."'s ability activated, causing it to take control of "..other.name..".")
		other.team = self.team
	end
end
function Cultist:score_(board)
	return -2
end

Elephant = Bot:new()
Elephant.name = "Elephant"
Elephant.text = "Unkillable. Dies if smaller or equal enemies are by it after attack"
Elephant.image = love.graphics.newImage("assets/temp_raw.png")
Elephant.mini = love.graphics.newImage("assets/temp_mini.png")
Elephant.number = 8
function Elephant:postAttack_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].team ~= self.team and 
			neighbors[i]:getTotalStrength(board) < self:getTotalStrength(board) then
			self:die(board, self)
		end
	end
end
function Elephant:die_(board, killer)
	if killer == self then
		push(board.deathsThisAttack, self)
		local position = board:getBotPosition(self.number)
		if position == nil then return end
		board:setTile(position, nil)
	end
end

Crusher = Bot:new()
Crusher.name = "Crusher"
Crusher.text = "Before this attacks, kill the smallest bot anywhere."
Crusher.image = love.graphics.newImage("assets/temp_raw.png")
Crusher.mini = love.graphics.newImage("assets/temp_mini.png")
Crusher.number = 8
function Crusher:preAttack_(board)
	local smallestBot = {}
	smallestBot.number = 11
	for x=1,board.boardWidth do
		for y=1,board.boardHeight do
			local bot = board:getTile({x, y})
			if bot ~= nil and bot.number < smallestBot.number then
				smallestBot = bot
			end
		end
	end
	smallestBot:die(board, self)
end

Guardian = Bot:new()
Guardian.name = "Guardian"
Guardian.text = "The smallest adjacent friendly bot gets +1 strength."
Guardian.image = love.graphics.newImage("assets/temp_raw.png")
Guardian.mini = love.graphics.newImage("assets/temp_mini.png")
Guardian.number = 9
function Guardian:tick_(board)
	local neighbors = self:getNeighbors(board, board:getBotPosition(self.number))
	local realNeighbors = 0
	local smallestBots = {}
	local lowestStrength = 10
	for i=1,neighbors.n do
		if neighbors[i] ~= nil and neighbors[i].team == self.team and neighbors[i].number <= lowestStrength then
			if neighbors[i].number == highestStrength then
				push(smallestBots, i)
			else
				lowestStrength = neighbors[i].number
				smallestBots = {i}
			end
		end
	end
	for i=1,#smallestBots do
		neighbors[smallestBots[i]].tempMods = neighbors[smallestBots[i]].tempMods + 1
	end
	log(self.name.."'s ability applies +1 str to "..#smallestBots.." neighbors.")
end

SteadfastBot = Bot:new()
SteadfastBot.name = "SteadfastBot"
SteadfastBot.text = "Gets +1 strength while attacking."
SteadfastBot.image = love.graphics.newImage("assets/temp_raw.png")
SteadfastBot.mini = love.graphics.newImage("assets/temp_mini.png")
SteadfastBot.number = 9
function SteadfastBot:preAttack_(board)
	self.tempMods = self.tempMods + 1
end

GlassCannon = Bot:new()
GlassCannon.name = "GlassCannon"
GlassCannon.text = "Gets -2 strength during other bots' turns."
GlassCannon.image = love.graphics.newImage("assets/temp_raw.png")
GlassCannon.mini = love.graphics.newImage("assets/temp_mini.png")
GlassCannon.number = 10
function GlassCannon:tick_(board)
	self.tempMods = self.tempMods - 2
end
function GlassCannon:preAttack_(board)
	self.tempMods = self.tempMods + 2
end

DynaBot = Bot:new()
DynaBot.name = "DynaBot"
DynaBot.text = "After it attacks, it dies."
DynaBot.image = love.graphics.newImage("assets/temp_raw.png")
DynaBot.mini = love.graphics.newImage("assets/temp_mini.png")
DynaBot.number = 10
function DynaBot:postAttack_(board)
	self:die(board, self)
end

Merc = Bot:new()
Merc.name = "Merc"
Merc.text = "If it would die, instead it changes teams."
Merc.image = love.graphics.newImage("assets/temp_raw.png")
Merc.mini = love.graphics.newImage("assets/temp_mini.png")
Merc.number = 10
function Merc:die_(board, killer)
	self.team = killer.team
end

BotenAuGratin = Bot:new()
BotenAuGratin.name = "BotEnAuGratin"
BotenAuGratin.text = "Does not attack on its turn."
BotenAuGratin.image = love.graphics.newImage("assets/temp_raw.png")
BotenAuGratin.mini = love.graphics.newImage("assets/temp_mini.png")
BotenAuGratin.number = 10
function BotenAuGratin:tick_(board)
	self.paralyzed = true
end

ExtendedBots = {
	Arcenbot,
	Recycler,
	Injector,
	Ratchet,
	EMPBot,
	SpyBot,
	Booster,
	LaserCannon,
	Thresher,
	Renegade,
	StraitJacket,
	LilOleMe,
	Speedbot,
	BlackJack,
	FearBot,
	RadiationBot,
	DavidDestroyer,
	Faraday,
	Eater,
	Bouncer,
	TurtleBot,
	Pacifist,
	AutoLadder,
	Herobot,
	StraightShooter,
	Cultist,
	Elephant,
	Crusher,
	Guardian,
	SteadfastBot,
	GlassCannon,
	DynaBot,
	Merc,
	BotenAuGratin,
}

return ExtendedBots
