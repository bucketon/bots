function love.load()
	testMode = false
	require("scripts/utilities")
	Bot = require("scripts/bot")
	Bots = require("scripts/base_bots")
	Gameboard = require("scripts/gameboard")
	AI = require("scripts/AI")
	blobReader = require("lib/BlobReader")
	blobWriter = require("lib/BlobWriter")
	math.randomseed(os.time())
	version = "0.4.0"
	love.window.setTitle("Bots "..version)
	love.graphics.setColor(1, 1, 1, 1)
	font = love.graphics.newFont(18, "mono")
	love.graphics.setFont(font)
	title = love.graphics.newImage("assets/title.png")
	rules = love.graphics.newImage("assets/rules.png")
	arrow = love.graphics.newImage("assets/arrow.png")
	spaceCursor = love.graphics.newImage("assets/spacecursor.png")
	cardCursor = love.graphics.newImage("assets/cardcursor.png")
	cardback = love.graphics.newImage("assets/cardback.png")
	shadow = love.graphics.newImage("assets/dropshadow.png")
	space = love.graphics.newImage("assets/boardspace.png")
	neutralBotCard = love.graphics.newImage("assets/neutralbot.png")
	empIndicator = love.graphics.newImage("assets/emp.png")
	empMiniIndicator = love.graphics.newImage("assets/emp_mini.png")
	boostMiniIndicator = love.graphics.newImage("assets/boost_mini.png")
	attackIndicator = love.graphics.newImage("assets/attack_indicator.png")
	miniNumbers = {
		love.graphics.newImage("assets/minione.png"),
		love.graphics.newImage("assets/minitwo.png"),
		love.graphics.newImage("assets/minithree.png"),
		love.graphics.newImage("assets/minifour.png"),
		love.graphics.newImage("assets/minifive.png"),
		love.graphics.newImage("assets/minisix.png"),
		love.graphics.newImage("assets/miniseven.png"),
		love.graphics.newImage("assets/minieight.png"),
		love.graphics.newImage("assets/mininine.png"),
		love.graphics.newImage("assets/miniten.png"),
		love.graphics.newImage("assets/minieleven.png"),
		love.graphics.newImage("assets/minitwelve.png"),
		love.graphics.newImage("assets/minithirteen.png")
	}
	strengthBonus = {
		love.graphics.newImage("assets/plusone.png"),
		love.graphics.newImage("assets/plustwo.png"),
		love.graphics.newImage("assets/plusthree.png"),
		love.graphics.newImage("assets/plusfour.png"),
		love.graphics.newImage("assets/plusfive.png"),
		love.graphics.newImage("assets/plussix.png"),
		love.graphics.newImage("assets/plusseven.png"),
		love.graphics.newImage("assets/pluseight.png"),
		love.graphics.newImage("assets/plusnine.png")
	}
	minicard = love.graphics.newImage("assets/minicard.png")
	thermometer = love.graphics.newImage("assets/thermometer.png")
	instructions = {
		love.graphics.newImage("assets/instructionsA.png"),
		love.graphics.newImage("assets/instructionsB.png"),
		love.graphics.newImage("assets/instructionsC.png")
	}
	arrowInstructions = love.graphics.newImage("assets/instructions_arrows.png")
	player1wins = love.graphics.newImage("assets/player1wins.png")
	player2wins = love.graphics.newImage("assets/player2wins.png")
	nbwins = love.graphics.newImage("assets/neutralbotwins.png")
	mercury = {
		love.graphics.newImage("assets/therm_1.png"),
		love.graphics.newImage("assets/therm_2.png"),
		love.graphics.newImage("assets/therm_3.png"),
		love.graphics.newImage("assets/therm_4.png"),
		love.graphics.newImage("assets/therm_5.png"),
		love.graphics.newImage("assets/therm_6.png"),
		love.graphics.newImage("assets/therm_7.png"),
		love.graphics.newImage("assets/therm_8.png"),
		love.graphics.newImage("assets/therm_9.png"),
		love.graphics.newImage("assets/therm_10.png")
	}
	saveData = load()
	relevantScoresCount = 100
	gameStarted = false
	viewingRules = false
	player2TurnTime = 50
	floatingCardOffset = {0, 0}
	floatingCardRates = {0, 0}
	setup()
	boardOffset = {160, 16}
	boardTileDimensions = {64, 64}
	boardTilePadding = 5
	boardTilePositions = {}
	boardDimensions = 
	{boardTileDimensions[1]*board.boardWidth+boardTilePadding*(board.boardWidth+1),
	 boardTileDimensions[2]*board.boardHeight+boardTilePadding*(board.boardHeight+1)}
	for x=1,board.boardWidth do
		boardTilePositions[x] = {}
		for y=1,board.boardHeight do
			boardTilePositions[x][y] = 
			{boardOffset[1]+(boardTileDimensions[1]+boardTilePadding)*(x-1),
			 boardOffset[2]+(boardTileDimensions[2]+boardTilePadding)*(y-1)}
		end
	end
	player1HandPositions = {}
	for i=1,4 do
		player1HandPositions[i] = {boardOffset[1]+(i-1)*50, 220}
	end
	player2HandPositions = {}
	for i=1,4 do
		player2HandPositions[i] = {boardOffset[1]+(i-1)*50, -50}
	end
	menu = {
			{selected = love.graphics.newImage("assets/StartSelected.png"), 
			 unselected = love.graphics.newImage("assets/StartUnselected.png"), 
			 method = function() gameStarted = true end},

			{selected = love.graphics.newImage("assets/RulesSelected.png"), 
			 unselected = love.graphics.newImage("assets/RulesUnselected.png"), 
			 method = function() viewingRules = true end}
		   }
	menuIndex = 1
	if testMode == true then
		love.keypressed("z", "z", false)
	end
	gameCount = 0
	AIWinCount = 0
	score = calculateScore()
end

function setup()
	player1Hand = {}
	player2Hand = {}
	deck = {}
	board = Gameboard:new()
	fillDeck()
	shuffle(deck)
	deal()
	board.deck = deck
	frameCount = 0
	cursorCoord = {2, 2}
	handSelected = 0
	boardSelected = {0, 0}
	playerTurnsDone = false
	selectedCard = nil
	currentInstructions = 1
	player2TurnTimer = 0
	log("GAME START: Started a new game!")
end

function restart()
	setup()
end

function fillDeck() --the classic bots set
	deck[1] = Bots.Arcenbot:new()
	deck[2] = Bots.Recycler:new()
	deck[3] = Bots.Injector:new()
	deck[4] = Bots.Ratchet:new()
	deck[5] = Bots.EMPBot:new()
	deck[6] = Bots.SpyBot:new()
	deck[7] = Bots.Booster:new()
	deck[8] = Bots.LaserCannon:new()
	deck[9] = Bots.Thresher:new()
	deck[10] = Bots.Renegade:new()
end

function deal()
	for i=1,#deck-1 do
		if i == 1 then
			local card = pop(deck)
			card.team = 3
			card.facedown = true
			neutralBot = card
			board:setTile({2, 2}, card)
		elseif i%2 == 1 then
			local card = pop(deck)
			card.team = 1
			player1Hand[#player1Hand+1] = card
		else
			local card = pop(deck)
			card.team = 2
			player2Hand[#player2Hand+1] = card
		end
	end
end

function cleanupScores()
	if #saveData.score > 2*relevantScoresCount then
		for i=1,(#saveData.score - relevantScoresCount) do
			saveData.score[i] = nil
		end
		saveData.score = defrag(saveData.score)
	end
end

function calculateScore()
	local score = 0
	if saveData.score ~= nil then
		local last = math.max(1, #saveData.score - relevantScoresCount)
		for i=#saveData.score,last,-1 do
			local gamesPast = i - last + math.max(0, relevantScoresCount - #saveData.score) + 1
			score = score + saveData.score[i]*gamesPast
		end
	end
	return score
end

function love.keypressed(key, scancode, isrepeat)
	if gameStarted == false and viewingRules == false then
		if key == "z" then
			menu[menuIndex].method()
		end
		if key == "up" then
			menuIndex = math.max(1, menuIndex - 1)
		end
		if key == "down" then
			menuIndex = math.min(#menu, menuIndex + 1)
		end
	elseif viewingRules == true then
		if key == "x" then viewingRules = false end
	else
		if key=="left" then
			if handSelected > 1 then 
				handSelected = handSelected - 1 
			end
			cursorCoord[1] = math.max(1, cursorCoord[1]-1)
		end
		if key=="right" then
			if handSelected > 0 and handSelected < #player1Hand then 
				handSelected = handSelected + 1 
			end
			cursorCoord[1] = math.min(board.boardWidth, cursorCoord[1]+1)
		end
		if key=="up" then
			if handSelected > 0 then 
				handSelected = 0 
				cursorCoord[2] = board.boardHeight
				boardSelected = {0, 0}
			else
				cursorCoord[2] = math.max(1, cursorCoord[2]-1)
			end
		end
		if key=="down" then
			if cursorCoord[2] == board.boardHeight and selectedCard == nil and handSelected == 0 then
			 	handSelected = math.min(cursorCoord[1], #player1Hand)
			end
			cursorCoord[2] = math.min(board.boardHeight, cursorCoord[2]+1)
		end

		if key=="z" and player2TurnTimer == 0 then
			--run the fight
			if playerTurnsDone then
				if board.winner == 0 then
					currentInstructions = 3
					board:progress()
				else
					gameCount = gameCount + 1
					if board.winner == 2 then
						AIWinCount = AIWinCount + 1
					end
					--log("AI has won "..AIWinCount.." times out of "..gameCount.." so far.")
					if saveData.score == nil then
						saveData.score = {}
					end
					if board.winner == 1 then
						saveData.score[#saveData.score+1] = 1
					else
						saveData.score[#saveData.score+1] = 0
					end
					cleanupScores()
					save(saveData)
					restart()
				end
			end
			--pick up card if in hand, put down card if on empty board space
			if handSelected > 0 and selectedCard == nil then
				log("Selected card number "..handSelected.." in hand.")
				floatingCardRates = {math.random()*4.0, math.random()*4.0}
				selectedCard = player1Hand[handSelected]
				player1Hand[handSelected] = nil
				handSelected = 0
				currentInstructions = 2
				if not areEqual(boardSelected, {0, 0}) then
					cursorCoord = {boardSelected[1], boardSelected[2]}
					boardSelected = {0, 0}
				end
			elseif selectedCard ~= nil and handSelected == 0 and board:getTile(cursorCoord) == nil then
				log("Player 1 placed "..selectedCard.name.." on the board at ["..cursorCoord[1]..", "..cursorCoord[2].."].")
				board:setTile(cursorCoord, selectedCard)
				selectedCard = nil
				player1Hand = defrag(player1Hand, 4)
				currentInstructions = 1
				player2TurnTimer = 1
				board:refresh()
			elseif selectedCard == nil and handSelected == 0 and board:getTile(cursorCoord) == nil then
				handSelected = 1
				boardSelected = {cursorCoord[1], cursorCoord[2]}
			end
		end

		if key=="x" then
			--put card back in hand if card picked up
			if selectedCard ~= nil then
				local index = returnCard(selectedCard)
				selectedCard = nil
				handSelected = index
				currentInstructions = 1
			else
				handSelected = 1
			end
		end
	end
end

function returnCard(card)
	for i=1,4 do
		if player1Hand[i] == nil then
			player1Hand[i] = card
			return i
		end
	end
end

function takePlayer2Turn()
	DEBUG_LOGGING_ON = false --todo: come up with something better
	local move = AI:calculateTurn(player2Hand, board)
	DEBUG_LOGGING_ON = true
	board:setTile(move.space, player2Hand[move.index])
	local handLength = #player2Hand
	player2Hand[move.index] = nil
	defrag(player2Hand, handLength)
	endOfRound()
end

function endOfRound()
	if board:isBoardFull() then
		neutralBot.facedown = false--check this
		playerTurnsDone = true
		currentInstructions = 3
		log("Combat starts!")
		log("The board at the start of combat:")
		log(board:toString())
	end
	board:refresh()
end

function love.update(dt)
	frameCount = frameCount + 1

	--float the selected card around a bit
	for i=1,2 do
		floatingCardOffset[i] = (math.sin(frameCount/200.0*floatingCardRates[i])*2.0) - 1.0
	end

	--make the AI player take time
	if player2TurnTimer > 0 then
		player2TurnTimer = player2TurnTimer + 1
		if player2TurnTimer > player2TurnTime then
			takePlayer2Turn()
			player2TurnTimer = 0
		end
	end

	--testmode stuff
	if testMode == true  then
		if gameCount < 1000 then
			--push random buttons
			--local randKey = math.random()
			--if randKey < 0.35 then
			--	love.keypressed("z", "z", false)
			--elseif randKey < 0.50 then
			--	love.keypressed("up", "up", false)
			--elseif randKey < 0.65 then
			--	love.keypressed("down", "down", false)
			--elseif randKey < 0.80 then
			--	love.keypressed("left", "left", false)
			--elseif randKey < 0.95 then
			--	love.keypressed("right", "right", false)
			--else
			--	love.keypressed("x", "x", false)
			--end
			--play lots of games randomly very fast
			if not playerTurnsDone then
				local move1 = AI:calculateTurnWeak(player1Hand, board)
				board:setTile(move1.space, player1Hand[move1.index])
				local handLength1 = #player1Hand
				player1Hand[move1.index] = nil
				defrag(player1Hand, handLength1)
				local move2 = AI:calculateTurn(player2Hand, board)
				board:setTile(move2.space, player2Hand[move2.index])
				local handLength2 = #player2Hand
				player2Hand[move2.index] = nil
				defrag(player2Hand, handLength2)
				endOfRound()
			else
				if board.winner == 0 then
					board:progress()
				else
					gameCount = gameCount + 1
					if board.winner == 2 then
						AIWinCount = AIWinCount + 1
					end
					log("AI has won "..AIWinCount.." times out of "..gameCount.." so far.")
					restart()
				end
			end
		elseif gameCount == 100 then
			log("The AI won "..AIWinCount.." times out of 100!")
		end
	end
end

function love.draw()
	if gameStarted == false then
		if viewingRules == false then
			love.graphics.draw(title, 0, 0)
			drawMenu()
			drawScore()
		else
			love.graphics.draw(rules, 0, 0)
		end
	else
		for x=1,board.boardWidth do
			for y=1,board.boardHeight do
				love.graphics.draw(space, boardTilePositions[x][y][1]-2, boardTilePositions[x][y][2]-2)
				local thisBot = board:getTile({x, y})
				if thisBot ~= nil then	
					drawMiniCard(thisBot, boardTilePositions[x][y])
				end
			end
		end

		--draw ability
		local selectedBot = board:getTile(cursorCoord)
		if(selectedBot ~= nil and selectedBot.facedown == true) then
			love.graphics.draw(neutralBotCard, 0, 0)
		else
			if handSelected > 0 then
				selectedBot = player1Hand[handSelected]
			end
			if selectedBot ~= nil then
				--selectedBot is the one under the cursor, selectedCard is the one we're holding :P
				love.graphics.draw(selectedBot.image, 0, 0)
				local bonusStrength = selectedBot:getTotalStrength() - selectedBot.number
				if bonusStrength ~= 0 then
					love.graphics.draw(strengthBonus[bonusStrength], 20, 50)
				end
				if selectedBot.EMP == true then
					love.graphics.draw(empIndicator, 23, 157)
				end
			elseif selectedCard ~= nil then
				love.graphics.draw(selectedCard.image, 0, 0)
			end
		end

		--cursor
		if handSelected == 0 then
			local cursorCard = board:getTile(cursorCoord)
			if cursorCard == nil then
				love.graphics.draw(spaceCursor, boardTilePositions[cursorCoord[1]][cursorCoord[2]][1], 
					boardTilePositions[cursorCoord[1]][cursorCoord[2]][2])
			else
				love.graphics.draw(cardCursor, boardTilePositions[cursorCoord[1]][cursorCoord[2]][1], 
					boardTilePositions[cursorCoord[1]][cursorCoord[2]][2])
			end
		elseif not areEqual(boardSelected, {0, 0}) then
			love.graphics.draw(spaceCursor, boardTilePositions[boardSelected[1]][boardSelected[2]][1], 
					boardTilePositions[boardSelected[1]][boardSelected[2]][2])
		end

		--selected card
		if selectedCard ~= nil then
			love.graphics.draw(shadow, 
				boardTilePositions[cursorCoord[1]][cursorCoord[2]][1]+math.floor(floatingCardOffset[1]), 
				boardTilePositions[cursorCoord[1]][cursorCoord[2]][2]+math.floor(floatingCardOffset[2]))
			drawMiniCard(selectedCard, 
				{boardTilePositions[cursorCoord[1]][cursorCoord[2]][1]+5+math.floor(floatingCardOffset[1]), 
				 boardTilePositions[cursorCoord[1]][cursorCoord[2]][2]+5+math.floor(floatingCardOffset[2])})
		end

		--thermometer
		love.graphics.draw(thermometer, 368, 0)
		if playerTurnsDone then
			for i=1,board.currentbot do
				if i <= 10 then
					if i > 1 then
						love.graphics.rectangle("fill", 380, 11+(10-i+1)*22, 9, 4)
					end
					love.graphics.draw(mercury[i], 368, 11+(10-i)*22)
				end
			end
		end

		--hands
		for i=1,4 do --todo: allow different hand sizes
			local selectedOffset = 0
			if handSelected == i then
				selectedOffset = 30
			end
			local player1Bot = player1Hand[i]
			if player1Bot ~= nil then
				drawMiniCard(player1Bot, {player1HandPositions[i][1], player1HandPositions[i][2] - selectedOffset})
			end
			local player2Bot = player2Hand[i]
			if player2Bot ~= nil then
				love.graphics.draw(cardback, player2HandPositions[i][1], player2HandPositions[i][2])
			end
		end

		--instructions
		love.graphics.draw(instructions[currentInstructions], 0, 224)
		love.graphics.draw(arrowInstructions, 0, 0)

		--victory
		if board.winner ~= 0 then
			if board.winner == 1 then
				love.graphics.draw(player1wins, 0, 88)
			elseif board.winner == 2 then
				love.graphics.draw(player2wins, 0, 88)
			elseif board.winner == 3 then
				love.graphics.draw(nbwins, 0, 88)
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
			if bot.number == nextAttacker and playerTurnsDone == true then
				love.graphics.draw(attackIndicator, 0, 0)
			end
		end)
		love.graphics.draw(canvas, position[1], position[2])
	end
end

function drawMenu()
	local padding = 5
	local bottomMargin = 20
	local menuItemHeight = menu[1].selected:getHeight()
	local totalMenuHeight = menuItemHeight*#menu + padding*(#menu-1)
	for i=1,#menu do
		local drawable
		if menuIndex == i then
			drawable = menu[i].selected
		else
			drawable = menu[i].unselected
		end
		local position = {400/2 - drawable:getWidth()/2, 240 - (totalMenuHeight + bottomMargin) + (menuItemHeight+padding)*(i-1)}
		love.graphics.draw(drawable, position[1], position[2])
	end
end

function drawScore()
	love.graphics.print("Current Score: "..score, 0, 0)
end
