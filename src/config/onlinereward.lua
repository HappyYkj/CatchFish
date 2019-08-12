local tbl = CONFIG_D:get_table("onlinereward")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id          -- 索引
    config.time = row.time      -- 在线时长间隔
    config.num = row.num        -- 奖励次数
    config.rate = row.rate      -- 最小炮倍
    
    -- 奖励
    config.reward = {}
    if row.reward ~= "" then
        local tbl = {}
        local fields = split(row.reward, ";")
        for i = 1, #fields, 4 do
            local propId, min, max, weight = fields[i], fields[i + 1], fields[i + 2], fields[i + 3]
            if propId and min and max and weight then
                tbl[#tbl + 1] = {
                    propId = tonumber(propId),
                    min = tonumber(min),
                    max = tonumber(max),
                    weight = tonumber(weight),
                }
            end
        end

        if table.len(tbl) > 0 then
            config.reward = tbl
        end
    end

    local tbl = configs[config.num] or {}
    tbl[#tbl + 1] = config
    configs[config.num] = tbl
end

for num, _ in ipairs(configs) do
    table.sort(configs[num], function(config1, config2)
        return config1.rate < config2.rate 
    end)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

ONLINE_REWARD_CONFIG = {}

---! 获取奖励最大次数
function ONLINE_REWARD_CONFIG:get_reward_max_times(gunrate)
    return #configs
end

---! 获取奖励
function ONLINE_REWARD_CONFIG:get_reward_item(gunrate, times)
    if not configs[times] then
        return
    end

    local reward = {}
    for _, config in pairs(configs[times]) do
        if gunrate < config.rate then
            break
        end

        reward = config.reward
    end
    
    local sum = 0
    for _, val in pairs(reward) do
        sum = sum + val.weight
    end
    
    if sum > 0 then
        local rnd = math.random(sum)
        for _, val in pairs(reward) do
            if rnd < val.weight then
                return val.propId, math.random(val.min, val.max)
            end
            rnd = rnd - val.weight
        end
    end
end

---! 获取奖励所需时长
function ONLINE_REWARD_CONFIG:get_reward_need_time(gunrate, times)
    if not configs[times] then
        return
    end
    
    local time
    for _, config in pairs(configs[times]) do
        if gunrate < config.rate then
            break
        end

        time = config.time
    end
    return time
end
