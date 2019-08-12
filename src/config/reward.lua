local tbl = CONFIG_D:get_table("reward")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id - 940000000                  -- 索引
    config.limit = row.limit or 0                   -- 抽奖触发金额
    config.minFishTicket = row.minFishTicket or 0   -- 最小鱼券限制
    config.minCrystal = row.minCrystal or 0         -- 最小水晶限制
    config.minLevel = row.minLv or 0                -- 最小等级限制
    
    -- 奖励
    if row.reward ~= "" then
        local tbl = {}
        local fields = split(row.reward, ";")
        for i = 1, #fields, 3 do
            local propId, count, percent = fields[i], fields[i + 1], fields[i + 2]
            if propId and count and percent then
                tbl[#tbl + 1] = {
                    propId = tonumber(propId),
                    count = tonumber(count),
                    percent = tonumber(percent),
                }
            end
        end

        if table.len(tbl) > 0 then
            config.reward = tbl
        end
    end
    
    -- 抽奖奖励备用配置
    if row.reward_1 ~= "" then
        local tbl = {}
        local fields = split(row.reward_1, ";")
        for i = 1, #fields, 3 do
            local propId, count, percent = fields[i], fields[i + 1], fields[i + 2]
            if propId and count and percent then
                tbl[#tbl + 1] = {
                    propId = tonumber(propId),
                    count = tonumber(count),
                    percent = tonumber(percent),
                }
            end
        end

        if table.len(tbl) > 0 then
            config.reward_1 = tbl
        end
    end

    configs[#configs + 1] = config
end

table.sort(configs, function(config1, config2)
    -- 触发条件
    if config1.limit > config2.limit then
        return true
    end
    
    if config1.limit < config2.limit then
        return false
    end
    
    -- 鱼券限制
    if config1.minFishTicket > config2.minFishTicket then
        return true
    end
    
    if config1.minFishTicket < config2.minFishTicket then
        return false
    end
    
    -- 水晶限制
    if config1.minCrystal > config2.minCrystal then
        return true
    end
    
    if config1.minCrystal < config2.minCrystal then
        return false
    end
    
    -- 等级限制
    return config1.minLevel > config2.minLevel
end)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

REWARD_CONFIG = {}

function REWARD_CONFIG:get_config_by_id(id)
    for _, config in ipairs(configs) do
        if config.id == id then
            return config
        end
    end
end

function REWARD_CONFIG:get_config_by_draw_rate(draw_rate, fishticket, crystal, grade)
    for _, config in ipairs(configs) do repeat
        -- 触发条件
        if config.limit >= 0 and config.limit > draw_rate then
            break
        end
        
        -- 鱼券限制
        if config.minFishTicket >= 0 and config.minFishTicket > fishticket then
            break
        end
        
        -- 水晶限制
        if config.minCrystal >= 0 and config.minCrystal > crystal then
            break
        end
        
        -- 等级限制
        if config.minLevel >= 0 and config.minLevel > grade then
            break
        end

        return config
    until true end
end

function REWARD_CONFIG:get_item_by_config(config)
    local sum = 0
    for _, item in ipairs(config.reward) do
        sum = sum + item.percent
    end

    if sum > 0 then
        local rnd = math.random(sum)
        for _, item in ipairs(config.reward) do
            if rnd < item.percent then
                return item.propId, item.count
            end
            rnd = rnd - item.percent 
        end
    end
end
