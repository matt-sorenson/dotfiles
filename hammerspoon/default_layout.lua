local layout   = require 'ms.layout'
local sys      = require 'ms.sys'

layout.add_app('Finder',        nil, 'primary',    0, 0, 1/6, 1)
layout.add_app('Sublime Text',  nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('Quiver',        nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('NoMachine',     nil, 'primary',  1/6, 0, 1/2, 1)
layout.add_app('Google Chrome', nil, 'primary',  2/3, 0, 1/3, 1)
layout.add_app('Firefox',       nil, 'primary',  2/3, 0, 1/3, 1)

if sys.is_work_computer() then
    layout.add_app('iTerm',    nil,        'secondary',    0,   0, 9/10, 1/2)
    layout.add_app('Slack',    nil,        'secondary', 1/10,   0, 9/10, 1/2)
    layout.add_app('Adium',    nil,        'secondary',    0, 1/2,  1/3, 1/2)
    layout.add_app('Adium',    'Contacts', 'secondary',  2/3, 1/2,  1/3, 1/2)
    layout.add_app('Messages', nil,        'secondary',  1/5, 4/7,  3/5, 3/7)
else
    layout.add_app('iTerm' , nil, 'secondary',   0,   0,   1, 1/3)
    layout.add_app('Slack',  nil, 'secondary', 1/2, 2/3, 1/2, 1/3)
end


layout.add_app(nil,       'Youtube',      'secondary', 1/8, 1/2, 6/8, 1/3)
layout.add_app(nil,       'Amazon Music', 'secondary', 1/8, 1/2, 6/8, 1/3)
layout.add_app('Spotify', nil,            'secondary', 1/8, 1/2, 6/8, 1/3)
layout.add_app('iTunes',  nil,            'secondary', 1/8, 1/2, 6/8, 1/3)
layout.add_app(nil,       'reddit',       'secondary', 1/8, 4/7, 6/8, 3/7)
layout.add_app(nil,       'Hacker News',  'secondary', 1/8, 4/7, 6/8, 3/7)