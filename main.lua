function love.load()
	blobReader = require("lib/BlobReader")
	blobWriter = require("lib/BlobWriter")
	require("scripts/utilities")
	saveData = load()
	if saveData.DoubleResolution == nil then
		saveData.DoubleResolution = false
	end
	if saveData.DoubleResolution == true then
		love.window.setMode(800, 480)
    else
    	love.window.setMode(400, 240)
    end
	love.graphics.setDefaultFilter("nearest","nearest")
	require("scripts/manifest")
	require("scripts/board_renderer")
	Bot = require("scripts/bot")
	Bots = require("scripts/base_bots")
	Gameboard = require("scripts/gameboard")
	AI = require("scripts/AI")
	PauseMode = require("scripts/pause")
	HandCursor = require("scripts/hand_cursor")
	BoardCursor = require("scripts/board_cursor")
	math.randomseed(os.time())
	version = "0.5.0"
	love.window.setTitle("Bots "..version)
	love.graphics.setColor(1, 1, 1, 1)
	font = love.graphics.newFont(18, "mono")
	love.graphics.setFont(font)
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
	if saveData.DoubleResolution == true then
		love.graphics.scale(2.0, 2.0)
	end
	currentMode[#currentMode]:draw()
end
