--[[ export ]] function get_random_team_member(team_name)
    local TEAMMATE_FILENAME = hs.fs.pathToAbsolute("~/.dotfiles/local/" .. team_name)

    if nil == hs.fs.attributes(TEAMMATE_FILENAME) then
        hs.alert("'" .. TEAMMATE_FILENAME .. "' is missing")
        return
    end

    local PR_TARGETS = {}
    for name in io.lines(TEAMMATE_FILENAME) do
        PR_TARGETS[#PR_TARGETS + 1] = name
    end

    hs.alert(PR_TARGETS[hs.math.random(1, #PR_TARGETS)], 3)
end

return {
    get_random_team_member = get_random_team_member,
    get_random_team_member_fn = function(team_name) return function() get_random_team_member(team_name) end end
}
