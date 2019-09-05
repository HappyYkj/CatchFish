local tbl = CONFIG_D:get_table("gif")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id - 830000000  -- 索引
    config.goods = row.goods        -- 平台标识

    -- 获得奖励
    config.reward = {}
    if row.reward ~= "" then
        local tbl = {}
        local fields = string.split(row.reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.size(tbl) > 0 then
            config.reward = tbl
        end
    end

    -- 分享获得奖励
    config.share_reward = {}
    if row.share_reward ~= "" then
        local tbl = {}
        local fields = string.split(row.share_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.size(tbl) > 0 then
            config.share_reward = tbl
        end
    end

    -- 炮倍限制
    config.minGunRate, config.maxGunRate = 0, 0
    if row.cannon_limit ~= "" then
        local fields = string.split(row.share_reward, ";")
        if #fields == 2 then
            config.minGunRate, config.maxGunRate = tonumber(fields[1]), tonumber(fields[2])
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

GIFT_CONFIG = {}

---! 获取礼包配置
function GIFT_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end

---! 根据平台标识获取礼包
function GIFT_CONFIG:get_id_by_goods(goods)
    for id, config in pairs(configs) do
        if config.goods == goods then
            return id
        end
    end
end

---! 根据平台标识获取礼包配置
function GIFT_CONFIG:get_config_by_goods(goods)
    for id, config in pairs(configs) do
        if config.goods == goods then
            return config
        end
    end
end

---! 是否是有效炮倍
function GIFT_CONFIG:is_gunrate_validate(goods, gunRate)
    for id, config in pairs(configs) do repeat
        if config.goods ~= goods then
            break
        end

        if config.minGunRate < 0 then
            return false
        end

        if gunRate >= config.minGunRate and gunRate <= config.maxGunRate then
            return true
        end
    until true end
    return false
end
