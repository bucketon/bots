BoardCursor = {}

function BoardCursor:new(board, hand, coord, selectedCard)
    o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = function (table, key)
      return self[key]
    end
    o.coord = {math.min(math.max(1, coord[1]), board.boardWidth), math.min(math.max(1, coord[2]), board.boardHeight)}
    o.hand = hand
    o.board = board
    o.selectedCard = selectedCard
    return o
end

function BoardCursor:up()
	return BoardCursor:new(self.board, self.hand, {self.coord[1], self.coord[2]-1}, self.selectedCard)
end

function BoardCursor:down()
	if self.coord[2] == self.board.boardHeight and self.selectedCard == nil then
	 	return HandCursor:new(self.board, self.hand, self.coord[1], nil)
	else
		return BoardCursor:new(self.board, self.hand, {self.coord[1], self.coord[2]+1}, self.selectedCard)
	end
end

function BoardCursor:left()
	return BoardCursor:new(self.board, self.hand, {self.coord[1]-1, self.coord[2]}, self.selectedCard)
end

function BoardCursor:right()
	return BoardCursor:new(self.board, self.hand, {self.coord[1]+1, self.coord[2]}, self.selectedCard)
end

function BoardCursor:replace()
	if self.selectedCard == nil then
		return HandCursor:new(self.board, self.hand, 1)
	else
		local index = self:returnCard_(self.selectedCard)
		return HandCursor:new(self.board, self.hand, index, nil)
	end
end

function BoardCursor:bookmark()
	if self.selectedCard ~= nil or self.board:getTile(self.coord) ~= nil then
		return self
	else
		return HandCursor:new(self.board, self.hand, 1, self.coord)
	end
end

function BoardCursor:place()
	if self.board:getTile(self.coord) == nil then
		log("Player placed "..self.selectedCard.name.." on the board at ["..self.coord[1]..", "..self.coord[2].."].")
		local handLength = 10
		if self.hand.maxLength ~= nil then handLength = self.hand.maxLength end
		self.hand = defrag(self.hand, handLength)
		self.board:setTile(self.coord, self.selectedCard)
		return BoardCursor:new(self.board, self.hand, self.coord, nil), true
	else
		return self, false
	end
end

function BoardCursor:pickup()
	if self.board:getTile(self.coord) ~= nil then
		local card = self.board:getTile(self.coord)
		log("Player picked up "..card.name.." from the board at ["..self.coord[1]..", "..self.coord[2].."].")
		self.board:setTile(self.coord, nil)
		return BoardCursor:new(self.board, self.hand, self.coord, card)
	else
		return self
	end
end

function BoardCursor:returnCard_(card)
	local handLength = 10
	if self.hand.maxLength ~= nil then handLength = self.hand.maxLength end
	for i=1,handLength do
		if self.hand[i] == nil then
			self.hand[i] = card
			return i
		end
	end
end

return BoardCursor
