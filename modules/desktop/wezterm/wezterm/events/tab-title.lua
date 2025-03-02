------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local Cells = require("utils.cells")
local wezterm = require("wezterm")

local nf = wezterm.nerdfonts
local attr = Cells.attr

local GLYPH_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local GLYPH_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick .. " " --[[  ]]
local GLYPH_CIRCLE = nf.fa_circle --[[  ]]
local GLYPH_DEBUG = nf.fa_bug --[[  ]]
local GLYPH_SEARCH = nf.fa_search --[[  ]]

local TITLE_INSET = {
	DEFAULT = 6,
	ICON = 8,
}

local M = {}

local RENDER_VARIANTS = {
	{ "scircle_left", "index", "title", "padding", "scircle_right" },
	{ "scircle_left", "index", "title", "unseen_output", "padding", "scircle_right" },
}

local palette = {
	circle_bg = "rgba(0, 0, 0, 0.4)",
	index_bg = "#FFA066",
	text_default_bg = "#313244",
	text_hover_bg = "#74c7ec",
	text_active_bg = "#89b4fa",
	text_default_fg = "#89B4FA",
	text_hover_fg = "#181825",
	text_active_fg = "#181825",
	index_text = "#181825",
}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
  text_default          = { bg = palette.text_default_bg, fg = palette.text_default_fg },
  text_hover            = { bg = palette.text_hover_bg, fg = palette.text_hover_fg },
  text_active           = { bg = palette.text_active_bg, fg = palette.text_active_fg },

  unseen_output_default = { bg = palette.text_default_bg, fg = palette.index_bg },
  unseen_output_hover   = { bg = palette.text_hover_bg, fg = palette.index_bg },
  unseen_output_active  = { bg = palette.text_active_bg, fg = palette.index_bg },

  index_default         = { bg = palette.index_bg, fg = palette.index_text },
  index_hover           = { bg = palette.index_bg, fg = palette.index_text },
  index_active          = { bg = palette.index_bg, fg = palette.index_text },

  scircle_left_default  = { bg = palette.circle_bg, fg = palette.index_bg },
  scircle_left_hover    = { bg = palette.circle_bg, fg = palette.index_bg },
  scircle_left_active   = { bg = palette.circle_bg, fg = palette.index_bg },

  scircle_right_default = { bg = palette.circle_bg, fg = palette.text_default_bg },
  scircle_right_hover   = { bg = palette.circle_bg, fg = palette.text_hover_bg },
  scircle_right_active  = { bg = palette.circle_bg, fg = palette.text_active_bg },
}

---@param proc string
local function clean_process_name(proc)
	local a = string.gsub(proc, "(.*[/\\])(.*)", "%2")
	return a:gsub("%.exe$", "")
end

-- TODO: add windows path support
local function basename(s)
	-- Nothing a little regex can't fix
	return string.match(s, "([^/]+)/?$")
end

local function get_dir_name(cwd)
	local dir_name = cwd
	if dir_name then
		dir_name = basename(dir_name.file_path)
	else
		dir_name = ""
	end
	return dir_name
end

---@param process_name string
---@param dir_name string
---@param base_title string
---@param max_width number
---@param inset number
local function create_title(process_name, dir_name, base_title, max_width, inset)
	local title

	if process_name:len() > 0 then
		if dir_name == "" then
			title = process_name
		else
			title = process_name .. " in " .. dir_name
		end
	else
		title = base_title
	end

	if base_title == "Debug" then
		title = GLYPH_DEBUG .. " DEBUG"
		inset = inset - 2
	end

	if base_title:match("^InputSelector:") ~= nil then
		title = base_title:gsub("InputSelector:", GLYPH_SEARCH)
		inset = inset - 2
	end

	if title:len() > max_width - inset then
		local diff = title:len() - max_width + inset
		title = title:sub(1, title:len() - diff)
	else
		local padding = max_width - title:len() - inset
		title = title .. string.rep(" ", padding)
	end

	return title
end

---@class Tab
---@field title string
---@field index number
---@field cells Cells
---@field title_locked boolean
---@field unseen_output boolean
---@field is_active boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
	local tab = {
		title = "",
		cells = Cells:new(),
		title_locked = false,
		unseen_output = false,
	}
	return setmetatable(tab, self)
end

---@param pane any WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
function Tab:set_info(pane, max_width, tab_id)
	local process_name = clean_process_name(pane.foreground_process_name)
	local dir_name = get_dir_name(pane.current_working_dir)
	self.unseen_output = pane.has_unseen_output
	self.index = tab_id

	if self.title_locked then
		return
	end
	local inset = TITLE_INSET.DEFAULT
	if self.unseen_output then
		inset = inset + 2
	end
	self.title = create_title(process_name, dir_name, pane.title, max_width, inset)
end

function Tab:set_cells()
	self.cells
		:add_segment("scircle_left", GLYPH_SCIRCLE_LEFT)
		:add_segment("index", " ", nil, attr(attr.intensity("Bold")))
		:add_segment("title", " ", nil, attr(attr.intensity("Bold")))
		:add_segment("unseen_output", " " .. GLYPH_CIRCLE)
		:add_segment("padding", " ")
		:add_segment("scircle_right", GLYPH_SCIRCLE_RIGHT)
end

---@param title string
function Tab:update_and_lock_title(title)
	self.title = title
	self.title_locked = true
end

---@param is_active boolean
---@param hover boolean
function Tab:update_cells(is_active, hover)
	local tab_state = "default"
	if is_active then
		tab_state = "active"
	elseif hover then
		tab_state = "hover"
	end

	self.cells:update_segment_text("title", " " .. self.title)
	self.cells:update_segment_text("index", (self.index + 1) .. " ")
	self.cells
		:update_segment_colors("scircle_left", colors["scircle_left_" .. tab_state])
		:update_segment_colors("index", colors["index_" .. tab_state])
		:update_segment_colors("title", colors["text_" .. tab_state])
		:update_segment_colors("unseen_output", colors["unseen_output_" .. tab_state])
		:update_segment_colors("padding", colors["text_" .. tab_state])
		:update_segment_colors("scircle_right", colors["scircle_right_" .. tab_state])
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
	local variant_idx = 1

	if self.unseen_output then
		variant_idx = variant_idx + 1
	end
	return self.cells:render(RENDER_VARIANTS[variant_idx])
end

---@type Tab[]
M.tab_list = {}

M.setup = function()
	local enable_tab_bar = true

	-- CUSTOM EVENT
	-- Event listener to manually update the tab name
	-- Tab name will remain locked until the `reset-tab-title` is triggered
	wezterm.on("tabs.manual-update-tab-title", function(window, pane)
		window:perform_action(
			wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Foreground = { Color = "#FFFFFF" } },
					{ Attribute = { Intensity = "Bold" } },
					{ Text = "Enter new name for tab" },
				}),
				action = wezterm.action_callback(function(_window, _pane, line)
					if line ~= nil then
						local tab = window:active_tab()
						local id = tab:tab_id()
						M.tab_list[id]:update_and_lock_title(line)
					end
				end),
			}),
			pane
		)
	end)

	-- CUSTOM EVENT
	-- Event listener to unlock manually set tab name
	wezterm.on("tabs.reset-tab-title", function(window, _pane)
		local tab = window:active_tab()
		local id = tab:tab_id()
		M.tab_list[id].title_locked = false
	end)

	-- CUSTOM EVENT
	-- Event listener to manually update the tab name
	wezterm.on("tabs.toggle-tab-bar", function(window, _pane)
		enable_tab_bar = not enable_tab_bar
		window:set_config_overrides({ enable_tab_bar = enable_tab_bar })
	end)

	-- BUILTIN EVENT
	wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
		if not M.tab_list[tab.tab_id] then
			M.tab_list[tab.tab_id] = Tab:new()
			M.tab_list[tab.tab_id]:set_info(tab.active_pane, max_width, tab.tab_index)
			M.tab_list[tab.tab_id]:set_cells()
			return M.tab_list[tab.tab_id]:render()
		end

		M.tab_list[tab.tab_id]:set_info(tab.active_pane, max_width, tab.tab_index)
		M.tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
		return M.tab_list[tab.tab_id]:render()
	end)
end

return M
