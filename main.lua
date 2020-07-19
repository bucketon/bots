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
    if saveData.SortHands == nil then
		saveData.SortHands = false
	end
	if saveData.ShowSpeed == nil then
		saveData.ShowSpeed = false
	end
	love.graphics.setDefaultFilter("nearest","nearest")
	require("scripts/manifest")
	require("scripts/board_renderer")
	Bot = require("scripts/bot")
	Bots = require("scripts/base_bots")
	AllBots = require("scripts/extended_bots")
	Gameboard = require("scripts/gameboard")
	AI = require("scripts/AI")
	PauseMode = require("scripts/pause")
	HandCursor = require("scripts/hand_cursor")
	BoardCursor = require("scripts/board_cursor")
	math.randomseed(os.time())
	version = "0.8.0"
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

function love.textinput(text)
	if currentMode[#currentMode].textinput ~= nil then
		currentMode[#currentMode]:textinput(text)
	end
end

function love.update(dt)
	frameCount = frameCount + 1

	--test
	local boostsSize = 15
	if boosts == nil then
		boosts = {}
	end
	if frameCount%2 == 0 then
		if #boosts < boostsSize then
			push(boosts, {math.random(64), math.random(64), 15})
		end
		for i=1,#boosts do
			boosts[i][2] = boosts[i][2] - 1
			boosts[i][3] = boosts[i][3] - 1
			if boosts[i][3] < 0 then
				boosts[i] = nil
			end
		end
		boosts = defrag(boosts, boostsSize)
	end
	--end test

	currentMode[#currentMode]:update(dt)
end

function love.draw()
	if saveData.DoubleResolution == true then
		love.graphics.scale(2.0, 2.0)
	end
	currentMode[#currentMode]:draw()
end
