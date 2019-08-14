local tbl = CONFIG_D:get_table("bomb")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.item_id = row.item_id            -- 物品ID
    config.cannon_data = row.cannon_data    -- 炮倍参数
    config.data = row.data                  -- 库值
    config.one_gold = row.one_gold          -- 单发最大金额（鱼币）
    configs[config.item_id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
BOMB_CONFIG = {}

function BOMB_CONFIG:get_config_by_id(item_id)
    local config = configs[item_id]
    if not config then
        return
    end

    return config
end
