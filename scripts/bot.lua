Bot = {
	number = 0, 
	name = "",
	team = 0, 
	animation = 0, 
	tempMods = 0, 
	permMods = 0, 
	EMP = false,
	paralyzed = false,
	image = nil,
	mini = nil,
	facedown = false,
}

function Bot:new ()
    o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = function (table, key)
      return self[key]
    end
    o.EMP = false
    o.paralyzed = false
    return o
end

function Bot:tick(board)
	if self.EMP == false then
		self:tick_(board)
	else
		if Bot.tick_ ~= self.tick_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		Bot.tick_(self, board)
	end
end

function Bot:tick_(board)
end

function Bot:getNeighbors(board, currentPosition)
	if self.EMP == false then
		return self:getNeighbors_(board, currentPosition)
	else
		if Bot.getNeighbors_ ~= self.getNeighbors_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		return Bot.getNeighbors_(self, board, currentPosition)
	end
end

function Bot:getNeighbors_(board, currentPosition)
	local neighbors = {}
	neighbors[1] = board:getTile({currentPosition[1]+1, currentPosition[2]})
	neighbors[2] = board:getTile({currentPosition[1]-1, currentPosition[2]})
	neighbors[3] = board:getTile({currentPosition[1], currentPosition[2]+1})
	neighbors[4] = board:getTile({currentPosition[1], currentPosition[2]-1})
	neighbors.n = 4
	return neighbors
end

function Bot:preAttack(board)
	if self.EMP == false then
		self:preAttack_(board)
	else
		if Bot.preAttack_ ~= self.preAttack_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		Bot.preAttack_(self, board)
	end
end

function Bot:preAttack_(board)
end

function Bot:attack(board, other)
	if self.paralyzed == false then
		if self.EMP == false then
			self:attack_(board, other)
		else
			if Bot.attack_ ~= self.attack_ then
				log(self.name.."'s ability didn't work due to EMP!")
			end
			Bot.attack_(self, board, other)
		end
	else
		log(self.name.." couldn't attack due to paralysis!")
	end
end

function Bot:attack_(board, other)
	if other == nil then return end
	if self:getTotalStrength() >= other:getTotalStrength() and self.team ~= other.team then
		log(self.name.." attacked "..other.name..", killing it.")
		other:die(board, self)
	elseif self.team ~= other.team then
		log(self.name.." attacked "..other.name..", but couldn't kill it.")
	end
end

function Bot:postAttack(board)
	if self.EMP == false then
		self:postAttack_(board)
	else
		if Bot.postAttack_ ~= self.postAttack_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		Bot.postAttack_(self, board)
	end
end

function Bot:postAttack_(board)
end

function Bot:die(board, killer)
	if self.EMP == false then
		self:die_(board, killer)
	else
		if Bot.die_ ~= self.die_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		Bot.die_(self, board, killer)
	end
end

function Bot:die_(board, killer)
	push(board.deathsThisAttack, self)
	local position = board:getBotPosition(self.number)
	if position == nil then return end
	board:setTile(position, nil)
end

function Bot:score(board)
	if self.EMP == false then
		return self:score_(board)
	else
		if Bot.score_ ~= self.score_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		return Bot.score_(self, board)
	end
end

function Bot:score_(board)
	return 1
end

function Bot:getTotalStrength(board)
	if self.EMP == false then
		return self:getTotalStrength_(board)
	else
		if Bot.getTotalStrength_ ~= self.getTotalStrength_ then
			log(self.name.."'s ability didn't work due to EMP!")
		end
		return Bot.getTotalStrength_(self, board)
	end
end

function Bot:getTotalStrength_(board)
	return self.number + self.tempMods + self.permMods
end

return Bot
