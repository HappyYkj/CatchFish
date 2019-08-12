local tbl = CONFIG_D:get_table("iron")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do repeat
    local fish = tonumber(row.fish)
    local iron = tonumber(row.iron)

    local map = { iron = iron }
    for i, v in pairs(row) do repeat
        if not i then
            break
        end

        if i == "id" or i == "fish" or i == "iron" then
            break
        end

        map[tonumber(i)] = tonumber(v)
    until true end

    if not configs[fish] then
        configs[fish] = {}
    end

    configs[fish][#configs[fish] + 1] = map
until true end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

IRON_CONFIG = {}

function IRON_CONFIG:get_true_fish_id(fish, room)
    local config = configs[fish]
    if not config then
        return fish
    end

    local sum = 0
    for idx, _ in ipairs(config) do
        if config[idx][room] then
            sum = sum + config[idx][room]
        end
    end

    if sum > 0 then
        local rnd = math.random(sum)
        for idx, _ in ipairs(config) do
            if config[idx][room] then
                if rnd < config[idx][room] then
                    return config[idx].iron
                end
                rnd = rnd - config[idx][room]
            end
        end
    end

    return fish
end
