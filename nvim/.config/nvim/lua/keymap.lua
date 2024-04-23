-- [[ Basic Keymaps ]]

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move visual line down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move visual line up' })

vim.keymap.set('n', '<leader>bd', ':bp|bd #<cr>', { desc = '[B]uffer [D]elete' })

-- Perform action without replacing yank registry
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[D]elete and blackhole' })
vim.keymap.set({ 'n', 'v' }, '<leader>c', '"_c', { desc = 'Repla[C]e and blackhole' })
vim.keymap.set('v', '<leader>p', '"_dP', { desc = '[P]aste and blackhole' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Easier movement between splits
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left split' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right split' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus down split' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus up split' })

-- Easier resize of splits
vim.keymap.set('n', '<C-A-h>', '<C-W>10<', { desc = 'Shrink 10 columns' })
vim.keymap.set('n', '<C-A-l>', '<C-W>10>', { desc = 'Grow 10 columns' })
vim.keymap.set('n', '<C-A-j>', '<C-W>10-', { desc = 'Shrink 10 rows' })
vim.keymap.set('n', '<C-A-k>', '<C-W>10+', { desc = 'Grow 10 rows' })

-- Trim trailing whitespace
vim.keymap.set({ 'n', 'v' }, '<leader>tw', require('custom.trailspace').remove_trailing_whitespace,
  { desc = 'Trim trailing whitespace' })
