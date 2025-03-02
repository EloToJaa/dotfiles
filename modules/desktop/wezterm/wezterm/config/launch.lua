local platform = require("utils.platform")

local options = {
	default_prog = {},
	launch_menu = {},
}

if platform.is_win then
	options.default_prog = { "pwsh", "-NoLogo" }
	options.launch_menu = {
		{ label = "PowerShell Core", args = { "pwsh", "-NoLogo" } },
		{ label = "PowerShell Desktop", args = { "powershell" } },
		{ label = "Command Prompt", args = { "cmd" } },
		{ label = "Nushell", args = { "nu" } },
	}
elseif platform.is_mac then
	options.default_prog = { "/opt/homebrew/bin/fish", "-l" }
	options.launch_menu = {
		{ label = "Bash", args = { "bash", "-l" } },
		{ label = "Nushell", args = { "/opt/homebrew/bin/nu", "-l" } },
		{ label = "Zsh", args = { "zsh", "-l" } },
	}
elseif platform.is_linux then
	options.default_prog = { "nu", "-l" }
	options.launch_menu = {
		{ label = "Bash", args = { "bash", "-l" } },
		{ label = "Zsh", args = { "zsh", "-l" } },
		{ label = "Nushell", args = { "nu", "-l" } },
	}
end

return options
