local tbl = CONFIG_D:get_table("freefishcoin")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do repeat
    if row.type ~= 11 then
        break
    end

    local config = {}
    config.id = row.id                  -- 索引
    config.days = row.time_parameter    -- 天数
    config.share = row.if_share         -- 是否可分享
    config.vip = row.if_vip             -- 是否vip额外奖励

    -- 奖励道具
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

    -- VIP额外奖励道具
    config.vip_props = {}
    if row.vip_props ~= "" then
        local tbl = {}
        local fields = split(row.vip_props, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.vip_props = tbl
        end
    end

    -- 分享奖励道具
    config.share_props = {}
    if row.share_props ~= "" then
        local tbl = {}
        local fields = split(row.share_props, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.share_props = tbl
        end
    end

    -- VIP分享奖励道具
    config.share_vip_props = {}
    if row.share_vip_props ~= "" then
        local tbl = {}
        local fields = split(row.share_vip_props, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.share_vip_props = tbl
        end
    end

    configs[config.days] = config
until true end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CHECKIN_CONFIG = {}

function CHECKIN_CONFIG:get_config_by_day(days)
    local config = configs[days]
    if not config then
        return
    end

    return config
end
