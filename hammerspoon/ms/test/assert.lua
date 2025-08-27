local function assert_run(condition, error_object)
    if 'function' == type(condition) then
        condition = condition()
    end

    if not condition then
        error(error_object)
    end
end

local function equal(a, b, message)
    assert_run(a == b, {
        message = message,
        expected = a,
        actual = b,
        type = 'equal',
    })
end

local function not_equal(a, b, message)
    assert_run(a ~= b, {
        message = message,
        expected = a,
        actual = b,
        type = 'not_equal',
    })
end

local function array_unordered_equal(expected, actual, message)
    table.sort(expected)
    table.sort(actual)

    assert_run(table.deep_eq(expected, actual), {
        message = message,
        expected = function() return table.tostring(expected) end,
        actual = function() return table.tostring(actual) end,
        type = 'array_unordered_equal',
    })
end

local function not_array_unordered_equal(expected, actual, message)
    table.sort(expected)
    table.sort(actual)

    assert_run(not table.deep_eq(expected, actual), {
        message = message,
        expected = function() return table.tostring(expected) end,
        actual = function() return table.tostring(actual) end,
        type = 'not_array_unordered_equal',
    })
end

local function deep_equal(expected, actual, message)
    assert_run(table.deep_eq(expected, actual), {
        message = message,
        expected = function() return table.tostring(expected) end,
        actual = function() return table.tostring(actual) end,
        type = 'deep_equal',
    })
end

local function not_deep_equal(expected, actual, message)
    assert_run(not table.deep_eq(expected, actual), {
        message = message,
        expected = function() return table.tostring(expected) end,
        actual = function() return table.tostring(actual) end,
        type = 'not_deep_equal',
    })
end

local function is_true(condition, message)
    assert_run(condition and 'boolean' == type(condition), {
        message = message,
        type = 'is_true',
    })
end

local function is_false(condition, message)
    assert_run(not condition and 'boolean' == type(condition), {
        message = message,
        type = 'is_false',
    })
end

local function is_truthy(condition, message)
    assert_run(condition, {
        message = message,
        type = 'is_truthy',
    })
end

local function is_falsey(condition, message)
    assert_run(not condition, {
        message = message,
        type = 'is_falsey',
    })
end

local function is_nil(a, message)
    assert_run(a == nil, {
        message = message,
        expected = '<nil>',
        actual = a,
        type = 'is_nil',
    })
end

local function not_nil(a, message)
    assert_run(a ~= nil, {
        message = message,
        expected = '<nil>',
        actual = a,
        type = 'not_nil',
    })
end

return {
    equal = equal,
    not_equal = not_equal,

    deep_equal = deep_equal,
    not_deep_equal = not_deep_equal,

    array_unordered_equal = array_unordered_equal,
    not_array_unordered_equal = not_array_unordered_equal,

    is_true = is_true,
    is_false = is_false,

    is_truthy = is_truthy,
    is_falsey = is_falsey,

    is_nil = is_nil,
    not_nil = not_nil,
}
