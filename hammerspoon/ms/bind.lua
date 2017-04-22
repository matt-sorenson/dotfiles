local current_modal, _default_modal

local function modal_enter(self)
    if current_modal and (current_modal ~= self) then
        current_modal:exit(true)
    end

    hs.fnutils.each(self.saved_binds, function(bind) bind:enable() end)

    self.running = true
    current_modal = self
    self:on_enter()
end

local function modal_exit(self, skip_default)
    hs.fnutils.each(self.saved_binds, function(bind) bind:disable() end)

    current_modal = nil
    self.running = false
    self:on_exit()
end

local function modal_bind_wrapper_fn(self, fn, skip_reset)
    return function()
        result, msg = pcall(fn);

        if not result then
            print(msg)
        end

        if not skip_reset then
            self:exit();
        end
    end
end

local function modal_bind_wrapper_shift(self, mods, key, msg, fn, options)
    local new_opts = hs.fnutils.copy(options)
    local new_mods = hs.fnutils.copy(mods)

    new_opts.shiftable = nil
    new_opts.skip_help_msg = false
    new_opts.shifted = true
    new_opts.skip_clear_modal = true
    table.insert(new_mods, 'shift')

    self:bind(new_mods, key, msg, fn, new_opts)
end

local function convert_to_help_msg(mods, key, msg, shiftable)
    mods = table.concat(hs.fnutils.map(mods, function(mod)
        local out = hs.utf8.registeredKeys[mod] or mod

        if shiftable and '⇧' == out then
            out = '[⇧]'
        end

        return out
    end))

    return {shortcut = mods .. key, msg = msg}
end

local function modal_bind(self, mods, key, msg, fn, options)
    if type(msg) == 'function' then
        options = fn
        fn = msg
        msg = nil
    end
    options = options or {}

    if options.shiftable then
        modal_bind_wrapper_shift(self, mods, key, msg, fn, options)
        options = hs.fnutils.copy(options)
        options.skip_help_msg = true
    end

    fn = modal_bind_wrapper_fn(self, fn, options.skip_clear_modal)

    local bind = hs.hotkey.new(mods, key, msg, fn)
    table.insert(self.saved_binds, bind)

    if (not options.skip_help_msg) and msg then
        table.insert(self.msgs, convert_to_help_msg(mods, key, msg, options.shifted))
    end

    if self.running then
        bind:enable()
    end
end

local displayed_alert
local function clear_alert()
    if displayed_alert then
        hs.alert.closeSpecific(displayed_alert, 0)
        displayed_alert = nil
    end
end

local function alert(msg)
    clear_alert()
    displayed_alert = hs.alert(msg, 3)
end

local function print_help(self)
    local max_shortcut = 0

    hs.fnutils.ieach(self.msgs, function(msg)
        if ('table' == type(msg)) and (#msg.shortcut > max_shortcut) then
            max_shortcut = #msg.shortcut
        end
    end)

    formatted_msgs = hs.fnutils.map(self.msgs, function(msg)
        if 'string' == type(msg) then
            return msg
        end

        return string.format('%-' .. max_shortcut .. 's %s', msg.shortcut, msg.msg)
    end)

    alert(table.concat(formatted_msgs, '\n'))
end

local modal_mt = { __index = {} }

modal_mt.__index.on_enter = function() end
modal_mt.__index.on_exit = function() _default_modal:enter() end
modal_mt.__index.enter = modal_enter
modal_mt.__index.exit = modal_exit
modal_mt.__index.bind = modal_bind

modal_mt.__index.help_seperator = function(self)
    table.insert(self.msgs, '----------')
end

local function escape_fn() hs.alert('⎋ - Cancel') end

local function modal_new(parent, mods, key, name)
    parent = ((parent ~= 'noparent') and (parent or _default_modal)) or nil

    local out = {}
    setmetatable(out, modal_mt)

    out.saved_binds = {}
    out.msgs = {}
    out.running = false

    if parent then
        parent:bind(mods, key, name, function() out:enter() end)
        out:bind({}, 'H', function() print_help(out) end, { skip_clear_modal = true })
        out:bind({}, 'ESCAPE', escape_fn)
    end

    return out;
end

_default_modal = modal_new('noparent')
_default_modal.on_enter = function() clear_alert() end
_default_modal.on_exit = function() end
_default_modal:enter()

return {
    new = modal_new,
}
