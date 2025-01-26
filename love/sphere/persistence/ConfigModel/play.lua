---@class sphere.PlayConfig
local play = {
	const = false,
	rate = 1,
	modifiers = {},
	timings = {
		nearest = false,
		ShortNote = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16}
		},
		LongNoteStart = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16},
		},
		LongNoteEnd = {
			hit = {-0.12, 0.12},
			miss = {-0.16, 0.16}
		}
	}
}

play.timings = {
	LongNoteEnd = {
		hit = {
			-0.127,
			0.103
		},
		miss = {
			-0.164,
			0.103
		}
	},
	LongNoteStart = {
		hit = {
			-0.127,
			0.103
		},
		miss = {
			-0.164,
			0.103
		}
	},
	ShortNote = {
		hit = {
			-0.127,
			0.103
		},
		miss = {
			-0.164,
			0.103
		}
	},
	nearest = false
}

return play
