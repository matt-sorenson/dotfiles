local sys = require 'ms.sys'

hs.grid.setMargins(hs.geometry.size(0, 0))

local STANDARD_GRID = {
    {  'Z',  'X',  'C',  'V',  'B',  'N' },
    { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
    {  '1',  '2',  '3',  '4',  '5',  '6' },
    {  'Q',  'W',  'E',  'R',  'T',  'Y' },
    {  'A',  'S',  'D',  'F',  'G',  'H' },
}

-- While this looks really odd, for 49" ultrawide want 6x2 grid
local MOONLANDER_GRID = {
    {  'Z',  'X',  'C',  'V',  'B',  'N' },
    { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
    {  '1',  '2',  '3',  '4',  '5',  '=' },
    {  'Q',  'W',  'E',  'R',  'T',  'HOME' },
    {  'A',  'S',  'D',  'F',  'G',  'H' },
}

local function select_layout()
    if sys.find_usb_device_by_name('ErgoDox') or sys.find_usb_device_by_name('Moonlander Mark I') then
        if MOONLANDER_GRID ~= hs.grid.HINTS then
            if debug_output.grid then
                print('ergodox grid')
            end
            hs.grid.HINTS = MOONLANDER_GRID
        end
    elseif STANDARD_GRID ~= hs.grid.HINTS then
        if debug_output.grid then
            print('standard grid')
        end
        hs.grid.HINTS = STANDARD_GRID
    end
end

local GRID_LAYOUTS = {
    standard = {
        ['3840x2160']   = '5x2',
        ['DELL U3415W'] = '6x2',
        ['3440x1440']   = '6x2',
        ['5120x1440']   = '6x2',
        ['LS49AG95']    = '6x2',
        ['1440x2560']   = '3x4'
    },
    shift = {
        ['3840x2160']   = '5x4',
        ['DELL U3415W'] = '5x2',
        ['3440x1440']   = '5x2',
        ['5120x1440']   = '5x2',
        ['LS49AG95']    = '5x2',
        ['1440x2560']   = '4x4'
    }
}

local function set_grid(layout)
    for screen, dim in pairs(GRID_LAYOUTS[layout]) do
        hs.grid.setGrid(dim, screen)
    end
end

--[[export]] local function show(mod)
    select_layout()

    hs.grid.setGrid('3x5', '2160x3840') -- 4k Vertical
    hs.grid.setGrid('3x4', '1920x1080') -- 1080 Vertical

    hs.grid.setGrid('4x3', '2560×1440') -- 1440p Horizontal

    set_grid(mod or 'standard')

    hs.grid.show()
end

return {
    show = show,
    show_fn = function(mod) return function() show(mod) end end
}
