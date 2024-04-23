-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.api.nvim_create_user_command("SetWidth",
  function(opts)
    print(vim.inspect(opts.args))
    local width = tonumber(opts.args)
    vim.opt.tabstop = width
    vim.opt.shiftwidth = width
    vim.opt.softtabstop = width
    print("Changed tab width to " .. width)
  end,
  { nargs = 1, desc = "Set tab width" }
)

vim.api.nvim_create_user_command("GetWidth",
  function()
    local ts = vim.opt.tabstop:get()
    local sw = vim.opt.shiftwidth:get()
    local sts = vim.opt.softtabstop:get()
    print(string.format("TS=%i, SW=%i, STS=%i", ts, sw, sts))
  end,
  { desc = "Print tab width" }
)
