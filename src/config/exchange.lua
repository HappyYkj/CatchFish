local tbl = CONFIG_D:get_table("exchange")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id - 860000000      -- 索引
    config.name = row.name              -- VIP兑换物品名称

    -- 兑换物品
    config.reward = {}
    if row.reward ~= "" then
        local tbl = {}
        local fields = split(row.reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.reward = tbl
        end
    end

    -- 所需物品
    config.need_item = {}
    if row.need_item ~= "" then
        local tbl = {}
        local fields = split(row.need_item, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.need_item = tbl
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
EXCHANGE_CONFIG = {}

function EXCHANGE_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end

function EXCHANGE_CONFIG:get_configs()
    return configs
end
