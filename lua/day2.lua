local assert = require 'luassert'
local f = require 'fun'

local function is_possible(game)
    return game.blue <= 14 and game.green <= 13 and game.red <= 12
end

---@param s string
---@param sep string
---@return string[]
local function split(s, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for part in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, part)
    end
    return t
end

local function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

---@param raw_set string
---@return {red: number, green: number, blue: number}
local function parse_set(raw_set)
    local color_list = split(raw_set, ',')

    local result = {red = 0, blue = 0, green = 0}
    for _, raw_color in ipairs(color_list) do
        local left_and_right = split(trim(raw_color), ' ')
        result[left_and_right[2]] = tonumber(left_and_right[1])
    end

    return result
end

assert.same({blue = 2, red = 1, green = 2}, parse_set('2 blue, 1 red, 2 green'))

---@param line string
local function parse_game(line)
    local colon_index = line:find(":")
    local id = tonumber(line:sub(6, colon_index - 1))
    local set_list = f.map(parse_set, split(line:sub(colon_index + 2), ';'))

    return {set_list = set_list, id = id}
end

local parsed_game = parse_game(
                        'Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red')
assert.same(parsed_game.id, 4)
assert.same(f.totable(parsed_game.set_list), {
    {green = 1, red = 3, blue = 6}, {green = 3, red = 6, blue = 0},
    {blue = 15, red = 14, green = 3}
})

local function get(key) return function(t) return t[key] end end

local function max_for_color(set_list, color)
    return f.max(f.map(get(color), set_list))
end

local function power(set_list)
    return max_for_color(set_list, 'red') * max_for_color(set_list, 'blue') *
               max_for_color(set_list, 'green')
end

assert.same(power(parsed_game.set_list), 630)

local p1 = 0
local p2 = 0
while true do
    ---@type string
    local line = io.read("*l")
    if line == nil then break end

    local game = parse_game(line)
    if f.all(is_possible, game.set_list) then p1 = p1 + game.id end
    p2 = p2 + power(game.set_list)
end

print(tostring(p1))
print(tostring(p2))
