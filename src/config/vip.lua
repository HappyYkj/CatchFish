local tbl = CONFIG_D:get_table("vip")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id
    config.cannon_type = row.cannon_type
    config.money_need = row.money_need
    config.extra_sign = row.extra_sign
    config.vip_level = row.vip_level
    config.checkin_rate = row.checkin_rate
    config.daily_charge_gold = row.daily_charge_gold

    config.skill_plus = {}
    if row.skill_plus ~= "" then
        local tbl = {}
        local fields = split(row.skill_plus, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.skill_plus = tbl
        end
    end
    
    config.daily_items_reward = {}
    if row.daily_items_reward ~= "" then
        local tbl = {}
        local fields = split(row.daily_items_reward, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.daily_items_reward = tbl
        end
    end
    
    config.bonusPoints = {}
    if row.bonusPoints ~= "" then
        local tbl = {}
        local fields = split(row.bonusPoints, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.bonusPoints = tbl
        end
    end
    
    config.freeGameTimes = {}
    if row.freeGameTimes ~= "" then
        local tbl = {}
        local fields = split(row.freeGameTimes, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.freeGameTimes = tbl
        end
    end
    
    config.vipGift = {}
    if row.vipGift ~= "" then
        local tbl = {}
        local fields = split(row.vipGift, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.vipGift = tbl
        end
    end

    configs[config.vip_level] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

VIP_CONFIG = {}

function VIP_CONFIG:get_config_by_vip_level(vip_level)
    local config = configs[vip_level]
    if not config then
        return
    end

    return config
end

function VIP_CONFIG:get_config_by_vip_exp(vip_exp)
    local keys = table.keys(configs)
    table.sort(keys, function (a, b) return a > b end)

    for _, key in ipairs(keys) do
        local config = configs[key]
        if config.money_need <= vip_exp then
            return config
        end
    end
end

function VIP_CONFIG:get_freeze_skill_plus(vip_exp)
    local config = self:get_config_by_vip_exp(vip_exp)
    if not config then
        return 100
    end

    return config.skill_plus[1] or 100
end

function VIP_CONFIG:get_aim_skill_plus(vip_exp)
    local config = self:get_config_by_vip_exp(vip_exp)
    if not config then
        return 100
    end

    return config.skill_plus[2] or 100
end

function VIP_CONFIG:get_free_game_times(vip_exp, id)
    local config = self:get_config_by_vip_exp(vip_exp)
    if not config then
        return 0
    end

    return config.freeGameTimes[id] or 0
end

function VIP_CONFIG:get_bonus_points(vip_exp, id)
    local config = self:get_config_by_vip_exp(vip_exp)
    if not config then
        return 0
    end

    return config.bonusPoints[id] or 0
end
