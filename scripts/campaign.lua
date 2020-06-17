CampaignMode = {}

--[[
This is a mostly noninteractive view that shows the map and various stats, and serves as the entrypoint and exit point from campaign
mode. While it is also a view, its primary function is to act as data wrangler for campaign mode and to allow smooth transitions
between segments. It also handles globally necessary functions like saving and loading, and owns the resources for building levels.
]]--

function CampaignMode:setup()
	self.campaign = self:loadFile(saveData)
	self.masterDeck = self:starterDeck()
end

function CampaignMode:starterDeck()
	local deck = {}
end

function CampaignMode:loadFile(data)
	if data.campaign == nil then
		data.campaign = {}
		data.campaign.popularity = 3
		--initialize campaign here.
	end
	return data.campaign
end

function CampaignMode:saveFile(campaign)
	data.campaign = campaign
end

function CampaignMode:keypressed(key)
	if key == "z" then

	end
	if key == "x" then

	end
	if key == "up" then

	end
	if key == "down" then

	end
end

function CampaignMode:update(dt)

end

function CampaignMode:draw()

end

return CampaignMode
