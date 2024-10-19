local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local ICON_SEPARATOR = nf.oct_dash
local ICON_DATE = nf.fa_calendar
local ICON_DIR = nf.oct_file_directory_fill

-- TODO: add windows path support
local basename = function(s)
  -- Nothing a little regex can't fix
  return string.match(s, "([^/]+)/?$")
end

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
  date      = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
  dir       = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
  separator = { fg = '#74c7ec', bg = 'rgba(0, 0, 0, 0.4)' }
}

local cells = Cells:new()

cells
    :add_segment('date_icon', ICON_DATE .. '  ', colors.date, attr(attr.intensity('Bold')))
    :add_segment('date_text', '', colors.date, attr(attr.intensity('Bold')))
    :add_segment('separator', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('dir_icon', ICON_DIR .. ' ', colors.dir, attr(attr.intensity('Bold')))
    :add_segment('dir_text', '', colors.dir, attr(attr.intensity('Bold')))

M.setup = function()
  wezterm.on('update-right-status', function(window, pane)
    local cwd = pane:get_current_working_dir()
    wezterm.log_info('cwd', cwd.file_path)
    if cwd then
      cwd = basename(cwd.file_path)
    else
      cwd = ""
    end
    wezterm.log_info('cwd processed', cwd)
    cells
        :update_segment_text('date_text', wezterm.strftime('%a %H:%M:%S'))
        :update_segment_text('dir_text', cwd)

    window:set_right_status(
      wezterm.format(
        cells:render({ 'date_icon', 'date_text', 'separator', 'dir_icon', 'dir_text' })
      )
    )
  end)
end

return M
