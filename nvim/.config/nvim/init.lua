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

require('options')
require('keymap')
require('util')
require('custom.run_file')
require('custom.trailspace').setup()
require('custom.snakify').setup()

require('lazy').setup({ import = 'plugins', },
  {
    change_detection = {
      notify = false
    },
  })

function DoFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("Could not run dofile on '" .. file_path .. "'")
    return false
  end

  local ok, res = pcall(dofile, file_path)
  if not ok then
    vim.notify("Could not run file:\n" .. res)
  end
  return ok
end

-- Load current theme, if it doesn't exist load default
local current_theme = vim.env.XDG_CONFIG_HOME .. '/theming/current/neovim.lua'
if not DoFileIfExists(current_theme) then
  vim.cmd.colorscheme('kanagawa')
end

-- vim: ts=2 sts=2 sw=2 et
