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

local PATHNAMES = {
    CONFIG = hs.configdir .. '/config',
    DOTFILES = hs.configdir .. '/..',
    HS = hs.configdir,
    LOCAL = hs.configdir .. '/../local',
    RESOURCES = hs.configdir .. '/resources',
}

local function get_path_helper(pathname, local_path)
    if local_path then
        pathname = pathname .. '/' .. local_path
    end

    return hs.fs.pathToAbsolute(pathname)
end

--[[ export ]]
local function file_exists(filename, pathname)
    if filename == nil then
        return false
    end

    if pathname then
        filename = pathname .. '/' .. filename
    end

    return hs.fs.attributes(filename) ~= nil
end

local function do_file_helper(filename, pathname)
    if not filename then
        error('filename is required for do_file_*')
    end

    if pathname then
        filename = pathname .. '/' .. filename
    end

    local fn, err = loadfile(filename)
    if not fn then
        error("Error loading file: " .. err)
    end

    return fn()
end

return {
    ls = ls,

    get_config_path = function(local_path)
        return get_path_helper(PATHNAMES.CONFIG, local_path)
    end,
    get_dotfiles_path = function(local_path)
        return get_path_helper(PATHNAMES.DOTFILES, local_path)
    end,
    get_hs_path = function(local_path)
        return get_path_helper(PATHNAMES.HS, local_path)
    end,
    get_local_path = function(local_path)
        return get_path_helper(PATHNAMES.LOCAL, local_path)
    end,
    get_resource_path = function(local_path)
        return get_path_helper(PATHNAMES.RESOURCES, local_path)
    end,

    file_exists = file_exists,

    file_exists_config = function(path)
        return file_exists(path, PATHNAMES.CONFIG)
    end,
    file_exists_dotfiles = function(path)
        return file_exists(path, PATHNAMES.DOTFILES)
    end,
    file_exists_hs = function(path)
        return file_exists(path, PATHNAMES.HS)
    end,
    file_exists_local = function(path)
        return file_exists(path, PATHNAMES.LOCAL)
    end,
    file_exists_resource = function(path)
        return file_exists(path, PATHNAMES.RESOURCES)
    end,

    do_file_resources = function(file)
        return do_file_helper(file, PATHNAMES.RESOURCES)
    end,
    do_file_local  = function(file)
        return do_file_helper(file, PATHNAMES.LOCAL)
    end,
    do_file_config = function(file)
        return do_file_helper(file, PATHNAMES.CONFIG)
    end,

    samba = require('ms.fs.samba'),
}
