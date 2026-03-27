local padding <const> = {
	background = 8,
	icon = 10,
	label = 8,
	bar = 9,
	left = 12,
	right = 12,
	item = 18,
	popup = 8,
}

local graphics <const> = {
	bar = {
		height = 32,
		offset = 5,
	},
	background = {
		height = 0,
		corner_radius = 15,
	},
	slider = {
		height = 0,
	},
	popup = {
		width = 200,
		large_width = 300,
	},
	blur_radius = 60,
}

local text <const> = {
	icon = 16.0,
	label = 14.0,
}

return {
	padding = padding,
	graphics = graphics,
	text = text,
}
