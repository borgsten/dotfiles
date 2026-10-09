# Machine local config

Everything in this directory except this file is gitignored. Put files here
directly, or stow them in from another repo.

| File                    | Used for                                                  |
| ----------------------- | --------------------------------------------------------- |
| `init.lua`              | Options, keymaps and autocmds, loaded after the plugins   |
| `plugins/*.lua`         | Extra lazy.nvim plugin specs                              |
| `lsp_settings.lua`      | LSP servers, merged into the servers in `plugins/lsp.lua` |
| `formatters.lua`        | conform.nvim formatter overrides                          |

A missing file is skipped, one that fails to load shows an error.

Example `lsp_settings.lua`:

```lua
return {
    lsp_servers = {
        robotframework_ls = {
            settings = {
                robot = {
                    python = { executable = '/usr/local/bin/python3.8' },
                },
            },
        },
    },
}
```

`formatters.lua` follows the same shape, returning `{ formatters = { ... } }`.
