local tbl = CONFIG_D:get_table("item")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id
    config.num_perbuy = row.num_perbuy
    config.require_num = row.require_num
    config.inner_value = row.inner_value
    config.can_buy = row.can_buy
    config.require_vip = row.require_vip
    config.use_outlook = row.use_outlook
    config.taste_time = row.taste_time
    config.if_senior = row.if_senior ~= 0 and true or false
    config.name = row.name
    config.unit_post = row.unit_post
    config.itemtype = row.itemtype
    config.need_cannon = row.need_cannon
    config.convert_post = row.convert_post

    if config.convert_post <= 0 then
        config.convert_post = 1
    end
    
    config.price_type, config.price_value = 0, 0
    if row.price ~= "" then
        local fields = split(row.price, ";")
        if #fields == 2 then
            config.price_type, config.price_value = tonumber(fields[1]), tonumber(fields[2])
        end
    end
    
    config.sell_type, config.sell_value = 0, 0
    if row.sell_value ~= "" then
        local fields = split(row.price, ";")
        if #fields == 2 then
            config.sell_type, config.sell_value = tonumber(fields[1]), tonumber(fields[2])
        end
    end
    
    configs[config.id - 200000000] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

ITEM_CONFIG = {}

function ITEM_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end

    return config
end

function ITEM_CONFIG:get_price_by_itemid(id)
    local config = self:get_config_by_id(id)
    if not config then
        return 10000000
    end

    return config.price_value
end

function ITEM_CONFIG:is_senior_prop(id)
    local config = self:get_config_by_id(id)
    if not config then
        return false
    end

    return config.if_senior
end
