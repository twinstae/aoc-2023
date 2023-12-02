local assert = require 'luassert'

---@param s string
---@param target string
---@return boolean
local function startswith(s, target)
    return target ~= nil and string.sub(s, 1, #target) == target
end

---@param s string
---@return boolean
local function isdigit(s) return s ~= nil and s ~= "" and not s:find("%D") end

local function parse_cali_value(line)
    ---@type number[]
    local digits = {}
    for c in line:gmatch('.') do
        if isdigit(c) then table.insert(digits, c) end
    end

    return tonumber(digits[1] .. digits[#digits])
end

assert.same(parse_cali_value("1abc2"), 12)
assert.same(parse_cali_value("pqr3stu8vwx"), 38)
assert.same(parse_cali_value("a1b2c3d4e5f"), 15)
assert.same(parse_cali_value("treb7uchet"), 77)

local dict = {
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
}

---@param line string
local function parse_cali_value_2(line)
    ---@type number[]
    local digits = {}
    for i = 1, #line do
        local c = line:sub(i, i)
        if isdigit(c) then table.insert(digits, c) end
        for d, val in ipairs(dict) do
            if startswith(line:sub(i), val) then
                table.insert(digits, tostring(d))
            end
        end
    end

    return tonumber(digits[1] .. digits[#digits])
end

---@type { [1]: string, [2]: number }[]
local cases = {
    {"two1nine", 29}, {"eightwothree", 83}, {"abcone2threexyz", 13},
    {"xtwone3four", 24}, {"4nineeightseven2", 42}, {"zoneight234", 14},
    {"7pqrstsixteen", 76}, {"3eightnineonesixslhkjqgmreight", 38}
}

for _, case in ipairs(cases) do
    assert.same(parse_cali_value_2(case[1]), case[2], case[1])
end

local p2 = 0
while true do
    ---@type string
    local line = io.read("*l")
    if line == nil then break end

    p2 = p2 + parse_cali_value_2(line)
end

print(tostring(p2))
