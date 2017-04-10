local function app_js(app, cmd)
    local script = "var app = Application('" .. app .. "'); " .. cmd
    local ok, result = hs.osascript.javascript(script)

    return result, ok
end

local players = {
    itunes = {
        name = 'iTunes',
        bundle_id = 'com.apple.iTunes',
        fn = function(cmd) return  app_js('iTunes', cmd) end

        shuffle = function() return app_js('iTunes', 'app.shuffleEnabled = !app.shuffleEnabled()') end
        is_shuffled = function() return app_js('iTunes', 'app.shuffleEnabled()') end
    },

    spotify = {
        name = 'Spotify',
        bundle_id = 'com.spotify.client',
        fn = function(cmd) app_js('Spotify', cmd) end,

        shuffle = function() return app_js('Spotify', 'app.shuffling = !app.shuffling()') end,
        is_shuffled = function() return app_js('Spotify', 'spotify', 'app.shuffling()') end
    }
}

local function current_player()
    if hs.itunes.isPlaying() then
        return players.itunes
    end

    return players.spotify
end

local out = {
    current_player_bundleID = function() return current_players().bundle_id end,
    current_player_name = function() return current_players().name end,
    fn = function(key, ...)
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
}

local metatable = {
    __index = function(self, key, ...)
        current_player().fn(key, ...)
    end
}

setmetatable(out, metatable);

return out
