local tbl = CONFIG_D:get_table("skill")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.skillId = row.id             -- 索引
    config.itemId = row.item_need       -- 消耗的道具id
    config.duration = row.duration      -- 持续时间
    config.cool_down = row.cool_down    -- 冷却时间
    config.unlock_vip = row.unlock_vip  -- VIP解锁等级
    configs[config.itemId] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

SKILL_CONFIG = {}

function SKILL_CONFIG:get_config_by_itemid(itemid)
    local config = configs[itemid]
    if not config then
        return
    end

    return config
end

function SKILL_CONFIG:get_skill_id(itemid)
    local config = configs[itemid]
    if not config then
        return 0
    end

    return config.skillId
end
