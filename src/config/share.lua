local tbl = CONFIG_D:get_table("share")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.type = row.type          -- 索引, 房间类型Id
    config.awardnum = row.awardnum  -- 每日分享奖励次数

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

    configs[config.type] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

SHARE_CONFIG = {}

function SHARE_CONFIG:get_config_by_type(type)
    local config = configs[type]
    if not config then
        return
    end

    return config
end
