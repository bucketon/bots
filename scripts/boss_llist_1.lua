BE01 = {
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

BossEncounterList = {
	BE01,
}

return BossEncounterList
