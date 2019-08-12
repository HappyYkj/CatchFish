local tbl = CONFIG_D:get_table("freefishcoin")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do repeat
    if row.type ~= 10 then
        break
    end

    local config = {}
    config.id = row.id                  -- 索引
    config.times = row.time_parameter   -- 次数

    -- 签到奖励
    config.reward_props = {}
    if row.reward_props ~= "" then
        local tbl = {}
        local fields = split(row.reward_props, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.reward_props = tbl
        end
    end

    configs[config.times] = config
until true end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

AD_CONFIG = {}

function AD_CONFIG:get_config_by_times(times)
    local config = configs[times]
    if not config then
        return
    end

    return config
end
