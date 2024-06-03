-- Set highlight on search
vim.o.hlsearch = true
vim.keymap.set({ 'n' }, '<Esc>', ":noh<CR>", { silent = true })

-- Make line numbers default
vim.wo.number = true

-- Relative line numbering
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Split and move focus to the right/below
vim.o.splitright = true
vim.o.splitbelow = true

-- Number of lines to keep above/below cursor
vim.o.scrolloff = 10

-- Ruler
vim.o.ruler = true
vim.opt.colorcolumn = '80,120'

-- Default tabwidth
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
