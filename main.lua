function love.load()
	require("scripts/manifest")
	require("scripts/utilities")
	require("scripts/board_renderer")
	Bot = require("scripts/bot")
	Bots = require("scripts/base_bots")
	Gameboard = require("scripts/gameboard")
	AI = require("scripts/AI")
	HandCursor = require("scripts/hand_cursor")
	BoardCursor = require("scripts/board_cursor")
	blobReader = require("lib/BlobReader")
	blobWriter = require("lib/BlobWriter")
	math.randomseed(os.time())
	version = "0.5.0"
	love.window.setTitle("Bots "..version)
	love.graphics.setColor(1, 1, 1, 1)
	font = love.graphics.newFont(18, "mono")
	love.graphics.setFont(font)
	saveData = load()
	saveData.version = version
	save(saveData)
	relevantScoresCount = 100
	frameCount = 0
	floatingCardRates = {0, 0}

	boardOffset = {160, 16}
	boardTileDimensions = {64, 64}
	boardTilePadding = 5

	--The good stuff™
	currentMode = {}
	push(currentMode, require('scripts/title'))
	currentMode[#currentMode]:setup()
end

function love.keypressed(key, scancode, isrepeat)
	currentMode[#currentMode]:keypressed(key)
end

function love.update(dt)
	frameCount = frameCount + 1
	currentMode[#currentMode]:update(dt)
end

function love.draw()
	currentMode[#currentMode]:draw()
end
