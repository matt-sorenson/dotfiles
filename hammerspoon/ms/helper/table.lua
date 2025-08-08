--- this function returns a list of all the keys in a table
table.keys = function(t)
    local out = {}

    for k, _ in pairs(t) do
        table.insert(out, k)
    end

    return out
end

--- append all elements of the second table to the first table
table.append = function(t1, t2)
    table.each(t2, function(v) table.insert(t1, v) end)

    return t1
end

--- Find the key of a value in a table
--
-- @param haystack table to search
-- @param needle value to search for, or a function that takes a value
--    and returns true if the value is found
-- @return the key, value pair as 2 values, or nil if the value is not found
table.ifind = function(haystack, needle)
    for i, v in ipairs(haystack) do
        if 'function' == type(needle) then
            if needle(v) then
                return i, v
            end
        elseif v == needle then
            return i, v
        end
    end

    return nil
end

--- Find the key of a value in a table
--
-- @param haystack table to search
-- @param needle value to search for, or a function that takes a value
--    and returns true if the value is found
-- @return
--  Return the key, value pair as 2 values, or nil if the value is not found
table.find = function(haystack, needle)
    for k, v in pairs(haystack) do
        if 'function' == type(needle) then
            if needle(v) then
                return k, v
            end
        elseif v == needle then
            return k, v
        end
    end

    return nil
end

--- Execute a function on each element of a table (unordered iteration)
-- @param t table to iterate over
-- @param fn function to execute on each element, takes one argument, the value stored in the table
table.each = function(t, fn)
    for _, v in pairs(t) do
        fn(v)
    end
end

--- Execute a function on each element of an array
-- @param t table to iterate over
-- @param fn function to execute on each element, takes one argument, the value stored in the array
table.ieach = function(t, fn)
    for _, v in ipairs(t) do
        fn(v)
    end
end

--- Filter a table, the input table is not modified
-- @param t table to filter
-- @param fn
--    function to execute on each element, takes one argument,
--    the value stored in the table,
--    returns true if the element should be included in the output table
-- @return table of elements that passed the filter function
table.filter = function(t, fn)
    local out = {}

    for _, v in pairs(t) do
        if fn(v) then
            table.insert(out, v)
        end
    end

    return out
end

-- Map a function over a table
-- @param t table to map over
-- @param fn function to execute on each element, takes one argument, the value in the table
table.map = function(t, fn)
    local out = {}

    for k, v in pairs(t) do
        out[k] = fn(v)
    end

    return out
end

--- Map a function over an array
-- @param t array to map over
-- @param fn
--    function to execute on each element, takes one argument, the value in the array
--    return value is stored in output.
--    `nil` return value is dropped from output array.
-- @return array of results from the function
table.imap = function(t, fn)
    local out = {}

    for _, v in ipairs(t) do
        table.insert(out, fn(v))
    end

    return out
end

--- Create a shallow copy of a table
table.shallow_copy = function(t)
    local out = {}

    for k, v in pairs(t) do
        out[k] = v
    end

    return out
end

local function _deep_copy(t, ref_table, table_refs_to_not_copy)
    local out = {}
    ref_table[t] = out

    for k, v in pairs(t) do
        if 'table' == type(v) then
            if table.find(table_refs_to_not_copy, v) then
                out[k] = v
            else
                out[k] = ref_table[v]

                if not out[k] then
                    out[k] = _deep_copy(v, ref_table)
                end
            end
        else
            out[k] = v
        end
    end

    return out
end

--- Create a deep copy of a table
-- @param t table to copy
--    should handle circular references
--    If input table has multiple references to the same table the output table
--    will copy the referenced table once and use that copy for all references
-- @param table_refs_to_not_copy
--    Any tables in thist list will be copied as references
table.deep_copy = function(t, table_refs_to_not_copy)
    if not table_refs_to_not_copy then
        table_refs_to_not_copy = {}
    end

    return _deep_copy(t, {}, table_refs_to_not_copy)
end

--- Removes non-nil values from an array, in place
--
-- example table.compact({1, nil, 3}) would result in {1, 3}
--
-- @param t table to compact
-- @return the compacted table (same referance as input)
table.compact = function(t)
    for i = #t, 1, -1 do
        if t[i] == nil then
            table.remove(t, i)
        end
    end

    return t
end

local INDENT = '  '

--- Convert a table to a string representation
--
-- In cases of circular references the inner reference will be replaced with
-- the literal "'<circular>'".
--
-- @param t table to convert
-- @param indent the starting indentation to use, defaults to ''
-- @param looked_up a table of tables that have already been looked up, used to prevent circular references
-- @return a string representation of the table
table.tostring = function(t, indent, looked_up)
    if not looked_up then
        looked_up = {}
    end
    looked_up[t] = true

    if not indent then
        indent = ''
    end

    local out = '{\n'
    for k, v in pairs(t) do
        if type(v) == 'table' then
            if looked_up[v] then
                out = out .. indent .. k .. ': \'<circular>\',\n'
            else
                local tmp_looked_up = table.shallow_copy(looked_up)
                out = out .. indent .. k .. ': ' .. table.tostring(v, indent .. INDENT, tmp_looked_up) .. ',\n'
            end
        else
            if type(v) == 'string' then
                v = '"' .. v:gsub('"', '\\"') .. '"'
            end

            out = string.format('%s%s%s:%s,\n', out, indent, k, v)
        end
    end

    indent = indent:sub(1, -3)

    return out .. indent .. '}'
end

--- Remove an element from an array by value
-- @param t array to remove from
-- @param value value to remove
-- @return the array with the value removed, or nil if the value was not found
table.iremove_by_value = function(t, value)
    for i, v in ipairs(t) do
        if v == value then
            table.remove(t, i)
            return v
        end
    end

    return nil
end

table.ijoin = function(t1, sep)
    local out = ""

    for i, v in pairs(t1) do
        if i > 1 then
            out = out .. sep .. ' '
        end

        out = out .. tostring(v)
    end

    return out
end