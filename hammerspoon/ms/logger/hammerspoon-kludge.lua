local hslog = require('hs.logger')
local mslog = require 'ms.logger'

local function hs_log_level_to_log_level(input)
    if 'nothing' == input or 0 == input then
        return 'NONE'
    elseif 'error' == input or 1 == input then
        return 'ERROR'
    elseif 'warning' == input or 2 == input then
        return 'WARN'
    elseif 'info' == input or 3 == input then
        return 'WARN'
    elseif 'debug' == input or 4 == input then
        return 'DEBUG'
    elseif 'verbose' == input or 5 == input then
        return 'VERBOSE'
    end

    return 'INFO'
end

hslog.new = function(system, level)
    if not string.find(system, 'hs.') and not 'hs' == system then
        system = 'hs.' .. system
    end

    local wrapper = mslog.logger_fn(system)

    print("created hs log system: " .. system)

    return {
        v = function(msg) wrapper:verbose(message) end,
        d = function(msg) wrapper:debug(message) end,
        i = function(msg) wrapper:info(message) end,
        w = function(msg) wrapper:warn(message) end,
        e = function(msg) wrapper:error(message) end,

        vf = function(...)
            local message = string.format(...)
            wrapper:verbose(message)
        end,
        df = function(...)
            local message = string.format(...)
            wrapper:debug(message)
        end,
        wf = function(...)
            local message = string.format(...)
            wrapper:warn(message)
        end,
        ef = function(...)
            local message = string.format(...)
            wrapper:error(message)
        end,

        f = function(...)
            local message = string.format(...)
            wrapper:info(message)
        end,

        setLogLevel = function(log_level)
            wrapper:set_log_level(hs_log_level_to_log_level(log_level))
        end,
        getLogLevel = function()
            return 5
        end,
    }
end
