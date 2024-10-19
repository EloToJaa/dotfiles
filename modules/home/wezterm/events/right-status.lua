local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local ICON_STAT = nf.oct_table
local ICON_DIR = nf.oct_file_directory_fill
local ICON_USER = nf.oct_person_fill

local function get_username()
  return os.getenv('USER') or os.getenv('LOGNAME') or os.getenv('USERNAME')
end

---@param cwd any
---@return string
local function convert_cwd(cwd)
  if cwd then
    local new_cwd = string.gsub(cwd.file_path, "^/home/" .. get_username(), "~")
    if string.sub(new_cwd, -1) == "/" then
      return string.sub(new_cwd, 1, -2)
    else
      return new_cwd
    end
  else
    return ''
  end
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
    :add_segment('separator', ' ', colors.separator)
    :add_segment('dir_icon', ICON_DIR .. ' ', colors.dir, attr(attr.intensity('Bold')))
    :add_segment('dir_text', '', colors.dir, attr(attr.intensity('Bold')))
    :add_segment('user_icon', ICON_USER .. ' ', colors.dir, attr(attr.intensity('Bold')))
    :add_segment('user_text', '', colors.dir, attr(attr.intensity('Bold')))

M.setup = function()
  wezterm.on('update-right-status', function(window, pane)
    local stat = window:active_workspace()
    local cwd = convert_cwd(pane:get_current_working_dir())
    cells
        :update_segment_text('stat_text', stat)
        :update_segment_text('dir_text', cwd)
        :update_segment_text('user_text', get_username())

    window:set_right_status(
      wezterm.format(
        cells:render({ 'dir_icon', 'dir_text', 'separator', 'user_icon', 'user_text', 'separator', 'stat_icon',
          'stat_text' })
      )
    )
  end)
end

return M
