Puzzle01 = {
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

Puzzle02 = {
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

Puzzle03 = {
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

Puzzle04 = {
	board = {
		{bot = Renegade:new(), 		coord = {1, 1}, team = 2},
		{bot = Booster:new(), 		coord = {2, 1}, team = 2},
		{bot = SpyBot:new(), 		coord = {1, 3}, team = 2},
		{bot = LaserCannon:new(), 	coord = {3, 3}, team = 2},
		{bot = Injector:new(), 		coord = {2, 2}, team = 3}
	},
	hand = {
		{bot = Arcenbot:new(), team = 1},
		{bot = Ratchet:new(), team = 1},
		{bot = EMPBot:new(), team = 1},
		{bot = Recycler:new(), team = 1}
	},
	deck = {Thresher:new()}
}

Puzzle05 = {
	board = {
		{bot = Recycler:new(), 		coord = {2, 1}, team = 2},
		{bot = Thresher:new(), 		coord = {2, 2}, team = 3},
		{bot = Arcenbot:new(), 		coord = {3, 2}, team = 2},
		{bot = LaserCannon:new(), 	coord = {1, 2}, team = 2},
		{bot = Renegade:new(), 		coord = {2, 3}, team = 2}
	},
	hand = {
		{bot = Injector:new(), team = 1},
		{bot = Ratchet:new(), team = 1},
		{bot = EMPBot:new(), team = 1},
		{bot = Booster:new(), team = 1}
	},
	deck = {SpyBot:new()}
}

PuzzleList = {
	Puzzle01,
	Puzzle02,
	Puzzle03,
	Puzzle04,
	Puzzle05,
}

return PuzzleList
