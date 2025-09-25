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
        print:warn("No pr-teams.lua config file to load.")
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
        hs.alert(config[team_name].members[hs.math.random(1, #(config[team_name].members))])
    else
        print:error("Team '" .. team_name .. "' not found in config")
    end
end

-- Use 'is-work' file to determine this to massively simplify it
local IS_WORK_COMPUTER = fs.file_exists_local("is-work")

return {
    init = init,
    get_pr_hotkey_map = get_pr_hotkey_map,

    is_work_computer = function() return IS_WORK_COMPUTER end,

    get_random_team_member = get_random_team_member,
    get_random_team_member_fn = function(team_name)
        return function() get_random_team_member(team_name) end
    end
}
