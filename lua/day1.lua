local assert = require 'luassert'

local function parse_cali_value(line)
    local first = line:match("%d")
    local last = line:reverse():match("%d")
    return tonumber(first .. last)
end

assert.same(parse_cali_value("1abc2"), 12)
assert.same(parse_cali_value("pqr3stu8vwx"), 38)
assert.same(parse_cali_value("a1b2c3d4e5f"), 15)
assert.same(parse_cali_value("treb7uchet"), 77)

local dict = {
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
}

---@param line string
local function find_first(line)
    local s = line:find("%d")
    local value = line:match("%d")

    for digit, word in ipairs(dict) do
        local temp_s = line:find(word)
        if s == nil or temp_s and temp_s < s then
            s = temp_s
            value = digit
        end
    end

    return tostring(value)
end

---@param line string
local function find_last(line)
    local reversed = line:reverse()
    local _, e = reversed:find("%d")
    local value = reversed:match("%d")

    for digit, word in ipairs(dict) do
        local _, temp_e = reversed:find(word:reverse())
        if e == nil or temp_e and temp_e < e then
            e = temp_e
            value = digit
        end
    end

    return tostring(value)
end

local function parse_cali_value_2(line)
    return tonumber(find_first(line) .. find_last(line))
end
local cases = {
    {"two1nine", 29}, {"eightwothree", 83}, {"abcone2threexyz", 13},
    {"xtwone3four", 24}, {"4nineeightseven2", 42}, {"zoneight234", 14},
    {"7pqrstsixteen", 76}, {"3eightnineonesixslhkjqgmreight", 38}
}

for _, case in ipairs(cases) do
    assert.same(parse_cali_value_2(case[1]), case[2], case[1])
end

local result = 0

while true do
    local line = io.read("*l")
    if line == nil then break end
    result = result + parse_cali_value_2(line)
end

io.write(tostring(result))
