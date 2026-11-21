local prefix = "ctrl+a"

rex.bind(prefix .. ">ctrl+a", "pane.send_key", { key = "ctrl+a" })

local function bind_prefixed(key, action, args) rex.bind(prefix .. ">" .. key, action, args) end

bind_prefixed("[", "client.tab.previous")
bind_prefixed("]", "client.tab.next")
rex.bind("ctrl+[", "client.tab.previous")
rex.bind("ctrl+]", "client.tab.next")

bind_prefixed("t", "client.tab.new")
bind_prefixed("q", "client.tab.close")
bind_prefixed("x", "pane.close")
bind_prefixed("r", "client.tab.rename")
bind_prefixed("shift+r", "client.config.reload")

bind_prefixed("v", "pane.split", { direction = "down" })
bind_prefixed("s", "pane.split", { direction = "right" })

bind_prefixed("p", "pane.paste")

for number = 1, 9 do
  rex.bind("alt+" .. number, "client.tab.goto", { index = number - 1 })
end
rex.bind("alt+0", "client.tab.goto", { index = 9 })
