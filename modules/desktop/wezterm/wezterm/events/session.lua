local session_manager = require("utils.session-manager")
local wezterm = require("wezterm")

wezterm.on("save-session", function(window) session_manager.save_state(window) end)
wezterm.on("load-session", function(window) session_manager.load_state(window) end)
wezterm.on("restore-session", function(window) session_manager.restore_state(window) end)
