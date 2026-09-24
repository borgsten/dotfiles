-- Based on kicstart.nvim
-- https://github.com/nvim-lua/kickstart.nvim

-- Enable new UI2
require('vim._core.ui2').enable({})

--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('options')
require('keymap')
require('util')
require('custom.run_file')
require('custom.trailspace').setup()
require('custom.snakify').setup()

require('lazy').setup({ import = 'plugins' }, {
  change_detection = {
    notify = false,
  },
  -- Fallback to habamax on first install
  install = {
    colorscheme = { 'kanagawa', 'habamax' },
  },
})

-- vim: ts=2 sts=2 sw=2 et
