local layout   = require 'ms.layout'
local sys      = require 'ms.sys'

-- Misc
layout.add_app('default', 'Finder',        nil, 'primary',    0, 0, 1/6, 1)
layout.add_app('default', 'Sublime Text',  nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('default', 'Quiver',        nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('default', 'NoMachine',     nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('default', 'Google Chrome', nil, 'primary',  2/3, 0, 1/3, 1)
layout.add_app('default', 'Firefox',       nil, 'primary',  2/3, 0, 1/3, 1)

if sys.is_work_computer() then
    layout.add_app('default', 'iTerm',    nil,        'secondary',    0,   0, 9/10, 1/2)
else
    layout.add_app('default', 'iTerm' , nil, 'secondary',   0,   0,   1, 1/3)
end

local function add_communications_layouts(layout_name)
    if sys.is_work_computer() then
        layout.add_app(layout_name, 'Slack',    nil,        'secondary', 1/10,   0, 9/10, 1/2)
        layout.add_app(layout_name, 'Adium',    nil,        'secondary',    0, 1/2,  1/3, 1/2)
        layout.add_app(layout_name, 'Adium',    'Contacts', 'secondary',  2/3, 1/2,  1/3, 1/2)
        layout.add_app(layout_name, 'Messages', nil,        'secondary',  1/5, 4/7,  3/5, 3/7)
    else
        layout.add_app(layout_name, 'Slack',  nil, 'secondary', 1/2, 2/3, 1/2, 1/3)
    end
end

local function add_media_layouts(layout_name)
    layout.add_app(layout_name, nil,       'Youtube',      'secondary', 1/8, 1/2, 6/8, 1/3)
    layout.add_app(layout_name, nil,       'Amazon Music', 'secondary', 1/8, 1/2, 6/8, 1/3)
    layout.add_app(layout_name, 'Spotify', nil,            'secondary', 1/8, 1/2, 6/8, 1/3)
    layout.add_app(layout_name, 'iTunes',  nil,            'secondary', 1/8, 1/2, 6/8, 1/3)
    layout.add_app(layout_name, nil,       'reddit',       'secondary', 1/8, 4/7, 6/8, 3/7)
    layout.add_app(layout_name, nil,       'Hacker News',  'secondary', 1/8, 4/7, 6/8, 3/7)
end

add_communications_layouts('default')
add_media_layouts('default')

add_communications_layouts('communications')

add_media_layouts('media')
