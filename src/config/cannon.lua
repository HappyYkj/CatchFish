local tbl = CONFIG_D:get_table("cannon")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id                      -- 索引
    config.gunRate = row.times              -- 炮倍
    config.unlock_gem = row.unlock_gem      -- 解锁所需水晶
    config.unlock_award = row.unlock_award  -- 解锁返还金币
    config.unlock_prob = row.unlock_prob    -- 解锁成功率(百分比)
    config.succ_need = row.succ_need        -- 锻造必成辅助材料数量

    -- 解锁消耗物品
    config.unlock_item = {}
    if row.unlock_item ~= "" then
        local tbl = {}
        local fields = split(row.unlock_item, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.unlock_item = tbl
        end
    end

    -- 分享获得奖励
    config.share_reward = {}
    if row.share_reward ~= "" then
        local tbl = {}
        local fields = split(row.share_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.share_reward = tbl
        end
    end

    -- 阶段获得奖励
    config.phaseReward = {}
    if row.phaseReward ~= "" then
        local tbl = {}
        local fields = split(row.phaseReward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.phaseReward = tbl
        end
    end

    configs[#configs + 1] = config
end

table.sort(configs, function(config1, config2)
    return config1.gunRate < config2.gunRate
end)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CANNON_CONFIG = {}

function CANNON_CONFIG:get_config_by_gunrate(gunRate)
    for _, config in ipairs(configs) do
        if config.gunRate == gunRate then
            return config
        end
    end
end

---! 获取取整的炮倍
function CANNON_CONFIG:get_integer_gunrate(gunRate)
    for _, config in ipairs(configs) do
        if config.gunRate >= gunRate then
            return config.gunRate
        end
    end

    local config = configs[#configs]
    if config then
        return config.gunRate
    end
end

function CANNON_CONFIG:get_next_gunrate(gunRate)
    for _, config in ipairs(configs) do
        if gunRate < config.gunRate then
            return config.gunRate
        end
    end
end

function CANNON_CONFIG:get_config_id_by_gunrate(gunRate)
    local config = self:get_config_by_gunrate(gunRate)
    if not config then
        return 0
    end

    return config.id
end
