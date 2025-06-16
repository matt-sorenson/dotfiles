local hslog = require('hs.logger')
local mslog = require('ms.logger.logger')

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

local function log_level_to_hs_log_level(input)
    if 'VERBOSE' == input then
        return 'verbose'
    elseif 'DEBUG' == input then
        return 'debug'
    elseif 'INFO' == input then
        return 'info'
    elseif 'WARN' == input then
        return 'warning'
    elseif 'ERROR' == input then
        return 'error'
    elseif 'NONE' == input then
        return 'nothing'
    end

    return 'nothing'
end

--- We override the hammerspoon logger to use the ms logger here
-- This means we get the same logging format as all of my custom stuff
hslog.new = function(system, level)
    if not string.find(system, 'hs.') then
        system = 'hs.' .. system
    end

    system = string.gsub(system, '^hs:', 'hs.')

    local wrapper = mslog.new(system)
    wrapper:set_log_level(hs_log_level_to_log_level(level))

    return {
        v = function(msg) wrapper:verbose(msg) end,
        d = function(msg) wrapper:debug(msg) end,
        i = function(msg) wrapper:info(msg) end,
        w = function(msg) wrapper:warn(msg) end,
        e = function(msg) wrapper:error(msg) end,

        vf = function(...) wrapper:verbosef(...) end,
        df = function(...) wrapper:debugf(...) end,
        wf = function(...) wrapper:warnf(...) end,
        ef = function(...) wrapper:errorf(...) end,
        f = function(...) wrapper:infof(...) end,

        setLogLevel = function(log_level)
            wrapper:set_log_level(hs_log_level_to_log_level(log_level))
        end,
        getLogLevel = function()
            log_level_to_hs_log_level(wrapper:get_log_level())
        end,
    }
end
