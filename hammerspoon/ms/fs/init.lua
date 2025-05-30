--[[ export ]]
local function ls(dir)
    local _, iter = hs.fs.dir(dir)
    local contents = {}

    repeat
        local filename = iter:next()

        if (filename and ('..' ~= filename) and ('.' ~= filename)) then
            table.insert(contents, filename)
        end
    until filename == nil
    iter:close()

    return contents
end

local function get_path_helper(root_path, local_path)
    if local_path then
        root_path = root_path .. '/' .. local_path
    end

    return hs.fs.pathToAbsolute(root_path)
end

--[[ export ]]
local function get_hs_path(local_path)
    return get_path_helper(hs.configdir, local_path)
end

--[[ export ]]
local function get_dotfiles_path(local_path)
    return get_path_helper(hs.configdir .. '/../', local_path)
end

--[[ export]]
local function get_resource_path(local_path)
    return get_path_helper(hs.configdir .. '/resources/', local_path)
end

--[[ export ]]
local function get_config_path(config_path)
    return get_path_helper(hs.configdir .. '/config/', config_path)
end

--[[ export ]]
local function get_local_path(local_path)
    return get_path_helper(get_dotfiles_path() .. '/local/', local_path)
end

local function do_file_helper(filename, path_fn)
    local file = path_fn(filename)
    if not file then
        error("Could not find file: " .. filename)
    end

    local fn, err = loadfile(file)
    if not fn then
        error("Error loading file: " .. err)
    end

    return fn()
end

return {
    ls = ls,

    get_config_path = get_config_path,
    get_dotfiles_path = get_dotfiles_path,
    get_hs_path = get_hs_path,
    get_resource_path = get_resource_path,
    get_local_path = get_local_path,

    do_file_resources = function(file) return do_file_helper(file, get_resource_path) end,
    do_file_local  = function(file) return do_file_helper(file, get_local_path) end,

    samba = require('ms.fs.samba'),
}
