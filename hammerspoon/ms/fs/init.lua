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

--[[ export]]
local function get_resource_path(local_path)
    return hs.configdir .. '/resources/' .. local_path
end

--[[ export ]]
local function ls_resource_path(local_path)
    return ls(get_resource_path(local_path))
end

--[[ export ]]
local function do_file_hs_local(filename)
    local file = hs.fs.pathToAbsolute(hs.configdir .. "/local/" .. filename)
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
    ls_resource_path = ls_resource_path,
    get_resource_path = get_resource_path,
    do_file_hs_local = do_file_hs_local,

    samba = require('ms.fs.samba'),
}
