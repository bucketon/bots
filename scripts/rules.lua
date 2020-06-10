RulesMode = {}

function RulesMode:setup()
	self.rules = love.graphics.newImage("assets/rules.png")
end

function RulesMode:keypressed(key)
	if key == "x" then pop(currentMode) end--replace viewingRules with state transition
end

function RulesMode:update(dt)

end

function RulesMode:draw()
	love.graphics.draw(self.rules, 0, 0)
end

return RulesMode
