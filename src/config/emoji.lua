local tbl = CONFIG_D:get_table("emoji")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id
    config.crystal_need = row.crystal_need
    config.unlock_vip = row.unlock_vip
    configs[config.id - 400000000] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
EMOJI_CONFIG = {}

function EMOJI_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end
