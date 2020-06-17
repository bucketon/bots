EE01 = {
	board = {
		{bot = Arcenbot:new(), 		coord = {1, 1}, team = 2},
		{bot = EMPBot:new(), 		coord = {2, 2}, team = 3},
		{bot = Thresher:new(), 		coord = {3, 2}, team = 2},
		{bot = Recycler:new(), 		coord = {3, 3}, team = 2},
		{bot = LaserCannon:new(), 	coord = {1, 3}, team = 2}
	},
	hand = {
		{bot = Injector:new(), team = 1},
		{bot = Ratchet:new(), team = 1},
		{bot = SpyBot:new(), team = 1},
		{bot = Renegade:new(), team = 1}
	},
	deck = {Booster:new()}
}

EE02 = {
	board = {
		{bot = Arcenbot:new(), 		coord = {1, 1}, team = 2},
		{bot = EMPBot:new(), 		coord = {2, 2}, team = 3},
		{bot = Thresher:new(), 		coord = {1, 2}, team = 2},
		{bot = Recycler:new(), 		coord = {2, 1}, team = 2},
		{bot = LaserCannon:new(), 	coord = {1, 3}, team = 2}
	},
	hand = {
		{bot = Booster:new(), team = 1},
		{bot = Ratchet:new(), team = 1},
		{bot = SpyBot:new(), team = 1},
		{bot = Injector:new(), team = 1}
	},
	deck = {Renegade:new()}
}

EE03 = {
	board = {
		{bot = Booster:new(), 		coord = {1, 1}, team = 2},
		{bot = Ratchet:new(), 		coord = {3, 1}, team = 2},
		{bot = Recycler:new(), 		coord = {3, 2}, team = 2},
		{bot = Renegade:new(), 		coord = {1, 3}, team = 2},
		{bot = LaserCannon:new(), 	coord = {2, 2}, team = 3}
	},
	hand = {
		{bot = Injector:new(), team = 1},
		{bot = EMPBot:new(), team = 1},
		{bot = Arcenbot:new(), team = 1},
		{bot = Thresher:new(), team = 1}
	},
	deck = {SpyBot:new()}
}

EliteEncounterList = {
	EE01,
	EE02,
	EE03
}

return EliteEncounterList
