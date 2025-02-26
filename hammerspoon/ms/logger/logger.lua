local hs_print = print

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
    return LOG_LEVEL_ENUM[string.upper(level)]
end

local _system_log_level = log_level_to_num('INFO')

--[[ export]]
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
                local tmp_looked_up = table.shallow_copy(looked_up)
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

local function print_to_console(msg)
    hs_print(msg)
end

local function system_logger(system, level, message, obj)
    if 'table' == type(message) and obj == nil then
        obj = message
        message = '<Debug OBJ Dump>:'
    end

    if nil == message then
        message = '<nil>'
    elseif type(message) ~= 'string' then
        message = tostring(message)
    end

    local header = format_header(system, level, 9)
    if (obj) then
        local obj_str

        if type(obj) == 'table' then
            obj_str = table_to_string(obj)
        else
            obj_str = tostring(obj)
        end

        print_to_console(header .. message .. '\n' .. obj_str)
    else
        print_to_console(header .. message)
    end
end

local _logger_mt_index = {
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
        local print = require('ms.logger').new('init')

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
local function _logger_new(system, log_level)
    if log_level then
        log_level = log_level_to_num(log_level)
    end

    log_level = log_level or _system_log_level

    local out = {
        system = system,
        log_level = log_level,
    }
    setmetatable(out, _logger_mt_index)
    return out
end

return {
    new = _logger_new,

    set_log_level = set_log_level,
    get_log_level = get_log_level,

    hs_print = hs_print,

    system_logger = system_logger,
}
