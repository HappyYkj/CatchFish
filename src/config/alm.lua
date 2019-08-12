local tbl = CONFIG_D:get_table("alms")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id                                  -- 索引
    config.alms_vip_level = row.alms_vip_level          -- VIP等级
    config.alms_gun_level = row.alms_gun_level          -- 炮倍分隔值（最大炮倍在值以下服务器计算救济金值）
    config.alms_gun_multiply = row.alms_gun_multiply    -- 奖励乘数（服务器计算乘数*最大炮倍）

    -- 领取间隔CD
    config.alms_cd_array = {}
    if row.alms_cd_array ~= "" then
        local tbl = {}
        local fields = split(row.alms_cd_array, ";")
        for i = 1, #fields, 1 do
            tbl[i] = tonumber(fields[i])
        end

        if table.len(tbl) > 0 then
            config.alms_cd_array = tbl
        end
    end

    -- 奖励信息
    config.alms_reward_array = {}
    if row.alms_reward_array ~= "" then
        local tbl = {}
        local fields = split(row.alms_reward_array, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[#tbl + 1] = { [tonumber(key)] = tonumber(val) }
            end
        end

        if table.len(tbl) > 0 then
            config.alms_reward_array = tbl
        end
    end

    configs[config.alms_vip_level] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ALM_CONFIG = {}

function ALM_CONFIG:get_config_by_vip_level(vip_level)
    local config = configs[vip_level]
    if not config then
        return
    end
    return config
end
