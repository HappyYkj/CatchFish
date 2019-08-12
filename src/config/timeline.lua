local tbl = CONFIG_D:get_table("timeline")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id          -- 索引
    config.frame = row.frame    -- 帧号
    config.pathid = row.pathid  -- 轨迹
    config.fishid = row.fishid  -- 鱼种id
    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

TIMELINE_CONFIG = {}

function TIMELINE_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end

function TIMELINE_CONFIG:get_timeline_index(id)
    local config = configs[id]
    if not config then
        return
    end
    return math.floor(id / 1000) % 10
end
