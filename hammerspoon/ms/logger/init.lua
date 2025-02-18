local sys_print = print

local LOG_LEVEL_ENUM = {
    VERBOSE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    NONE = 5,
}

local function log_level_to_num(level)
    if type(level) == 'number' then
        return level
    end
    return LOG_LEVEL_ENUM[level]
end

local _system_log_level = log_level_to_num('INFO')

local function get_log_level()
    return _system_log_level
end

local function get_log_level_name(level)
    for k, v in pairs(LOG_LEVEL_ENUM) do
        if v == level then
            return k
        end
    end

    error("invalid log level provided: " .. level)
end

--[[ export ]]
local function set_log_level(level)
    _system_log_level = log_level_to_num(level)
end

local table_shallow_copy = function(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local INDENT = '  '

local function table_to_string(t, indent, looked_up)
    if not looked_up then
        looked_up = {}
    end

    if not indent then
        indent = ''
    end

    local out = '{\n'

    for k, v in pairs(t) do
        if type(v) == 'table' then
            if looked_up[v] then
                out = out .. indent .. k .. ': <circular>,\n'
            else
                local tmp_looked_up = table_shallow_copy(looked_up)
                tmp_looked_up[v] = true

                out = out .. indent .. k .. ': ' .. table_to_string(v, indent .. INDENT, tmp_looked_up) .. ',\n'
            end
        else
            if type(v) == 'string' then
                v = '"' .. v:gsub('"', '\\"') .. '"'
            end

            out = string.format('%s%s%s:%s,\n', out, indent, k, v)
        end
    end

    indent = indent:sub(1, -3)

    return out .. indent .. '}'
end

local function format_header(system, level, min_sys_length)
    local out = '[' .. level .. ':' .. system .. '] '

    if #system < min_sys_length then
        out = out .. string.rep(' ', min_sys_length - #system)
    end

    return out
end

local function system_logger(system, level, message, obj)
    if log_level_to_num(level) < _system_log_level then
        return
    end

    if nil == message then
        message = '<nil>'
    end

    local header = format_header(system, level, 9)
    if (obj) then
        local obj_str

        if type(obj) == 'table' then
            obj_str = table_to_string(obj)
        else
            obj_str = tostring(obj)
        end

        sys_print(header .. message .. '\n' .. obj_str)
    else
        sys_print(header .. message)
    end
end

local logger_mt_index = {
    __index = {
        verbose = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.VERBOSE then
                system_logger(self.system, 'VERBOSE', message, obj)
            end
        end,
        verbosef = function(self, message, ...)
            self:verbose(string.format(message, ...))
        end,

        debug = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.DEBUG then
                system_logger(self.system, 'DEBUG', message, obj)
            end
        end,
        debugf = function(self, message, ...)
            self:debug(string.format(message, ...))
        end,

        info = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.INFO then
                system_logger(self.system, 'INFO', message, obj)
            end
        end,
        infof = function(self, message, ...)
            self:info(string.format(message, ...))
        end,

        warn = function(self, message, obj)
            local old_color = hs.console.consolePrintColor()

            hs.console.consolePrintColor({ red = 1, green = .5, blue = 0, alpha = 1 })
            system_logger(self.system, 'WARN', message, obj)
            hs.console.consolePrintColor(old_color)
        end,
        warnf = function(self, message, ...)
            self:warn(string.format(message, ...))
        end,

        error = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.ERROR then
                local old_color = hs.console.consolePrintColor()

                hs.console.consolePrintColor({ red = 1, green = 0, blue = 0, alpha = 1 })
                system_logger(self.system, 'ERROR', message, obj)
                hs.console.consolePrintColor(old_color)
            end
        end,
        errorf = function(self, message, ...)
            self:error(string.format(message, ...))
        end,

        set_log_level = function(self, level)
            self.log_level = log_level_to_num(level)
        end,
        get_log_level = function(self)
            return get_log_level_name(self.log_level)
        end,
    },

    __call = function(self, message, obj)
        self:info(message, obj)
    end,
}

--[[
    Suggested usage:
    ```lua
        local print = require('ms.logger').logger_fn('init')

        print('test')
        print:error('error test')
    ```

    this will output the following to the console:
    ```
        2025-01-15 11:04:00: [INFO:init] test
        2025-01-15 11:04:00: [ERROR:init] error test
    ```
]]
--[[ export ]]
local function logger_fn(system)
    local out = {
        system = system,
        log_level = _system_log_level,
    }
    setmetatable(out, logger_mt_index)
    return out
end

-- Kludge some of the default hammerspoon logging into this system
print = function(...)
    local args = table.pack(...)
    if string.find(args[1], '-- ') == 1 then
        system_logger('hs', 'INFO', args[1]:sub(4))
    elseif string.find(args[1], '     hotkey:') then
        system_logger('hs.hotkey', 'INFO', args[1]:sub(22))
    elseif string.find(args[1], 'ERROR:   LuaSkin:') then
        system_logger('hs.LuaSkin', 'ERROR', args[1]:sub(28))
    else
        system_logger('unknown', 'INFO', table.concat(args, ' '))
    end
end

return {
    set_log_level = set_log_level,
    get_log_level = get_log_level,

    logger_fn = logger_fn,
}
