local print = require('ms.logger').logger_fn('ms.audio.devices')

local config = {}

local output_device
local input_device

local output_watcher_callbacks = {}
local input_watcher_callbacks = {}

local function get_config(device)
  table.each(config, function(config)
    if output_device:name(config.device_name) then
      return config
    end
  end)

  return config.default
end

--[[export]] local function get_output_config()
  return get_config(output_device)
end

--[[export]] local function get_input_config()
  return get_config(input_device)
end

--[[export]] local function get_input_device_by_name(name)
  local config = table.find(config, function(config)
    return config.name == name
  end)

  if config then
    name = config.device_name
  end

  return hs.audiodevice.findInputByName(name)
end

--[[export]] local function get_output_device_by_name(name)
  local config = table.find(config, function(config)
    return config.name == name
  end)

  if config then
    name = config.device_name
  end

  return hs.audiodevice.findOutputByName(name)
end

--[[export]] local function get_input_device_by_uid(uid)
  return hs.audiodevice.findInputByUID(uid)
end

--[[export]] local function get_output_device_by_uid(uid)
  return hs.audiodevice.findOutputByUID(uid)
end

--[[export]] local function get_input_device()
  return input_device
end

--[[export]] local function get_output_device()
  return output_device
end

--[[export]] local function add_input_watcher_callback(callback)
  table.insert(input_watcher_callbacks, callback)
end

--[[export]] local function remove_input_watcher_callback(callback)
  table.remove(input_watcher_callbacks, callback)
end

--[[export]] local function add_output_watcher_callback(callback)
table.insert(output_watcher_callbacks, callback)
end

--[[export]] local function remove_output_watcher_callback(callback)
  table.remove(output_watcher_callbacks, callback)
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

--[[export]] local function init(device_config)
  shutdown()

  _config = device_config or _config

  local default = _config.default or {}
  _config.default = nil
  default.min_volume_delta = default.min_volume_delta or 5

  table.each(_config, function(config)
    config.min_volume_delta = config.min_volume_delta or default.min_volume_delta
  end)

  _config.default = default

  if device_config then
    local default_config_key = table.find(device_config, function(config)
      return config.is_default
    end)

    if default_config_key then
      local default_config = device_config[default_config_key]
      get_output_device_by_name(default_config.device_name):setDefaultOutputDevice()
    else
      print('no default config found')
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
    init(device_config)
  end
end)

return {
  init = init,

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