-- Local nvim configs should be symlinked to this directory.
-- They can be used with the require('helpers').tryRequire(foo) function
-- Below is an example for local lsp settings
local M = {}

M.lsp_servers = {
  robotframework_ls = {
    settings = {
      robot = {
        python = {
          executable = "/usr/local/bin/python3.8",
        },
      },
    },
  },
}

return M
