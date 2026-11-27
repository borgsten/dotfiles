local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

-- A bare URL stops at whitespace, angle brackets, quotes and backticks, so
-- `<loc>https://x/a</loc>` and `href="https://x/a"` don't swallow the markup,
-- and it can't end on sentence punctuation like . , : ;
local url = [=[\b\w+://[^\s<>"'`]+[\w/#=~+)-]]=]

function M.apply_to_config(config)
    config.hyperlink_rules = {
        -- URL wrapped in (), [], {} or <>: link only the inside
        { regex = [=[\((\w+://[^\s()]+)\)]=], format = '$1', highlight = 1 },
        { regex = [=[\[(\w+://[^\s\[\]]+)\]]=], format = '$1', highlight = 1 },
        { regex = [=[\{(\w+://[^\s{}]+)\}]=], format = '$1', highlight = 1 },
        { regex = [=[<(\w+://[^\s<>]+)>]=], format = '$1', highlight = 1 },
        { regex = url, format = '$0' },
        { regex = [=[\b\w+@[\w-]+(\.[\w-]+)+\b]=], format = 'mailto:$0' },
    }

    -- Double-click stops at tags and quotes, so it selects just the URL
    config.selection_word_boundary = ' \t\n{}[]()"\'`<>,;│'

    config.mouse_bindings = config.mouse_bindings or {}
    local function bind(event, mods, action)
        table.insert(config.mouse_bindings, { event = event, mods = mods, action = action })
    end
    local up = { Up = { streak = 1, button = 'Left' } }
    local down = { Down = { streak = 1, button = 'Left' } }

    -- Click/drag only selects and copies; it never opens a link, so the first
    -- click of a double-click on a URL doesn't open it. SHIFT is the mouse
    -- reporting bypass (selecting inside nvim/tmux), so it behaves the same.
    bind(up, 'NONE', act.CompleteSelection('ClipboardAndPrimarySelection'))
    bind(up, 'SHIFT', act.CompleteSelection('ClipboardAndPrimarySelection'))
    bind(up, 'SHIFT|ALT', act.CompleteSelection('PrimarySelection'))

    -- Ctrl+click opens the link, Ctrl+Shift+click inside nvim/tmux. The Down
    -- is swallowed so the program doesn't see a stray Ctrl+click.
    for _, mods in ipairs({ 'CTRL', 'CTRL|SHIFT' }) do
        bind(up, mods, act.OpenLinkAtMouseCursor)
        bind(down, mods, act.Nop)
    end

    -- CTRL-SHIFT-G: label the URLs on screen and open the one picked
    config.keys = config.keys or {}
    table.insert(config.keys, {
        key = 'G',
        mods = 'CTRL|SHIFT',
        action = act.QuickSelectArgs({
            label = 'open url',
            patterns = { url },
            action = wezterm.action_callback(function(window, pane)
                local selected = window:get_selection_text_for_pane(pane)
                window:perform_action(act.ClearSelection, pane)
                wezterm.open_with(selected)
            end),
        }),
    })
end

return M
