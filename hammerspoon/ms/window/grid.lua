local sys = require 'ms.sys'

hs.grid.setMargins(hs.geometry.size(0, 0))

local GRID_KEYBOARD = {
    standard = {
        { 'Z',  'X',  'C',  'V',  'B',  'N' },
        { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
        { '1',  '2',  '3',  '4',  '5',  '6' },
        { 'Q',  'W',  'E',  'R',  'T',  'Y' },
        { 'A',  'S',  'D',  'F',  'G',  'H' },
    },

    -- While this looks really odd, for 49" ultrawide want 6x2 grid
    moonlander = {
        { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
        { '1',  '2',  '3',  '4',  '5',  '=' },
        { 'Q',  'W',  'E',  'R',  'T',  'HOME' },
        { 'A',  'S',  'D',  'F',  'G',  'H' },
        { 'Z',  'X',  'C',  'V',  'B',  'N' },
    }
}

local function select_layout()
    local grid = GRID_KEYBOARD.standard

    if sys.using_moonlander_ergodox() then
        grid = GRID_KEYBOARD.moonlander
    end

    hs.grid.HINTS = grid
end

local GRID_LAYOUTS = {
    -- If the layout specificed to set_grid does not have a key for the
    -- resolution it falls back to the one provided in 'default'
    default = {
        ['5120x1440'] = '6x2', -- 49" Ultrawide
        ['3840x1600'] = '5x2', -- 38" Ultrawide
        ['3440x1440'] = '5x2', -- 34" Ultrawide

        ['3840x2160'] = '4x2', -- 4K Horizontal
        ['2560x1440'] = '4x2', -- 1440p/27" Horizontal
    },

    standard = {
        ['3840x2160'] = '3x5', -- 4K Vertical
        ['1440x2560'] = '3x5', -- 1440p/27" Vertical
    },

    shift = {
        ['3840x2160'] = '2x4', -- 4K Vertical
        ['1440x2560'] = '2x4', -- 1440p/27" Vertical
    }
}

local current_grid_layout = nil

-- For other resolutions, use standard
for k, v in pairs(GRID_LAYOUTS.standard) do
    if GRID_LAYOUTS.shift[k] == nil then
        GRID_LAYOUTS.shift[k] = v
    end
end

local function set_grid(layout)
    if current_grid_layout == layout then
        return
    end

    for screen, dim in pairs(GRID_LAYOUTS[layout]) do
        hs.grid.setGrid(dim, screen)
    end

    for resolution, grid in pairs(GRID_LAYOUTS['default']) do
        if GRID_LAYOUTS[layout][resolution] == nil then
            hs.grid.setGrid(grid, resolution)
        end
    end

    current_grid_layout = layout
end

---
-- Setup the grid and show it
-- @param mod
--   Key into GRID_LAYOUTS to use. If nil, or the key isn't found in GRID_LAYOUTS
--   then 'standard' is used. Called mod as it's mainly used for keybinds.
--[[export]]
local function show(mod)
    select_layout()

    if mod == nil or GRID_LAYOUTS[mod] == nil then
        mod = 'standard'
    end

    set_grid(mod)

    hs.grid.show()
end

return {
    show = show,
    show_fn = function(mod) return function() show(mod) end end
}
