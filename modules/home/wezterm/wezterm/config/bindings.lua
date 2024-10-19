local wezterm = require 'wezterm'
local act = wezterm.action

local keys = {
  -- Send C-a when pressing C-a twice
  { key = 'a',          mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'c',          mods = 'LEADER',      action = act.ActivateCopyMode },
  { key = 'phys:Space', mods = 'LEADER',      action = act.ActivateCommandPalette },

  -- Pane keybindings
  { key = 'v',          mods = 'LEADER',      action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 's',          mods = 'LEADER',      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'h',          mods = 'LEADER',      action = act.ActivatePaneDirection('Left') },
  { key = 'j',          mods = 'LEADER',      action = act.ActivatePaneDirection('Down') },
  { key = 'k',          mods = 'LEADER',      action = act.ActivatePaneDirection('Up') },
  { key = 'l',          mods = 'LEADER',      action = act.ActivatePaneDirection('Right') },
  { key = 'LeftArrow',  mods = 'LEADER',      action = act.ActivatePaneDirection('Left') },
  { key = 'DownArrow',  mods = 'LEADER',      action = act.ActivatePaneDirection('Down') },
  { key = 'UpArrow',    mods = 'LEADER',      action = act.ActivatePaneDirection('Up') },
  { key = 'RightArrow', mods = 'LEADER',      action = act.ActivatePaneDirection('Right') },
  { key = 'x',          mods = 'LEADER',      action = act.CloseCurrentPane { confirm = false } },
  { key = 'q',          mods = 'LEADER',      action = act.CloseCurrentTab { confirm = false } },
  { key = 'z',          mods = 'LEADER',      action = act.TogglePaneZoomState },
  { key = 'o',          mods = 'LEADER',      action = act.RotatePanes 'Clockwise' },
  {
    key = 'u',
    mods = 'LEADER',
    action = act.QuickSelectArgs({
      label = 'open url',
      patterns = {
        '\\((https?://\\S+)\\)',
        '\\[(https?://\\S+)\\]',
        '\\{(https?://\\S+)\\}',
        '<(https?://\\S+)>',
        '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. url)
        wezterm.open_with(url)
      end),
    }),
  },
  -- We can make separate keybindings for resizing panes
  -- But Wezterm offers custom 'mode' in the name of 'KeyTable'
  { key = 'r', mods = 'LEADER',       action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

  -- Tab keybindings
  { key = 't', mods = 'LEADER',       action = act.SpawnTab('CurrentPaneDomain') },
  { key = '[', mods = 'LEADER',       action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'LEADER',       action = act.ActivateTabRelative(1) },
  { key = 'n', mods = 'LEADER',       action = act.ShowTabNavigator },

  -- rename tab
  { key = 'e', mods = 'LEADER',       action = act.EmitEvent('tabs.manual-update-tab-title') },
  -- { key = 'e', mods = 'LEADER',       action = act.EmitEvent('tabs.reset-tab-title') },

  -- Key table for moving tabs around
  { key = 'm', mods = 'LEADER',       action = act.ActivateKeyTable { name = 'move_tab', one_shot = false } },
  -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
  { key = '{', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '}', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(1) },

  -- Lastly, workspace
  { key = 'w', mods = 'LEADER',       action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
}

for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1)
  })
end
table.insert(keys, {
  key = '0',
  mods = 'LEADER',
  action = act.ActivateTab(9)
})

local key_tables = {
  resize_pane = {
    { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape',     action = 'PopKeyTable' },
    { key = 'Enter',      action = 'PopKeyTable' },
  },
  move_tab = {
    { key = 'h',          action = act.MoveTabRelative(-1) },
    { key = 'j',          action = act.MoveTabRelative(-1) },
    { key = 'k',          action = act.MoveTabRelative(1) },
    { key = 'l',          action = act.MoveTabRelative(1) },
    { key = 'LeftArrow',  action = act.MoveTabRelative(-1) },
    { key = 'DownArrow',  action = act.MoveTabRelative(-1) },
    { key = 'UpArrow',    action = act.MoveTabRelative(1) },
    { key = 'RightArrow', action = act.MoveTabRelative(1) },
    { key = 'Escape',     action = 'PopKeyTable' },
    { key = 'Enter',      action = 'PopKeyTable' },
  }
}
-- remove copy on highlight
local mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.Nop,
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

return {
  disable_default_key_bindings = true,
  leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 },
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
