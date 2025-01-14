local sys = require 'ms.sys'

local print = require('ms.logger').logger_fn('home-assistant')

local ha_config = sys.do_file_hs_local('config-home-assistant.lua')

--[[
  For a given event type if a trigger_id is set then it will be used as the
  webhook_id for the event. If not then the default webhook_id will be used.
]] 
if not ha_config.trigger_ids then
  ha_config.trigger_ids = {}
end

if not ha_config.log_ignore then
  ha_config.log_ignore = {}
end

local function get_trigger_url(event, options)
  local host = ha_config.host
  local webhook_id = ha_config.webhook_id

  if options.host then
    host = options.host
  end

  if options.webhook_id then
    webhook_id = options.webhook_id
  end

  return host .. '/api/events/' .. webhook_id
end

--[[
- Expects the home assistant webhook to take a json object with the following keys:
  - `event` - the event to trigger
  - `data` - the data to send with the event

  - `options`
  - `host` - the host to post to, default from 'config-home-assistant.lua'
  - `webhook_id` - the webhook id to use, default from 'config-home-assistant.lua'
  - `headers` - a table of headers to include in the request (always sends `Content-Type: application/json`)
  - `callback` - a function to call when the request completes, default to logger

- Mostly configured to use a single webhook for all events, but can be
  overridden with options.

- In home assistant I trigger a script based of the event name and pass the data
  as a variable as needed.
]]
--[[ export ]] local function post(event, data, options)
  if options == nil then
    options = {}
  end

  local url = get_trigger_url(event, options)

  local body = hs.json.encode({
    event = event,
    data = data,
  })

  local headers = {
    ["Content-Type"] = "application/json",
  }

  if options.headers then
    for k, v in pairs(options.headers) do
      headers[k] = v
    end
  end

  local callback = options.callback

  if not callback then
    callback = function(status, body, headers)
      local message =
        "HA event: " .. tostring(event) ..
        "\nstatus: " .. tostring(status)

      print(message)
    end
  end

  print("HA POST", { url = url, body = body, headers = headers })

  hs.http.asyncPost(url, body, headers, callback)
end

return {
  post = post,
}
