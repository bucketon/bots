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
