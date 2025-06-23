local logger = require('ms.logger.logger')

local system_logger = logger.system_logger

 -- luacheck: ignore print printf

-- Kludge some of the default hammerspoon logging into this system
print = function(...)
    local args = table.pack(...)
    if 'string' == type(args[1]) then
        if string.find(args[1], '-- ') == 1 then
            system_logger('hs', 'INFO', args[1]:sub(4))
            return
        elseif string.find(args[1], '     hotkey:') then
            system_logger('hs.hotkey', 'INFO', args[1]:sub(22))
            return
        elseif string.find(args[1], 'ERROR:   LuaSkin:') then
            system_logger('LuaSkin', 'ERROR', args[1]:sub(28))
            return
        end
    end

    local str_args =  table.map(args, function(e) return tostring(e) end)
    local message = table.concat(str_args, ' ')
    system_logger('unknown', 'INFO', message)
end

printf = function(...)
    local message = string.format(...)
    system_logger('unknown', 'INFO', message)
end

return {
    set_log_level = logger.set_log_level,
    get_log_level = logger.get_log_level,

    new = logger.new,

    hs_print = logger.hs_print
}
