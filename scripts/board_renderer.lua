function drawBoard(board, coord)
	local boardTilePositions = {}
	for x=1,board.boardWidth do
		boardTilePositions[x] = {}
		for y=1,board.boardHeight do
			boardTilePositions[x][y] = 
			{(boardTileDimensions[1]+boardTilePadding)*(x-1),
			 (boardTileDimensions[2]+boardTilePadding)*(y-1)}
		end
	end

	for x=1,board.boardWidth do
		for y=1,board.boardHeight do
			love.graphics.draw(space, boardTilePositions[x][y][1]-2+coord[1], boardTilePositions[x][y][2]-2+coord[2])
			local thisBot = board:getTile({x, y})
			if thisBot ~= nil then	
				drawMiniCard(thisBot, {boardTilePositions[x][y][1]+boardOffset[1],boardTilePositions[x][y][2]+boardOffset[2]})
				if thisBot.number == board.nextAttacker and board.combatStarted == true then
				love.graphics.draw(attackIndicator, 0, 0)
			end
			end
		end
	end

	--thermometer
	love.graphics.draw(thermometer, 208+coord[1], coord[2]-16)
	if board.combatStarted then
		for i=1,board.currentbot do
			if i <= 10 then
				if i > 1 then
					love.graphics.rectangle("fill", 380, 11+(10-i+1)*22, 9, 4)
				end
				love.graphics.draw(mercury[i], 368, 11+(10-i)*22)
			end
		end
	end
end

function drawMiniCard(bot, position)
	local angle = 0
	if bot.team == 2 then angle = math.pi end
	if bot.team == 3 then angle = math.pi/2 end
	if bot.facedown == true then
		love.graphics.draw(cardback, position[1], position[2])
	else
		local canvas = love.graphics.newCanvas()
		canvas:renderTo(function()
			love.graphics.draw(minicard, 0, 0)
			love.graphics.draw(bot.mini, 0, 0)
			love.graphics.draw(arrow, arrow:getWidth()/2, arrow:getHeight()/2, angle, 1, 1, arrow:getWidth()/2, arrow:getHeight()/2)
			local totalStrength = bot:getTotalStrength()
			love.graphics.draw(miniNumbers[totalStrength], 4, 4)
			if bot.EMP == true then
				love.graphics.draw(empMiniIndicator, 0, 0)
			end
			if bot.number < bot:getTotalStrength() then
				love.graphics.draw(boostMiniIndicator, 0, 0)
			end
		end)
		love.graphics.draw(canvas, position[1], position[2])
	end
end

function drawCursorAndHand(cursor)
	drawCursor(cursor)
	drawHand(cursor.hand, cursor.index, {boardOffset[1], 220})
	--draw instructions
	local currentInstructions = 1
	if cursor.selectedCard ~= nil then currentInstructions = 2 end
	if cursor.board.combatStarted == true then currentInstructions = 3 end
	love.graphics.draw(instructions[currentInstructions], 0, 224)
	love.graphics.draw(arrowInstructions, 0, 0)
end

function drawCursor(cursor)
	local boardTilePositions = {}
	for x=1,cursor.board.boardWidth do
		boardTilePositions[x] = {}
		for y=1,cursor.board.boardHeight do
			boardTilePositions[x][y] = 
			{(boardTileDimensions[1]+boardTilePadding)*(x-1)+boardOffset[1],
			 (boardTileDimensions[2]+boardTilePadding)*(y-1)+boardOffset[2]}
		end
	end

	--ability
	local selectedBot = cursor.board:getTile(cursor.coord)
	if(selectedBot ~= nil and selectedBot.facedown == true) then
		love.graphics.draw(neutralBotCard, 0, 0)
	elseif cursor.selectedCard ~= nil then
		love.graphics.draw(cursor.selectedCard.image, 0, 0)
		local bonusStrength = cursor.selectedCard:getTotalStrength() - cursor.selectedCard.number
		if bonusStrength ~= 0 then
			love.graphics.draw(strengthBonus[bonusStrength], 20, 50)
		end
		if cursor.selectedCard.EMP == true then
			love.graphics.draw(empIndicator, 23, 157)
		end
	elseif cursor.index ~= nil then
		local hoveredBot = cursor.hand[cursor.index]
		if hoveredBot ~= nil then
			love.graphics.draw(hoveredBot.image, 0, 0)
		end
	elseif cursor.coord ~= nil then
		local hoveredBot = cursor.board:getTile(cursor.coord)
		if hoveredBot ~= nil then
			love.graphics.draw(hoveredBot.image, 0, 0)
		end
	end

	--cursor
	if cursor.coord ~= nil then
		local cursorCard = cursor.board:getTile(cursor.coord)
		if cursorCard == nil then
			love.graphics.draw(spaceCursor, boardTilePositions[cursor.coord[1]][cursor.coord[2]][1], 
				boardTilePositions[cursor.coord[1]][cursor.coord[2]][2])
		else
			love.graphics.draw(cardCursor, boardTilePositions[cursor.coord[1]][cursor.coord[2]][1], 
				boardTilePositions[cursor.coord[1]][cursor.coord[2]][2])
		end
	end

	if cursor.mark ~= nil then
		love.graphics.draw(spaceCursor, boardTilePositions[cursor.mark[1]][cursor.mark[2]][1], 
				boardTilePositions[cursor.mark[1]][cursor.mark[2]][2])
	end

	--selected card
	local floatingCardOffset = {}
	for i=1,2 do
		floatingCardOffset[i] = (math.sin(frameCount/200.0*floatingCardRates[i])*2.0) - 1.0
	end
	if cursor.selectedCard ~= nil then
		local cardCoord = {boardTilePositions[cursor.coord[1]][cursor.coord[2]][1]+math.floor(floatingCardOffset[1])+5, 
						   boardTilePositions[cursor.coord[1]][cursor.coord[2]][2]+math.floor(floatingCardOffset[2])+5}
		love.graphics.draw(shadow, cardCoord[1]-5, cardCoord[2]-5)
		drawMiniCard(cursor.selectedCard, cardCoord)
	end
end

function drawHand(hand, selectedIndex, coord)
	local handLength = 10
	if hand.maxLength ~= nil then handLength = hand.maxLength end
	local handPositions = {}
	for i=1,handLength do
		handPositions[i] = {coord[1]+(i-1)*50, coord[2]}
	end

	for i=1,handLength do
		local selectedOffset = 0
		if selectedIndex == i then
			selectedOffset = 30
		end
		if hand[i] ~= nil then
			drawMiniCard(hand[i], {handPositions[i][1], handPositions[i][2] - selectedOffset})
		end
	end
end
