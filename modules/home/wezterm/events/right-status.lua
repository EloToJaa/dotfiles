local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local ICON_SEPARATOR = nf.oct_dash
local ICON_STAT = nf.oct_table
local ICON_DIR = nf.oct_file_directory_fill

-- TODO: add windows path support
local function basename(s)
  -- Nothing a little regex can't fix
  return string.match(s, "([^/]+)/?$")
end

local function get_cwd(pane)
  local cwd = pane:get_current_working_dir()
  if cwd then
    cwd = basename(cwd.file_path)
  else
    cwd = ""
  end
  return cwd
end

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
  stat      = { fg = '#f7768e', bg = 'rgba(0, 0, 0, 0.4)' },
  dir       = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
  separator = { fg = '#74c7ec', bg = 'rgba(0, 0, 0, 0.4)' }
}

local cells = Cells:new()

cells
    :add_segment('stat_icon', ICON_STAT .. '  ', colors.date, attr(attr.intensity('Bold')))
    :add_segment('stat_text', '', colors.date, attr(attr.intensity('Bold')))
    :add_segment('separator', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('dir_icon', ICON_DIR .. ' ', colors.dir, attr(attr.intensity('Bold')))
    :add_segment('dir_text', '', colors.dir, attr(attr.intensity('Bold')))

M.setup = function()
  wezterm.on('update-right-status', function(window, pane)
    local stat = window:active_workspace()
    local cwd = get_cwd(pane)
    cells
        :update_segment_text('stat_text', stat)
        :update_segment_text('dir_text', cwd)

    window:set_right_status(
      wezterm.format(
        cells:render({ 'stat_icon', 'stat_text', 'separator', 'dir_icon', 'dir_text' })
      )
    )
  end)
end

return M
