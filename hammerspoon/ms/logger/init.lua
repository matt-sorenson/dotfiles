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

local function get_log_level()
    return system_log_level
end

local function get_log_level_name(level)
    for k, v in pairs(LOG_LEVEL_ENUM) do
        if v == level then
            return k
        end
    end

    error("invalid log level provided: " .. level)
end

local system_log_level = log_level_to_num('INFO')
--[[ export ]] local function set_log_level(level)
    system_log_level = log_level_to_num(level)
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

    out = '{\n'

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
                v = v:gsub('"', '\\"')
                v = '"' .. v .. '"'
            end

            out = out .. indent .. k .. ': ' .. v .. ',\n'
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
    if log_level_to_num(level) < system_log_level then
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
        debug = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.DEBUG then
                system_logger(self.system, 'DEBUG', message, obj)
            end
        end,
        info = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.INFO then
                system_logger(self.system, 'INFO', message, obj)
            end
        end,
        warn = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.WARN then
                system_logger(self.system, 'WARN', message, obj)
            end
        end,
        error = function(self, message, obj)
            if self.log_level <= LOG_LEVEL_ENUM.ERROR then
                system_logger(self.system, 'ERROR', message, obj)
            end
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
--[[ export ]] local function logger_fn(system)
    local out = {
        system = system,
        log_level = system_log_level,
    }
    setmetatable(out, logger_mt_index)
    return out
end

-- Kludge some of the default hammerspoon logging into this system 
print = function(...)
    local args = table.pack(...)
    if string.find(args[1], '-- ') == 1 then
        args[1] = args[1]:sub(4)
        system_logger('hs', 'INFO', args[1])
    elseif string.find(args[1], '     hotkey:') then
        args[1] = args[1]:sub(22)
        system_logger('hs:hotkey', 'INFO', args[1])
    else
        sys_print(...)
    end
end

return {
  set_log_level = set_log_level,

  logger_fn = logger_fn,
}
