-- Based on kicstart.nvim
-- https://github.com/nvim-lua/kickstart.nvim

--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ import = 'plugins', },
  {
    change_detection = {
      notify = false
    },
  })

require('options')
require('keymap')
require('util')
require('custom.run_file')
require('custom.trailspace').setup()

-- Read colorscheme form xresources to support dynamic switching
local colorscheme = 'kanagawa'
local color = require('custom.helpers').readFromXResources("themename")
if color ~= nil then
  colorscheme = color
end
vim.cmd.colorscheme(colorscheme)

-- vim: ts=2 sts=2 sw=2 et
