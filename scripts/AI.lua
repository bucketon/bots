AI = {}

function AI:calculateTurn(hand, board)

	--medium AI version
	local unusedBots = {
		Bots.Arcenbot:new(),
		Bots.Recycler:new(),
		Bots.Injector:new(),
		Bots.Ratchet:new(),
		Bots.EMPBot:new(),
		Bots.SpyBot:new(),
		Bots.Booster:new(),
		Bots.LaserCannon:new(),
		Bots.Thresher:new(),
		Bots.Renegade:new()
	}
	if saveData.deck ~= nil then
		for i=1,#saveData.deck do
			unusedBots[i] = AllBots[saveData.deck[i]]:new()
		end
	end

	local myTeam = hand[1].team
	local theirTeam = myTeam%2+1
	local neutralBotLocation = {0, 0}
	for i=1,#hand do
		unusedBots[hand[i].number] = nil
	end
	for x=1,board.boardWidth do
		for y=1,board.boardHeight do
			local bot = board:getTile({x, y})
			if bot ~= nil and bot.facedown == false then
				unusedBots[bot.number] = nil
			end
			if bot ~= nil and bot.facedown == true then
				neutralBotLocation = {x, y}
			end
		end
	end
	unusedBots = defrag(unusedBots, 10)
	shuffle(unusedBots)

	local possibleMoves = {}
	local emptySpaces = board:getEmptySpaces()
	
	for i=1,#hand do
		for j=1,#emptySpaces do
			local handCopy = deepCopy(hand)
			local space = pop(emptySpaces)
			local card = pop(handCopy)
			local totalScores = 0
			for n=1,#unusedBots do
				local testBoard = deepCopy(board)
				testBoard:setTile(space, card)--the move we're testing
				local unusedBotsCopy = deepCopy(unusedBots)
				if not areEqual(neutralBotLocation, {0, 0}) then
					local neutralBot = unusedBotsCopy[n]
					unusedBotsCopy[n] = nil
					neutralBot.team = 3
					testBoard:setTile(neutralBotLocation, neutralBot)
				end
				unusedBotsCopy = defrag(unusedBotsCopy, 10)
				local emptySpacesCopy = deepCopy(emptySpaces)
				local handCopyCopy = deepCopy(handCopy)
				shuffle(unusedBotsCopy)
				for k=1,#emptySpacesCopy do--fill the rest of the board
					if k%2 == 1 then --play a blank bot we can't see
						local bot = pop(unusedBotsCopy)
						bot.team = theirTeam
						testBoard:setTile(emptySpacesCopy[k], bot)
					else --play a random bot from our hand
						testBoard:setTile(emptySpacesCopy[k], pop(handCopyCopy))
					end
				end
				testBoard.deck = unusedBotsCopy
				if #unusedBotsCopy == 0 then error("deck was empty") end
				--compute score
				while testBoard.winner == 0 or testBoard.winner == nil do
					testBoard:progress()
				end
				local winner = testBoard.winner
				if winner == myTeam then
					totalScores = totalScores + 1
				end
			end
			--insert averagescore + move into a data structure
			local handIndex = 0
			for i=1,#hand do
				if hand[i].number == card.number then
					handIndex = i
				end
			end
			possibleMoves[#possibleMoves+1] = {space, handIndex, totalScores}
		end
	end
	--sort, randomly choose from top results
	local message = ""
	for iter=1,#possibleMoves do
		message = message..", "..possibleMoves[iter][3]
	end
	shuffle(possibleMoves)
	table.sort (possibleMoves, function (left, right) return left[3] > right[3] end)
	return {space = possibleMoves[1][1], index = possibleMoves[1][2]}
end

function AI:calculateTurnWeak(hand, board)
	local emptySpaces = board:getEmptySpaces()
	local randomIndex = math.random(1, #emptySpaces)
	log("Player placed "..hand[#hand].name.." on the board at ["..emptySpaces[randomIndex][1]..", "..emptySpaces[randomIndex][2].."].")
	return {space = emptySpaces[randomIndex], index = #hand}
end

return AI
