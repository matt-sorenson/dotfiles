local print = require('ms.logger').new('ms.home-assistant')

local fs = require 'ms.fs'

local function get_ha_config()
    local success, result = pcall(function()
        return fs.do_file_local('config-home-assistant.lua')
    end)

    if not success then
        print:error("Failed to load config-home-assistant", result)

        result = {}
    elseif 'table' ~= type(result) then
        print:error("config-home-assistant.lua did not return a table")

        result = {}
    end

    --[[
        For a given event type if a trigger_id is set then it will be used as the
        webhook_id for the event. If not then the default webhook_id will be used.
    ]]
    if not result.event_webhook_id then
        result.event_webhook_id = {}
    end

    return result
end

local ha_config = get_ha_config()

local function verify_config()
    local success = true

    if not ha_config.host then
        print:error("Home Assistant host not set")
        success = false
    end

    if not ha_config.webhook_id and 0 == #ha_config.event_webhook_id then
        print:error("Home Assistant webhook_id not set")
        success = false
    end

    return success
end

local function get_trigger_url(event, options)
    local host = options.host or ha_config.host
    local webhook_id = ha_config.webhook_id

    if ha_config.event_webhook_id[event] then
        webhook_id = ha_config.event_webhook_id[event]
    elseif options.webhook_id then
        webhook_id = options.webhook_id
    end

    return host .. '/api/webhook/' .. webhook_id
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
--[[ export ]]
local function post(event, data, options)
    if not verify_config() then
        return
    end

    if options == nil then
        options = {}
    end

    local url = get_trigger_url(event, options)

    local post_body = hs.json.encode({
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
        callback = function(status, response_body, response_headers)
            print:debug("Home Assistant Response", {
                event = event,
                status = status,
                body = response_body,
                headers = response_headers,
            })
        end
    end

    print:debug("HA POST", { url = url, body = post_body, headers = headers })

    hs.http.asyncPost(url, post_body, headers, callback)
end

return {
    post = post,
}
