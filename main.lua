function love.load()
	require("scripts/manifest")
	require("scripts/utilities")
	require("scripts/board_renderer")
	Bot = require("scripts/bot")
	Bots = require("scripts/base_bots")
	Gameboard = require("scripts/gameboard")
	AI = require("scripts/AI")
	blobReader = require("lib/BlobReader")
	blobWriter = require("lib/BlobWriter")
	math.randomseed(os.time())
	version = "0.5.0"
	love.window.setTitle("Bots "..version)
	love.graphics.setColor(1, 1, 1, 1)
	font = love.graphics.newFont(18, "mono")
	love.graphics.setFont(font)
	saveData = load()
	relevantScoresCount = 100

	boardOffset = {160, 16}
	boardTileDimensions = {64, 64}
	boardTilePadding = 5

	player1HandPositions = {}
	for i=1,4 do
		player1HandPositions[i] = {boardOffset[1]+(i-1)*50, 220}
	end
	player2HandPositions = {}
	for i=1,4 do
		player2HandPositions[i] = {boardOffset[1]+(i-1)*50, -50}
	end

	--The good stuff™
	currentMode = {}
	push(currentMode, require('scripts/title'))
	currentMode[#currentMode]:setup()
end

function love.keypressed(key, scancode, isrepeat)
	currentMode[#currentMode]:keypressed(key)
end

function love.update(dt)
	currentMode[#currentMode]:update(dt)
end

function love.draw()
	currentMode[#currentMode]:draw()
end
