local sys_print = print

local logger_systems_to_skip = {}
--[[ export ]] local function logger_skip_system(system)
    logger_systems_to_skip[system] = true
end

--[[ export ]] local function logger_unskip_system(system)
    logger_systems_to_skip[system] = nil
end

local LOG_LEVEL_ENUM = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5,
}

local function log_level_to_num(level)
    return LOG_LEVEL_ENUM[level]
end

local system_log_level = log_level_to_num('DEBUG')
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

local function system_logger(system, level, message, obj)
    if logger_systems_to_skip[system] then
        return
    end

    if log_level_to_num(level) < system_log_level then
        return
    end

    if nil == message then
        message = '<nil>'
    end

    if (obj) then
        local obj_str

        if type(obj) == 'table' then
            obj_str = table_to_string(obj)
        else
            obj_str = tostring(obj)
        end

        sys_print('[' .. level .. ':' .. system .. '] ' .. message .. '\n' .. obj_str)
    else
        sys_print('[' .. level .. ':' .. system .. '] ' .. message)
    end
end

local logger_mt_index = {
    __index = {
        debug = function(self, message, obj)
            system_logger(self.system, 'DEBUG', message, obj)
        end,
        info = function(self, message, obj)
            system_logger(self.system, 'INFO', message, obj)
        end,
        warn = function(self, message, obj)
            system_logger(self.system, 'WARN', message, obj)
        end,
        error = function(self, message, obj)
            system_logger(self.system, 'ERROR', message, obj)
        end,
        fatal = function(self, message, obj)
            system_logger(self.system, 'FATAL', message, obj)
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
    }
    setmetatable(out, logger_mt_index)
    return out
end

return {
  logger_skip_system = logger_skip_system,
  logger_unskip_system = logger_unskip_system,
  set_log_level = set_log_level,

  logger_fn = logger_fn,
}
