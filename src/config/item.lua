local tbl = CONFIG_D:get_table("item")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id
    config.name = row.name                                      -- 物品名称
    config.itemtype = row.itemtype                              -- 物品类型
    config.num_perbuy = row.num_perbuy                          -- 每次加减的数量
    config.require_num = row.require_num                        -- 购买本道具需要持有水晶的最低数
    config.inner_value = row.inner_value                        -- 内置价值
    config.can_buy = row.can_buy                                -- 可否能够购买
    config.require_vip = row.require_vip                        -- 购买所需VIP等级
    config.use_outlook = row.use_outlook                        -- 使用的炮台外观
    config.taste_time = row.taste_time                          -- 体验时间
    config.need_cannon = row.need_cannon                        -- 解锁所需炮倍
    config.if_senior = row.if_senior

    -- 购买单价
    config.price_type, config.price_value = 0, 0
    if row.price ~= "" then
        local fields = string.split(row.price, ";")
        if #fields == 2 then
            config.price_type, config.price_value = tonumber(fields[1]), tonumber(fields[2])
        end
    end

    -- 出售价值
    config.sell_type, config.sell_value = 0, 0
    if row.sell_value ~= "" then
        local fields = string.split(row.sell_value, ";")
        if #fields == 2 then
            config.sell_type, config.sell_value = tonumber(fields[1]), tonumber(fields[2])
        end
    end

    configs[config.id - 200000000] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ITEM_CONFIG = {}

function ITEM_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end
