local prefix = "ctrl+a"
local terminal = "com.superlogical.terminal"

rex.bind(prefix .. ">ctrl+a", "pane.send_key", { key = "ctrl+a" })

local function bind_prefixed(key, action, args) rex.bind(prefix .. ">" .. key, action, args) end

local vim_like_processes = {
  fzf = true,
  nvim = true,
  vi = true,
  view = true,
  vim = true,
}

local function foreground_process(block_id)
  if block_id == nil then
    return nil
  end
  local process = rex.block.call(terminal, "process", { block_id = block_id })
  if process == nil then
    return nil
  end
  return process.foreground
end

local function is_vim_like(block_id)
  local foreground = foreground_process(block_id)
  if foreground == nil then
    return false
  end
  return vim_like_processes[foreground.name] == true
end

local function pane_directory(block_id)
  if block_id == nil then
    return nil
  end
  local reported = rex.block.call(terminal, "pwd", { block_id = block_id })
  if reported ~= nil and reported.pwd ~= nil then
    return reported.pwd
  end
  local foreground = foreground_process(block_id)
  if foreground == nil then
    return nil
  end
  return foreground.cwd
end

-- Mirrors tmux smart-splits: Neovim and fzf get the key so they can move between their own splits.
local function smart_pane_action(name, title, pane_action)
  rex.action({
    name = name,
    title = title,
    args = { direction = "string", key = "string" },
    repeats = true,
    run = function(ctx, args)
      if is_vim_like(ctx.block_id) then
        rex.client.queue("pane.send_key", { key = args.key })
        return
      end
      rex.client.queue(pane_action, { direction = args.direction })
    end,
  })
end

smart_pane_action("smart_focus", "Focus pane or Neovim split", "pane.focus")
smart_pane_action("smart_resize", "Resize pane or Neovim split", "pane.resize")

rex.action({
  name = "popup",
  title = "Open popup",
  args = { command = "array", here = "boolean?" },
  run = function(ctx, args)
    local options = { command = args.command }
    if args.here then
      options.cwd = pane_directory(ctx.block_id)
    end
    local _, err = rex.session.new_layer({
      bounds = { 0.075, 0.05, 0.85, 0.9 },
      focus = true,
      layout = rex.layout.block({ flavor = terminal .. ".shell", options = options }),
    })
    if err ~= nil then
      error(err, 0)
    end
  end,
})

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  rex.bind("ctrl+" .. key, "smart_focus", { direction = direction, key = "ctrl+" .. key })
  rex.bind("alt+" .. key, "smart_resize", { direction = direction, key = "alt+" .. key })
end

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

bind_prefixed("z", "pane.zoom")
bind_prefixed("o", "pane.focus_next")
bind_prefixed("=", "pane.balance")

bind_prefixed("w", "session.switch")
bind_prefixed("shift+9", "session.previous")
bind_prefixed("shift+0", "session.next")

bind_prefixed("p", "pane.paste")

bind_prefixed("m", "popup", { command = { "btop" } })
bind_prefixed("g", "popup", { command = { "lazygit" }, here = true })
bind_prefixed("shift+g", "popup", { command = { "gh", "dash" } })

for number = 1, 9 do
  rex.bind("alt+" .. number, "client.tab.goto", { index = number - 1 })
end
rex.bind("alt+0", "client.tab.goto", { index = 9 })
