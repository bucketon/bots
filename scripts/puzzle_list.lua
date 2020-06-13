Puzzle01 = {
	board = {
		{bot = Arcenbot:new(), 		coord = {1, 1}, team = 2},
		{bot = EMPBot:new(), 		coord = {2, 2}, team = 3},
		{bot = Thresher:new(), 		coord = {3, 2}, team = 2},
		{bot = Recycler:new(), 		coord = {3, 3}, team = 2},
		{bot = LaserCannon:new(), 	coord = {1, 3}, team = 2}
	},
	hand = {
		Injector:new(),
		Ratchet:new(),
		SpyBot:new(),
		Renegade:new()
	},
	deck = {Booster:new()}
}

Puzzle02 = {
	board = {
		{bot = Arcenbot:new(), 		coord = {1, 1}, team = 2},
		{bot = EMPBot:new(), 		coord = {2, 2}, team = 3},
		{bot = Thresher:new(), 		coord = {1, 2}, team = 2},
		{bot = Recycler:new(), 		coord = {2, 1}, team = 2},
		{bot = LaserCannon:new(), 	coord = {1, 3}, team = 2}
	},
	hand = {
		Injector:new(),
		Ratchet:new(),
		SpyBot:new(),
		Renegade:new()
	},
	deck = {Booster:new()}
}

PuzzleList = {
	Puzzle01,
	Puzzle02
}

return PuzzleList
