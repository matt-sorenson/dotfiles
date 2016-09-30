local players = {
    itunes = {
        name = 'iTunes',
        bundle_id = 'com.apple.iTunes',
        player = hs.itunes
    },

    spotify = {
        name = 'Spotify',
        bundle_id = 'com.spotify.client',
        player = hs.spotify
    }
}

local function current_player_table()
    if hs.itunes.isPlaying() then
        return players.itunes
    end

    return players.spotify
end

local function current_player()
    return current_player_table().player
end

local function current_player_bundleID()
    return current_player_table().bundle_id
end

local function current_player_name()
    return current_player_table().name
end

local metatable = {
    __index = function(self, key)
        print(key)
        return current_player()[key]
    end
}

local out = {
    current_player_bundleID = current_player_bundleID,
    current_player_name = current_player_name,
    fn = function(key, ...)
        local args = {...}
        return function()
            current_player()[key](table.unpack(args))
        end
    end
}
setmetatable(out, metatable);

return out
