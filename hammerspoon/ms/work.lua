local print = require('ms.logger').new('ms.work')
local fs    = require 'ms.fs'

local config = {}

local function inner_init()
    --[[ The config file is expected to be formatted as follows:
        ```
        {
            ['team_name'] = {
                hotkey = 'T',
                members = { 'member1', 'member2', ... }
            },
        }
        ```
    ]]
    config = fs.do_file_local("pr-teams.lua")
end

local function init()
    if not pcall(inner_init) then
        print:error("Failed to load pr-teams config")
        config = {}
    end
end

local function get_pr_hotkey_map()
    local out = {}

    for team, team_config in pairs(config) do
        out[team] = team_config.hotkey
    end

    return out;
end

--[[ export ]]
local function get_random_team_member(team_name)
    if config[team_name] then
        hs.alert(config[team_name].members[hs.math.random(1, #config[team_name])])
    else
        print:error("Team '" .. team_name .. "' not found in config")
    end
end

return {
    init = init,
    get_pr_hotkey_map = get_pr_hotkey_map,

    get_random_team_member = get_random_team_member,
    get_random_team_member_fn = function(team_name) return function() get_random_team_member(team_name) end end
}
