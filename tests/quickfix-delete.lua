local root = assert(vim.env.REVIEW_TEST_DIR)
local delete = dofile(root .. "/delete.lua")
local path = root .. "/source.txt"
vim.fn.writefile({ "first", "second", "third" }, path)
vim.cmd.edit(path)
local buf = vim.api.nvim_get_current_buf()
local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
_G.ReviewQuickfixText = function() return { "one", "two", "three" } end
local function setup(idx, count)
  local items = {}
  for i = 1, count do
    items[i] = { bufnr = buf, lnum = i, text = tostring(i), user_data = { entry = i } }
  end
  vim.fn.setqflist({}, " ", {
    items = items,
    idx = idx,
    title = "review test",
    context = { origin = "review" },
    quickfixtextfunc = "v:lua.ReviewQuickfixText",
  })
  return vim.fn.getqflist({ all = 0 })
end
local function check(before, expected, idx)
  local after = vim.fn.getqflist({ all = 0 })
  assert(after.id == before.id and after.nr == before.nr)
  assert(after.title == before.title and vim.deep_equal(after.context, before.context))
  assert(after.quickfixtextfunc == before.quickfixtextfunc)
  assert(#after.items == #expected and after.idx == idx, vim.inspect(after))
  for i, n in ipairs(expected) do
    assert(after.items[i].text == tostring(n))
    assert(after.items[i].user_data.entry == n)
  end
  assert(vim.deep_equal(original, vim.api.nvim_buf_get_lines(buf, 0, -1, false)))
  assert(not vim.bo[buf].modified)
  assert(vim.deep_equal(original, vim.fn.readfile(path)))
end
local before = setup(2, 3)
delete()
check(before, { 1, 3 }, 2)
before = setup(3, 3)
delete()
check(before, { 1, 2 }, 2)
before = setup(1, 1)
delete()
check(before, {}, 0)
delete()
check(before, {}, 0)
before = setup(3, 3)
vim.cmd.copen()
vim.api.nvim_win_set_cursor(0, { 1, 0 })
delete()
check(before, { 2, 3 }, 2)
assert(vim.api.nvim_win_get_cursor(0)[1] == 1)
vim.api.nvim_win_set_cursor(0, { 2, 0 })
delete()
check(before, { 2 }, 1)
vim.cmd.cclose()
vim.fn.setloclist(0, { { bufnr = buf, lnum = 1, text = "local" } }, " ")
vim.cmd.lopen()
local qf = vim.fn.getqflist({ all = 0 })
delete()
assert(vim.deep_equal(qf, vim.fn.getqflist({ all = 0 })))
assert(#vim.fn.getloclist(0) == 1)
vim.cmd.lclose()
vim.o.undodir = root .. "/undo/nested"
vim.o.undofile = true
vim.fn.mkdir(vim.o.undodir, "p", 448)
assert(vim.fn.isdirectory(vim.o.undodir) == 1)
vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "changed" })
vim.cmd.write()
assert(vim.fn.filereadable(vim.fn.undofile(path)) == 1)
print(
  "PASS: quickfix deletion, metadata/index, empty list, location-list guard, unchanged source buffers/files, persistent undo"
)
