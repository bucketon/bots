HandCursor = {
	index = 1
}

function HandCursor:new(board, hand, index, mark)
    o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = function (table, key)
      return self[key]
    end
    o.index = math.min(math.max(1, index), #hand)
    o.hand = hand
    o.board = board
    if mark == nil then
    	o.mark = nil
    else
    	o.mark = {math.min(math.max(1, mark[1]), board.boardWidth), math.min(math.max(1, mark[2]), board.boardHeight)}
    end
    return o
end

function HandCursor:up()
	return BoardCursor:new(self.board, self.hand, {self.index, self.board.boardHeight}, nil)
end

function HandCursor:down()
	return self
end

function HandCursor:left()
	return HandCursor:new(self.board, self.hand, self.index - 1, self.mark)
end

function HandCursor:right()
	return HandCursor:new(self.board, self.hand, self.index + 1, self.mark)
end

function HandCursor:grab()
	local card = self.hand[self.index]
	self.hand[self.index] = nil
	if self.mark ~= nil and self.hand[self.index] ~= nil then
		log("Player placed "..card.name.." on the board at ["..self.mark[1]..", "..self.mark[2].."].")
		self.hand[self.index] = nil
		local handLength = 10
		if self.hand.maxLength ~= nil then handLength = self.hand.maxLength end
		self.hand = defrag(self.hand, handLength)
		self.board:setTile(self.mark, card)
		return BoardCursor:new(self.board, self.hand, self.mark, nil), true
	else
		log("Selected card number "..self.index.." in hand.")
		return BoardCursor:new(self.board, self.hand, {self.index, self.board.boardHeight}, card), false
	end
end

return HandCursor
