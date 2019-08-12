local tbl = CONFIG_D:get_table("skilldrop")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id
    config.cannon_times1 = row.cannon_times1
    config.cannon_times2 = row.cannon_times2
    config.diamond_cost = row.diamond_cost
    config.call_cost = row.call_cost
    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

SKILL_DROP_CONFIG = {}

function SKILL_DROP_CONFIG:get_diamond_cost_by_cannon_times(cannon_times)
    for _, config in pairs(configs) do
        if cannon_times >= config.cannon_times1 and cannon_times <= config.cannon_times2 then
            return math.floor(1.0 * config.diamond_cost / 10000);
        end
    end
    return 0
end

function SKILL_DROP_CONFIG:get_callfish_drop_rate_by_cannon_times(cannon_times)
    for _, config in pairs(configs) do
        if cannon_times >= config.cannon_times1 and cannon_times <= config.cannon_times2 then
            return math.floor(1.0 * config.call_cost / 10000);
        end
    end
    return 0
end
