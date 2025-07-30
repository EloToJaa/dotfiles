local gpu_adapters = require("utils.gpu_adapter")

local M = {}

-- color scheme
M.color_scheme = "Catppuccin Mocha"

-- scrollbar
M.enable_scroll_bar = false

-- tab bar
M.enable_tab_bar = true
M.hide_tab_bar_if_only_one_tab = false
M.use_fancy_tab_bar = false
M.tab_max_width = 25
M.tab_bar_at_bottom = true
M.show_tab_index_in_tab_bar = false
M.switch_to_last_active_tab_when_closing_tab = true
M.tab_and_split_indices_are_zero_based = false

-- window
M.window_padding = {
	left = 3,
	right = 3,
	top = 5,
	bottom = 0,
}
M.window_background_opacity = 0.9
M.window_close_confirmation = "NeverPrompt"
M.window_frame = {
	active_titlebar_bg = "#090909",
	-- font = fonts.font,
	-- font_size = fonts.font_size,
}
-- inactive_pane_hsb = {
--    saturation = 0.9,
--    brightness = 0.65,
-- },
M.inactive_pane_hsb = {
	saturation = 1,
	brightness = 1,
}

local host = require("utils.variables").host
M.front_end = "OpenGL"
if host == "laptop" then
	-- M.front_end = "OpenGL"

	M.animation_fps = 80
	M.max_fps = 80
else
	-- M.front_end = "WebGpu"
	-- M.webgpu_power_preference = "HighPerformance"
	-- M.webgpu_preferred_adapter = gpu_adapters:pick_best()

	M.animation_fps = 200
	M.max_fps = 200
end

return M
