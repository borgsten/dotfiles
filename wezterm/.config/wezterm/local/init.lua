local wezterm = require('wezterm')

local M = {}

function M.apply_to_config(config)
    local scripts = wezterm.glob(wezterm.config_dir .. '/local/*.lua')
    table.sort(scripts)

    for _, script in ipairs(scripts) do
        local name = script:match('/([^/]+)%.lua$')
        if name ~= 'init' then
            require('local.' .. name).apply_to_config(config)
        end
    end
end

return M
