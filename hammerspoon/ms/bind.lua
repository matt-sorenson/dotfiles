local print = require('ms.logger').print_fn('ms.bind')

-- only log errors from within the hs.hotkey module
hs.hotkey.setLogLevel('error')

local current_modal, _default_modal

local function modal_enter(self)
    if current_modal and (current_modal ~= self) then
        current_modal:exit(true)
    end

    table.each(self.saved_binds, function(bind) bind:enable() end)

    self.running = true
    current_modal = self
    self:on_enter()
end

local function modal_exit(self, skip_default)
    table.each(self.saved_binds, function(bind) bind:disable() end)

    self.running = false
    current_modal = nil
    if self:on_exit() and (not skip_default) then
        _default_modal:enter()
    end
end

local function modal_bind_fn_wrapper_fn(self, fn, skip_clear)
    return function()
        local result, msg = pcall(fn);

        if not result then
            hs.notify.new(hs.openConsole, {
                title = 'Hammerspoon',
                subTitle = msg,
                informativeText = ''
            }):send()

            print(msg)
        end

        if not skip_clear then
            self:exit()
        end
    end
end

local function modal_bind_fn_wrapper(self, fn, skip_clear)
    local out = {}

    if 'function' == type(fn) then
        fn = { pressed_fn = fn }
    end

    if fn.pressed_fn and fn.release_fn then
        out.pressed_fn = modal_bind_fn_wrapper_fn(self, fn.pressed_fn, true)
        out.release_fn = modal_bind_fn_wrapper_fn(self, fn.release_fn, skip_clear)
    elseif fn.pressed_fn and (not fn.release_fn) then
        out.pressed_fn = modal_bind_fn_wrapper_fn(self, fn.pressed_fn, skip_clear)
    elseif (not fn.pressed_fn) and fn.release_fn then
        out.release_fn = modal_bind_fn_wrapper_fn(self, fn.release_fn, skip_clear)
    else
        error('at least pressed or release fn must be passed to hotkey')
    end

    if fn.repeat_fn then
        out.repeat_fn = modal_bind_fn_wrapper_fn(self, fn.repeat_fn, true)
    end

    return out
end

local function array_set_remove(t1, t2)
    local out = {}

    for _, v in ipairs(t1) do
        if not table.ifind(t2, v) then
            table.insert(out, v)
        end
    end

    return out
end

local function normalize_mod(mod)
    if 'command' == mod then
        mod = 'cmd'
    elseif 'control' == mod then
        mod = 'ctrl'
    end

    return hs.utf8.registeredKeys[mod] or mod:upper()
end

local function dedup_mods(mods, opt)
    local out = {}

    if mods then
        for _, v in ipairs(toarray(mods)) do
            out[normalize_mod(v)] = true
        end
    end

    if opt then
        for _, v in ipairs(toarray(opt)) do
            out[normalize_mod(v)] = true
        end
    end

    return table.keys(out)
end

local function modal_convert_to_help_msg(config)
    local optional_mods = dedup_mods(config.optional_mods, toarray(config.repeat_on_mods))
    local required_mods = dedup_mods(config.mods)

    required_mods = array_set_remove(required_mods, optional_mods)

    local mods_str = table.concat(required_mods, '')
    local opt_mods_str = table.concat(optional_mods, '][')
    local key_str = config.key:upper()

    if 0 ~= #opt_mods_str then
        opt_mods_str = '[' .. opt_mods_str .. ']'
    end

    return {
        shortcut = opt_mods_str .. mods_str .. key_str,
        msg = config.msg
    }
end

local function modal_bind(self, config)
    if config.repeat_on_mods then
        -- If repeat_on_mods is set then we duplicate the config
        -- and, modify it to include the mod & hide the help message and
        -- bind it in the same place as the original config
        local repeat_on_mods_config = table.deep_copy(config)
        if not repeat_on_mods_config.mods then
            repeat_on_mods_config.mods = {}
        end

        table.append(repeat_on_mods_config.mods, toarray(config.repeat_on_mods))
        repeat_on_mods_config.repeat_on_mods = nil
        repeat_on_mods_config.skip_clear = true
        repeat_on_mods_config.skip_help_msg = true

        modal_bind(self, repeat_on_mods_config)
    end

    local fn = modal_bind_fn_wrapper(self, config.fn, config.skip_clear)

    local arg_msg = config.msg
    local arg_pressed_fn = fn.pressed_fn
    local arg_release_fn = fn.release_fn
    local arg_repeat_fn = fn.repeat_fn

    if not arg_msg then
        arg_msg = fn.pressed_fn
        arg_pressed_fn = fn.arg_release_fn
        arg_release_fn = fn.repeat_fn
        arg_repeat_fn = nil
    end

    local bind = hs.hotkey.new(config.mods or '', config.key,
        arg_msg, arg_pressed_fn, arg_release_fn, arg_repeat_fn)

    if config.msg and (not config.skip_help_msg) then
        table.insert(self.msgs, modal_convert_to_help_msg(config))
    end

    if self.running then
        bind:enable()
    end

    table.insert(self.saved_binds, bind)
end

local displayed_alert
local function modal_clear_alert()
    if displayed_alert then
        hs.alert.closeSpecific(displayed_alert, 0)
        displayed_alert = nil
    end
end

local function modal_alert(msg)
    modal_clear_alert()
    displayed_alert = hs.alert(msg, { textFont = 'Berkeley Mono' }, 3)
end

local function modal_print_help(self)
    local max_shortcut = 0
    local max_msg = 0

    table.ieach(self.msgs, function(msg)
        if 'table' == type(msg) then
            if hs.utf8.len(msg.shortcut) > max_shortcut then
                max_shortcut = hs.utf8.len(msg.shortcut)
            end

            if hs.utf8.len(msg.msg) > max_msg then
                max_msg = hs.utf8.len(msg.msg)
            end
        end
    end)

    local formatted_msgs = table.map(self.msgs, function(msg)
        if 'string' == type(msg) then
            local shortcut = string.rep('─', max_shortcut)
            local msg = string.rep('─', max_msg)

            return string.format('%s%s%s%s%s', '├', shortcut, '┼', msg, '┤')
        end

        local shortcut_prefix = string.rep(' ', max_shortcut - hs.utf8.len(msg.shortcut))
        local msg_prefix = string.rep(' ', max_msg - hs.utf8.len(msg.msg))

        local shortcut = shortcut_prefix .. msg.shortcut
        local message = msg_prefix .. msg.msg

        return string.format('│%s│%s│', shortcut, message)
    end)

    local shortcut = string.rep('─', max_shortcut)
    local msg = string.rep('─', max_msg)
    local prepend = string.format('%s%s%s%s%s', '┌', shortcut, '┬', msg, '┐')
    local postpend = string.format('%s%s%s%s%s', '└', shortcut, '┴', msg, '┘')

    modal_alert(prepend .. '\n' .. table.concat(formatted_msgs, '\n') .. '\n' .. postpend)
end

local modal_mt = { __index = {} }
modal_mt.__index.on_enter = function() end
modal_mt.__index.on_exit = function() return true end
modal_mt.__index.enter = modal_enter
modal_mt.__index.exit = modal_exit
modal_mt.__index.bind = modal_bind
modal_mt.__index.help_seperator = function(self)
    table.insert(self.msgs, '─')
end

local function escape_fn() hs.alert('⎋ - Cancel') end

--[[export]]
local function modal_new(config, parent)
    parent = ((parent ~= 'noparent') and (parent or _default_modal)) or nil

    local out = {}
    setmetatable(out, modal_mt)

    out.saved_binds = {}
    out.children = {}
    out.msgs = {}
    out.running = false
    out.title = config.title

    if parent then
        local title = config.title
        if config.skip_help_msg then
            title = nil
        end

        parent:bind({ mods = config.mods, key = config.key, msg = title, fn = function() out:enter() end, skip_clear = true })
        out:bind({ key = 'H', fn = function() modal_print_help(out) end, skip_clear = true })
        out:bind({ key = 'escape', fn = escape_fn })
    end

    for _, v in ipairs(config) do
        if '-' == v then
            out:help_seperator()
        elseif v.title then
            out.children[v.title:lower()] = modal_new(v, out)
        else
            out:bind(v)
        end
    end

    return out;
end

--[[export]]
local function init(config)
    _default_modal = modal_new(config, 'noparent')
    _default_modal.on_enter = function() modal_clear_alert() end
    _default_modal.on_exit = function() end
    _default_modal:enter()

    return _default_modal
end

return {
    init = init,
    new = modal_new
}
