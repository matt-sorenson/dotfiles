local sys = require 'ms.sys'

hs.grid.setMargins(hs.geometry.size(0, 0))

local STANDARD_GRID = {
    {  'Z',  'X',  'C',  'V',  'B',  'N' },
    { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
    {  '1',  '2',  '3',  '4',  '5',  '6' },
    {  'Q',  'W',  'E',  'R',  'T',  'Y' },
    {  'A',  'S',  'D',  'F',  'G',  'H' },
}

local ERGODOX_GRID = {
    {  'Z',  'X',  'C',  'V',  'B',  'N' },
    { 'F1', 'F3', 'F4', 'F5', 'F6', 'F7' },
    {  '1',  '2',  '3',  '4',  '5',  '=' },
    {  'Q',  'W',  'E',  'R',  'T',  'HOME' },
    {  'A',  'S',  'D',  'F',  'G',  'H' },
} --[[ {
    { 'F1', 'F3', 'F4', 'F5', 'F6',   'F7' },
    {  '1',  '2',  '3',  '4',  '5',    '6' },
    {  'Q',  'W',  'E',  'R',  'T',    '=' },
    {  'A',  'S',  'D',  'F',  'G',   'F2' },
    {  'Z',  'X',  'C',  'V',  'B',  'END' }
}
]]--

local function select_layout()
    if sys.find_usb_device_by_name('ErgoDox') or sys.find_usb_device_by_name('Moonlander Mark I') then
        if ERGODOX_GRID ~= hs.grid.HINTS then
            if debug_output.grid then
                print('ergodox grid')
            end
            hs.grid.HINTS = ERGODOX_GRID
        end
    elseif STANDARD_GRID ~= hs.grid.HINTS then
        if debug_output.grid then
            print('boring grid')
        end
        hs.grid.HINTS = STANDARD_GRID
    end
end

--[[export]] local function show(mod)
    select_layout()

    hs.grid.setGrid('3x5', '2160x3840') -- 4k Vertical
    hs.grid.setGrid('3x4', '1920x1080') -- 1080 Vertical

    hs.grid.setGrid('4x3', '2560×1440') -- 1440p Horizontal

    if (mod == 'shift') then
        hs.grid.setGrid('5x4', '3840x2160')   -- 4k Horizontal
        hs.grid.setGrid('5x2', 'DELL U3415W') -- 34" Ultra-Wide
        hs.grid.setGrid('5x2', '3440x1440')   -- 34" Ultra-Wide
        hs.grid.setGrid('5x2', '5120x1440')   -- 49" Ultra-Wide
        hs.grid.setGrid('5x2', 'LS49AG95')    -- 49" Ultra-Wide

        hs.grid.setGrid('4x4', '1440x2560') -- 1440p Vertical
    else
        hs.grid.setGrid('5x2', '3840x2160')   -- 4k Horizontal
        hs.grid.setGrid('6x2', 'DELL U3415W') -- 34" Ultra-Wide
        hs.grid.setGrid('6x2', '3440x1440')   -- 34" Ultra-Wide
        hs.grid.setGrid('6x2', '5120x1440')   -- 49" Ultra-Wide
        hs.grid.setGrid('6x2', 'LS49AG95')    -- 49" Ultra-Wide

        hs.grid.setGrid('3x4', '1440x2560') -- 1440p Vertical
    end

    hs.grid.show()
end

return {
    show = show,
    show_fn = function(mod) return function() show(mod) end end
}
