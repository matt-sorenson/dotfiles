local function messages_slack_window_rect(win)
    -- If both slack and messages are open then put slack on the left 7/8 of the
    -- bottom of screen and messages on the right 7/8 of the bottom of the screen.
    -- Otherwise they take the full bottom of the screen
    local messagesBundleId = 'com.apple.MobileSMS'
    local slackBundleId = 'com.tinyspeck.slackmacgap'

    local inBundleId = win:application():bundleID()
    
    if inBundleId == slackBundleId then
        if hs.application.find(messagesBundleId) then
            return { 0, 1/2, 7/8, 1/2 }
        end
    elseif inBundleId == messagesBundleId then
        if hs.application.find(slackBundleId) then
            return { 1/8, 1/2, 7/8, 1/2 }
        end
    end

    return { 0, 1/2, 1, 1/2 }
end

return {
    layout = {
        { -- Primary Horizontal Screen
            screen = {'3840x1600', '3440x1440'},

            { app = {'Code', 'DataGrip', 'IntelliJ IDEA', 'TablePlus'}, section = 1 },
            -- TablePlus "New Workspace" window
            { app = 'TablePlus', window = '', resize_center = { 898, 556 } },

            { app = {'Chrome'},  section = 2 },

            { app = 'zoom.us', resize_center = { 1280, 960 }, categories = 'communications' },
            { app = {'okta', 'AWS VPN Client'}, center = true },

            { window = 'Hammerspoon Console', rect = { 11 / 16, 1/10, 4/16, 4/5 } }
        },
        { -- Side Vertical Screen
            screen = { 'DELL G2725D', '1440x2560' },

            { app = {'Firefox', 'Music'}, section = 3, categories = 'media' },

            { app = 'Messages', rect = messages_slack_window_rect, categories = 'communications' },
            { app = 'Slack',    rect = messages_slack_window_rect, categories = 'communications' },
        }
    },

    sections = {
        { screen = 1, rect = {   0,   0, 5/8,   1 } },
        { screen = 1, rect = { 5/8,   0, 3/8,   1 } },

        { screen = 2, rect = {   0,   0,   1, 1/2 } },
        { screen = 2, rect = {   0, 1/2,   1, 1/2 } },
    },

    is_work_computer = true,
}
