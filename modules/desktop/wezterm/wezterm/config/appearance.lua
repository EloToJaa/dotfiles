local gpu_adapters = require("utils.gpu_adapter")
-- local colors = require('colors.custom')

return {
	animation_fps = 60,
	max_fps = 60,
	front_end = "WebGpu",
	webgpu_power_preference = "HighPerformance",
	webgpu_preferred_adapter = gpu_adapters:pick_best(),

	-- color scheme
	-- colors = colors,
	color_scheme = "Catppuccin Mocha",

	-- scrollbar
	enable_scroll_bar = false,

	-- tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_max_width = 25,
	tab_bar_at_bottom = true,
	show_tab_index_in_tab_bar = false,
	switch_to_last_active_tab_when_closing_tab = true,
	tab_and_split_indices_are_zero_based = false,

	-- window
	window_padding = {
		left = 3,
		right = 3,
		top = 5,
		bottom = 0,
	},
	window_background_opacity = 0.9,
	window_close_confirmation = "NeverPrompt",
	window_frame = {
		active_titlebar_bg = "#090909",
		-- font = fonts.font,
		-- font_size = fonts.font_size,
	},
	-- inactive_pane_hsb = {
	--    saturation = 0.9,
	--    brightness = 0.65,
	-- },
	inactive_pane_hsb = {
		saturation = 1,
		brightness = 1,
	},
}