local print = require('ms.logger').new('ms.workspace.init')

-- Apple doesn't like others messing with workspace creation so
-- we sleep to allow the hacky way to interact with workspaces to work.
local function sleep()
    local one_second_in_useconds = 1000000
    hs.timer.usleep(one_second_in_useconds)
end

--[[export]]
--@return integer | nil
--     an opaque id of the new workspace
--     or nil if the workspace could not be created
local function new_workspace()
    local before_spaces = hs.spaces.spacesForScreen()

    local success, error = hs.spaces.addSpaceToScreen()

    if not success then
        print:error("Failed to create new workspace: " .. error)
        return
    end

    sleep()
    local after_spaces = hs.spaces.spacesForScreen()

    local new_spaces = table.filter(after_spaces, function(space)
        return not table.find(before_spaces, space)
    end)

    if #new_spaces == 0 then
        print:error("Failed to find new workspace id", {
            before_spaces = before_spaces,
            after_spaces = after_spaces,
        })
        return
    elseif #new_spaces > 1 then
        print:error("More than 1 new workspace created, yay race conditions!")
        return
    end

    print('Created new workspace with id: ' .. new_spaces[1])

    return new_spaces[1]
end

--[[export]]
local function change_to_workspace(workspace_id)
    local success, error = hs.spaces.gotoSpace(workspace_id or 1)

    if not success then
        print:error("Failed to change to workspace: " .. error)
    end

    return not not success, error
end

--[[export]]
-- Currently broket
local function move_window_to_workspace(window, workspace_id)
    print:warn('move_window_to_workspace is broken')

    local success, error = hs.spaces.moveWindowToSpace(window, workspace_id)

    if not success then
        print:error("Failed to move window to workspace: " .. error)
    end

    return success, error
end

--[[export]]
--- @param workspace_id string | nil
---     the id of the workspace to destroy, if not provided then the current
---     workspace is destroyed
local function destroy_workspace(workspace_id)
    if workspace_id == nil then
        workspace_id = hs.spaces.focusedSpace()
    end

    if workspace_id == nil then
        print:error("Failed to destroy workspace: no workspace id provided/found")
        return
    elseif workspace_id == 1 then
        print:error("Failed to destroy workspace: cannot destroy default workspace")
        return
    end

    local success, error = hs.spaces.gotoSpace(1)
    if not success then
        print:error("Failed to go to default workspace: " .. error)
    end

    success, error = hs.spaces.removeSpace(workspace_id)

    if not success then
        print:error("Failed to destroy workspace: " .. error)
    end
end

local function launchOrGetApp(bundleId)
    local app = hs.application.get(bundleId)
    if app == nil then
        hs.application.launchOrFocusByBundleID(bundleId)
        app = hs.application.get(bundleId)
    end
    return app
end

--[[export]]
--- Create a new workspace with zoom and a new vscode window for notes
local function zoom_meeting()
    local new_workspace_id = new_workspace()

    if new_workspace_id == nil then
        print:error("Failed to create new workspace for zoom meeting")
        return
    end

    local success, error = change_to_workspace(new_workspace_id)

    if not success then
        print:error("Failed to change to new workspace for zoom meeting: " .. error)
        -- Not returning here, still try to move windows
    end
    sleep()

    local code = launchOrGetApp('com.microsoft.VSCode')
    if code ~= nil then
        code:selectMenuItem({ 'File', 'New Window' })
    end

    -- Zoom is last so it's focused
    -- move_window_to_workspace is broken, consider checking if there are
    -- no windows or only `Zoom Workplace` open and closing the app and re-launching
    local zoom = launchOrGetApp('us.zoom.xos')
    if zoom ~= nil then
        table.each(zoom:allWindows(), function(window)
            print('moving window to workspace: ' .. new_workspace_id, window)

            -- drop any errors on the floor
            move_window_to_workspace(window, new_workspace_id)
            window:focus()
        end)
    end
end

return {
    new_workspace = new_workspace,
    move_window_to_workspace = move_window_to_workspace,
    destroy_workspace = destroy_workspace,

    zoom_meeting = zoom_meeting,
}
