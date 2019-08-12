local tbl = CONFIG_D:get_table("fisharray")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id              -- 索引
    config.frame = row.frame        -- 帧号
    config.trace = row.trace        -- 轨迹
    config.fishid = row.fishid      -- 鱼种id
    config.offsetx = row.offsetx    -- 偏移x
    config.offsety = row.offsety    -- 偏移y
    config.arrId = math.floor(config.id / 1000) - 310000
    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FISH_ARRAY_CONFIG = {}

function FISH_ARRAY_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end
