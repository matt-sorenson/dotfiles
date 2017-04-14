local current_modal, _default_modal

local function set_window_rect(rect)
    return function()
        local win = hs.window.focusedWindow()
        local screen_frame = win:screen():frame()

        local frame = {
            x = screen_frame.x + (screen_frame.w * rect[1]),
            y = screen_frame.y + (screen_frame.h * rect[2]),
            w = screen_frame.w * rect[3],
            h = screen_frame.h * rect[4]
        }

        win:setFrameInScreenBounds(frame)
    end
end

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

local function modal_bind_wrapper_fn(self, fn)
    return function()
        result, msg = pcall(fn);

        if not result then
            print(msg)
        end

        self:exit();
    end
end

local function modal_bind_wrapper_shift(self, mods, key, msg, fn, options)
    local new_opts = hs.fnutils.copy(options)
    local new_mods = hs.fnutils.copy(mods)

    new_opts.shiftable = nil
    new_opts.skip_help_msg = true
    new_opts.skip_clear_modal = true
    table.insert(new_mods, 'shift')

    self:bind(new_mods, key, msg, fn, new_opts)
end

local function convert_to_help_msg(mods, key, msg)
    mods = hs.fnutils.map(mods, function(mod) return hs.utf8.registeredKeys[mod] or mod end)
    table.insert(mods, key)

    return {shortcut = table.concat(mods), msg = msg}
end

local function modal_bind(self, mods, key, msg, fn, options)
    if 'table' == type(msg) or 'function' == type(msg) then
        options = fn or {}
        fn = msg
        msg = nil
    end

    options = options or {}

    if options.shiftable then
        modal_bind_wrapper_shift(self, mods, key, msg, fn, options)
    end

    if not options.skip_clear_modal then
        fn = modal_bind_wrapper_fn(self, fn)
    end

    local bind = hs.hotkey.new(mods, key, msg, fn)
    table.insert(self.saved_binds, bind)

    if (not options.skip_help_msg) and msg then
        table.insert(self.msgs, convert_to_help_msg(mods, key, msg))
    end

    if self.running then
        bind:enable()
    end
end

local function modal_add_help_seperator(self)
    table.insert(self.msgs, '-----------------')
end

local displayed_alert
local function alert(msg)
    if displayed_alert then
        hs.alert.closeSpecific(displayed_alert, 0)
        displayed_alert = nil
    end

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

        return string.format('%-' .. max_shortcut .. 's\t%s', msg.shortcut, msg.msg)
    end)

    alert(table.concat(formatted_msgs, '\n'))
end

local function modal_new(parent, mods, key, name)
    local out = {}

    out.saved_binds = {}
    out.msgs = {}
    out.running = false

    out.on_enter = function() end
    out.on_exit = function()
        _default_modal:enter()
        clear_alert()
    end

    out.enter = modal_enter
    out.exit = modal_exit
    out.bind = modal_bind

    out.add_help_seperator = modal_add_help_seperator

    if parent then
        parent:bind(mods, key, name, function() out:enter() end, name)
        out:bind({}, 'H', function() print_help(out) end, { skip_clear_modal = true })
        out:bind({}, 'ESCAPE', function() hs.alert('⎋ - Cancel') end)
    end

    return out;
end

local function default_modal()
    if not _default_modal then
        _default_modal = modal_new()
        _default_modal.on_exit = function() end
        _default_modal:enter()
    end

    return _default_modal
end

return {
    modal_new = modal_new,
    default_modal = default_modal,

    set_window_rect = set_window_rect,
}
