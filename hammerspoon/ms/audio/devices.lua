local print = require('ms.logger').new('ms.audio.devices')

local _config = {}

local output_device
local input_device

local output_watcher_callbacks = {}
local input_watcher_callbacks = {}

local function get_config(device)
    local _, config = table.find(_config, function(v)
        return device:name() == v.device_name
    end)

    if config then
        return config
    else
        return _config.default
    end
end

--[[ export ]]
local function get_output_config()
    return get_config(output_device)
end

--[[ export ]]
local function get_input_config()
    return get_config(input_device)
end

--[[ export ]]
local function get_config_by_name(name)
    return _config[name]
end

--[[ export ]]
local function get_input_device_by_name(name)
    if _config[name] then
        return hs.audiodevice.findInputByName(_config[name].device_name)
    else
        if device then
            return device
        else
            return hs.audiodevice.defaultInputDevice()
        end
    end
end

--[[ export ]]
local function get_output_device_by_name(name)
    if _config[name] then
        return hs.audiodevice.findOutputByName(_config[name].device_name)
    else
        local device = hs.audiodevice.findOutputByName(name)
        if device then
            return device
        else
            return hs.audiodevice.defaultOutputDevice()
        end
    end
end

--[[ export ]]
local function get_input_device_by_uid(uid)
    return hs.audiodevice.findInputByUID(uid)
end

--[[ export ]]
local function get_output_device_by_uid(uid)
    return hs.audiodevice.findOutputByUID(uid)
end

--[[ export ]]
local function get_input_device()
    return input_device
end

--[[ export ]]
local function get_output_device()
    return output_device
end

--[[ export ]]
local function add_input_watcher_callback(callback)
    table.insert(input_watcher_callbacks, callback)
end

--[[ export ]]
local function remove_input_watcher_callback(callback)
    table.iremove_by_value(input_watcher_callbacks, callback)
end

--[[ export ]]
local function add_output_watcher_callback(callback)
    table.insert(output_watcher_callbacks, callback)
end

--[[ export ]]
local function remove_output_watcher_callback(callback)
    table.iremove_by_value(output_watcher_callbacks, callback)
end

local function shutdown()
    if input_device then
        input_device:watcherStop()
    end

    if output_device then
        output_device:watcherStop()
    end

    output_device = nil
    input_device = nil
end

--[[ export ]]
local function init(device_config, set_default_output)
    shutdown()

    if device_config then
        _config = device_config
    end

    local default = _config.default or {}
    _config.default = nil
    default.min_delta = default.min_delta or 5

    table.each(_config, function(config)
        config.min_delta = config.min_delta or default.min_delta
    end)

    _config.default = default

    if set_default_output or set_default_output == nil then
        if device_config then
            local default_config_key = table.find(device_config, function(config)
                return config.is_default
            end)

            if default_config_key then
                local default_config = device_config[default_config_key]
                get_output_device_by_name(default_config.device_name):setDefaultOutputDevice()
            else
                print:warn('no default config found')
            end
        end
    end

    output_device = hs.audiodevice.defaultOutputDevice()
    input_device = hs.audiodevice.defaultInputDevice()

    output_device:watcherCallback(function(uid, event, scope, element)
        table.each(output_watcher_callbacks, function(callback)
            local device = get_output_device_by_uid(uid)

            callback(device, event, scope, element)
        end)
    end)

    input_device:watcherCallback(function(uid, event, scope, element)
        table.each(input_watcher_callbacks, function(callback)
            local device = get_input_device_by_uid(uid)

            callback(device, event, scope, element)
        end)
    end)
end

hs.audiodevice.watcher.setCallback(function(arg)
    local device_change_events = { 'dIn', 'dOut', 'sOut' }

    if table.find(device_change_events, arg) then
        init()
    end
end)

return {
    init = init,
    get_config_by_name = get_config_by_name,

    get_input_device = get_input_device,
    get_input_device_by_name = get_input_device_by_name,
    get_input_device_by_uid = get_input_device_by_uid,
    get_input_config = get_input_config,
    add_input_watcher_callback = add_input_watcher_callback,
    remove_input_watcher_callback = remove_input_watcher_callback,

    get_output_device = get_output_device,
    get_output_device_by_name = get_output_device_by_name,
    get_output_device_by_uid = get_output_device_by_uid,
    add_output_watcher_callback = add_output_watcher_callback,
    get_output_config = get_output_config,
    remove_output_watcher_callback = remove_output_watcher_callback,
}
