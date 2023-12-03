local assert = require 'luassert'
local f = require 'lua.fun'
local inspect = require 'inspect'

---@param line string
---@return { num_list: { start: number, last: number, value: number }[] }
local function parse_row(line)
    ---@type { start: number, last: number, value: number }[]
    local num_list = {}
    local symbol_list = {}
    local current = 0
    while current < #line do
        local start, last = line:find("%d+", current)
        if start and last then
            table.insert(num_list, { start = start, last = last, value = tonumber(line:sub(start, last)) })
            current = last + 1
        else
            current = #line
        end
    end

    current = 0

    while current < #line do
        local x = line:find("[^.%d]", current)
        if x then
            table.insert(symbol_list, {x = x, value = line:sub(x,x)})
            current = x + 1
        else
            current = #line
        end
    end

    return { num_list = num_list, symbol_list = symbol_list }
end

assert.same({ num_list = { { start = 1, last = 3, value = 467 }, { start = 6, last = 8, value = 114 } }, symbol_list = {} },
    parse_row('467..114..'))

assert.same({ num_list = {}, symbol_list = {{ x = 4, value = "*" }} }, parse_row('...*......'))

assert.same({
    num_list = { {
        last = 4,
        start = 3,
        value = 35
    }, {
        last = 9,
        start = 7,
        value = 633
    } },
    symbol_list = {}
}, parse_row('..35..633.'))

assert.same({ num_list={}, symbol_list={{x=4, value="$"}, {x=6, value="*"}}}, parse_row("...$.*...."))

local game = {}
while true do
    ---@type string
    local line = io.read("*l")
    if line == nil then break end

    table.insert(game, parse_row(line))
end

local function is_not_nil(v)
    return v ~= nil
end

local function concat(t_list)
    local result = {}
    for _, t in ipairs(t_list) do
        for _, v in ipairs(t) do
            table.insert(result, v)
        end
    end
    return result
end

function part_1(game)
    local part_num_list = {}
    for i, row in ipairs(game) do
        local symbol_list = row.symbol_list
        for _, symbol in ipairs(symbol_list) do
            local up = game[i - 1].num_list
            local current = game[i].num_list
            local down = game[i + 1].num_list

            for _, num in ipairs(concat({up, current, down}))  do
                if symbol.x-1 <= num.last and num.start <= symbol.x+1 then
                    table.insert(part_num_list, num)
                end
            end
        end
    end

    return f.iter(part_num_list):map(function (num)
        return num.value
    end):sum()
end

function part_2(game)
    local gear_list = f.enumerate(game):map(function (i, row)
        return f.iter(row.symbol_list):filter(function (symbol)
            return symbol.value == "*"
        end):map(function (symbol)
            local up = game[i - 1].num_list
            local current = game[i].num_list
            local down = game[i + 1].num_list

            local part_num_list = f.chain(up, current, down):filter(function (num)
                return symbol.x-1 <= num.last and num.start <= symbol.x+1
            end):totable()

            if #part_num_list == 2 then
                return {a=part_num_list[1].value, b=part_num_list[2].value}
            end
            return nil
        end):filter(is_not_nil)
    end):totable()

    return f.chain(unpack(gear_list)):map(function (gear) return gear.a * gear.b end):sum()
end

print(part_1(game))
print(part_2(game))
