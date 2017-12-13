local sys = require 'ms.sys'

hs.grid.setMargins(hs.geometry.size(0, 0))

local ERGODOX_GRID = {
    { 'F1', 'F3', 'F4', 'F5', 'F6',   'F7' },
    {  '1',  '2',  '3',  '4',  '5',    '6' },
    {  'Q',  'W',  'E',  'R',  'T',    '=' },
    {  'A',  'S',  'D',  'F',  'G',   'F2' },
    {  'Z',  'X',  'C',  'V',  'B',  'END' }
}

local STANDARD_GRID = {
    { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
    {  '1',  '2',  '3',  '4',  '5',  '6' },
    {  'Q',  'W',  'E',  'R',  'T',  'Y' },
    {  'A',  'S',  'D',  'F',  'G',  'H' },
    {  'Z',  'X',  'C',  'V',  'B',  'N' }
}

local function select_layout()
    if sys.find_usb_device_by_name('ErgoDox') then
        if ERGODOX_GRID ~= hs.grid.HINTS then
            print('ergodox grid')
            hs.grid.HINTS = ERGODOX_GRID
        end
    elseif STANDARD_GRID ~= hs.grid.HINTS then
        print('boring grid')
        hs.grid.HINTS = STANDARD_GRID
    end
end

local function pre_show()
    select_layout()

    hs.grid.setGrid('5x3', '3840x2160') -- 4k Horizontal
    hs.grid.setGrid('3x5', '2160x3840') -- 4k Vertical
    hs.grid.setGrid('3x4', '1920x1080') -- 1080 Vertical

    hs.grid.setGrid('4x3', '2560×1440') -- 1440p Horizontal
    hs.grid.setGrid('3x4', '1440x2560') -- 1440p Vertical
end

local function default_show_grid_fn()
    pre_show()

    hs.grid.setGrid('6x3', 'DELL U3415W')
    hs.grid.setGrid('6x3', '3440x1440') -- 34" Ultra-Wide

    hs.grid.setGrid('3x4', '1440x2560') -- 1440p Vertical

    hs.grid.show()
end

local function shift_show_grid_fn()
    pre_show()

    hs.grid.setGrid('5x3', 'DELL U3415W')
    hs.grid.setGrid('5x3', '3440x1440') -- 34" Ultra-Wide

    hs.grid.setGrid('4x4', '1440x2560') -- 1440p Vertical

    hs.grid.show()
end

return {
    default_show_grid_fn = default_show_grid_fn,
    shift_show_grid_fn = shift_show_grid_fn
}
