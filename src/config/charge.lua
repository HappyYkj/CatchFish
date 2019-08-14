local tbl = CONFIG_D:get_table("newrecharge")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id              -- 索引
    config.recharge = row.recharge  -- 充值额度

    -- 奖励道具
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

    -- 赠送道具
    config.reward_gift = {}
    if row.reward_gift ~= "" then
        local tbl = {}
        local fields = split(row.reward_gift, ";")
        for i = 1, #fields, 2 do
            local key, val = fields[i], fields[i + 1]
            if key and val then
                tbl[tonumber(key)] = tonumber(val)
            end
        end

        if table.len(tbl) > 0 then
            config.reward_gift = tbl
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CHARGE_CONFIG = {}

function CHARGE_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end
