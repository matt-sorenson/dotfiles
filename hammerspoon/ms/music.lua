local sys = require('ms.sys')

local function app_js(app, cmd)
    local script = "var app = Application('" .. app .. "'); " .. cmd
    local ok, result = hs.osascript.javascript(script)

    return result, ok
end

local function app_fn(app, fn_name)
    return app_js(app, 'app.' .. fn_name .. "();")
end

local players = {
    itunes = {
        name = 'iTunes',
        bundle_id = 'com.apple.iTunes',
        fn = function(cmd) return  app_fn('iTunes', cmd) end,

        shuffle = function() return app_js('iTunes', 'app.shuffleEnabled = !app.shuffleEnabled()') end,
        is_shuffled = function() return app_js('iTunes', 'app.shuffleEnabled()') end
    },

    spotify = {
        name = 'Spotify',
        bundle_id = 'com.spotify.client',
        fn = function(cmd) app_fn('Spotify', cmd) end,

        shuffle = function() return app_js('Spotify', 'app.shuffling = !app.shuffling()') end,
        is_shuffled = function() return app_js('Spotify', 'spotify', 'app.shuffling()') end
    }
}

-- If iTunes is currently playing the 'current_player' is iTunes, otherwise
-- default to Spotify.
local function current_player()
    if hs.itunes.isPlaying() then
        return players.itunes
    end

    return players.spotify
end

--[[ export ]] local function select_current_player()
    sys.select_app(current_player().bundle_id)
end

--[[ export ]] local function fn(key, ...)
    local args = {...}
    return function()
        local player = current_player()
        if player[key] then
            player[key](table.unpack(args))
        else
            player.fn(key)
        end
    end
end

local out = {
    fn = fn,
    select_current_player = select_current_player
}

local metatable = {
    __index = function(self, key, ...)
        current_player().fn(key, ...)
    end
}

setmetatable(out, metatable);

return out
