local logger_systems_to_skip = {}
--[[ export ]] local function logger_skip_system(system)
    logger_systems_to_skip[system] = true
end

--[[ export ]] local function logger_unskip_system(system)
    logger_systems_to_skip[system] = nil
end

local log_level = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5,
}

local function log_level_to_num(level)
    return log_level[level]
end

local log_level = log_level_to_num('INFO')
--[[ export ]] local function set_log_level(level)
    log_level = log_level_to_num(level)
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

    if log_level_to_num(level) >= log_level then
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

        print('[' .. system .. '] ' .. message .. '\n' .. obj_str)
    else
        print('[' .. system .. '] ' .. message)
    end
end

--[[ export ]] local function logger_fn(system)
    return function(message, obj)
        system_logger(system, 'INFO', message, obj)
    end
end

return {
  logger_skip_system = logger_skip_system,
  logger_unskip_system = logger_unskip_system,
  set_log_level = set_log_level,

  logger_fn = logger_fn,
}
