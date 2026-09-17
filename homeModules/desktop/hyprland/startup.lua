local variables = require("variables")

hl.on("hyprland.start", function()
	-- Home Manager's Hyprland target starts DMS and other user services.
	hl.exec_cmd("systemctl --user import-environment --all")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")

	hl.exec_cmd("udiskie --automount --notify --smart-tray")
	hl.exec_cmd(variables.discord)
	hl.exec_cmd("valent --gapplication-service")
	hl.exec_cmd("ntfy subscribe --from-config")
end)
