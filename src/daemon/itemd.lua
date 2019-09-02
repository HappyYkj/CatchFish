local table_insert = assert(table.insert)

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local function log_prop_changed(player, prop_id, offset, reason)
    local prop_changed = player:query_temp("log_prop_changed_cache", prop_id, reason)
    if prop_changed and prop_changed.timer_id then
        if player:get_desk_grade() == prop_changed.desk_grade then
            prop_changed.offset = prop_changed.offset + offset
            prop_changed.update_time = os.date("%Y-%m-%d %H:%M:%S")
            return
        end

        ---! 取消之前定时器
        TIMER_D:cancel_timer(prop_changed.timer_id)

        ---! 立即保存缓存日志
        LOG_D:write_item_log{
            player_id = player:get_id(),
            prop_id = prop_changed.prop_id,
            prop_count = player:get_prop_count(prop_changed.prop_id),
            offset = prop_changed.offset,
            reason = prop_changed.reason,
            update_time = prop_changed.update_time,
            desk_grade = prop_changed.desk_grade,
        }
    end

    ---! 启动新的定时器
    local timer_id = TIMER_D:start_timer(15, 1, function()
        local prop_changed = player:query_temp("log_prop_changed_cache", prop_id, reason)
        if not prop_changed then
            return
        end

        ---! 清理当前缓存信息
        player:delete_temp("log_prop_changed_cache", prop_id, reason)

        ---! 立即保存缓存日志
        LOG_D:write_item_log{
            player_id = player:get_id(),
            prop_id = prop_changed.prop_id,
            prop_count = player:get_prop_count(prop_changed.prop_id),
            offset = prop_changed.offset,
            reason = prop_changed.reason,
            update_time = prop_changed.update_time,
            desk_grade = prop_changed.desk_grade,
        }
    end)

    player:set_temp("log_prop_changed_cache", prop_id, reason, {
        prop_id = prop_id,
        offset = offset,
        reason = reason,
        timer_id = timer_id,
        update_time = os.date("%Y-%m-%d %H:%M:%S"),
        desk_grade = player:get_desk_grade(),
    })
end

local function log_senior_prop_changed(player, prop, offset, reason)
    LOG_D:write_item_log{
        player_id = player:get_id(),
        prop_id = prop.propId,
        prop_count = player:get_senior_prop_count(prop_id),
        offset = offset,
        reason = reason,
        update_time = os.date("%Y-%m-%d %H:%M:%S"),
        desk_grade = player:get_desk_grade(),
        memo = string.format("intProp1:%s,intProp2:%s,stringProp:%s", prop.intProp1, prop.intProp2, prop.stringProp)
    }
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ITEM_D = {}

function ITEM_D:send_item_info(player)
    local props = {}
    for _, prop in pairs(player:get_props()) do
        table_insert(props, prop)
    end

    local seniorProps = {}
    for _, seniorProp in pairs(player:get_senior_props()) do
        table_insert(seniorProps, seniorProp)
    end

    local result = {}
    result.props = props
    result.seniorProps = seniorProps
    player:send_packet("MSGS2CPropInfo", result)
end

---! 获取道具数量
function ITEM_D:get_prop_count(player, prop_id)
    for _, prop in pairs(player:get_props()) do
        if prop.propId == prop_id then
            return prop.propCount
        end
    end
    return 0
end

---! 修改道具数量
function ITEM_D:change_prop_count(player, prop_id, offset, reason)
    local props = player:get_props()
    for _, prop in pairs(props) do
        if prop.propId == prop_id then
            prop.propCount = prop.propCount + offset
            log_prop_changed(player, prop_id, offset, reason)
            return
        end
    end

    table_insert(props, { propId = prop_id, propCount = offset, })
    log_prop_changed(player, prop_id, offset, reason)
end

---! 获取高级道具数量
function ITEM_D:get_senior_prop_count(player, prop_id)
    local prop_count = 0
    for _, prop in pairs(player:get_senior_props()) do
        if prop.propId == prop_id then
            prop_count = prop_count + 1
        end
    end
    return prop_count
end

---! 增加高级道具
-- propId:道具类型id
-- stringProp:字符串属性
-- intProp1:数字属性1
-- intProp2:数字属性2
function ITEM_D:add_senior_prop(player, prop_id, str_prop, int_prop1, int_prop2)
    local prop_item_id = player:query_temp("maxSeniorPropId") or 0
    local prop_item_id = prop_item_id + 1

    local prop = {}
    prop.propId = prop_id
    prop.stringProp = str_prop or ""
    prop.intProp1 = int_prop1 or 0
    prop.intProp2 = int_prop2 or 0
    prop.propItemId = prop_item_id
    player:set_temp("item", "seniorProps", prop_item_id, prop)
    player:set_temp("maxSeniorPropId", prop_item_id)

    log_senior_prop_changed(player, prop, 1, reason)
    return prop
end

---! 快速添加高级道具，在内部会对不同道具id做特定处理
function ITEM_D:add_senior_prop_quick(player, prop_id)
    -- 明日礼包
    if prop_id == GamePropIds.kGamePropIdsTomorrowGift then
        return player:add_senior_prop(prop_id, "", os.time())
    end

    -- 新手礼包
    if prop_id == GamePropIds.kGamePropIdsNewbieGift then
        return player:add_senior_prop(prop_id, "", os.time())
    end

    -- 限时炮台
    local config = assert(ITEM_CONFIG:get_config_by_id(prop_id))
    if config.itemtype == 1 and config.taste_time > 0 then
        return player:add_senior_prop(prop_id, "", os.time() + config.taste_time)
    end

    -- buff类道具
    if config.itemtype == 3 and config.taste_time > 0 then
        local prop = player:get_senior_prop_by_id(prop_id)
        if not prop then
            return player:add_senior_prop(prop_id, "", os.time() + config.taste_time)
        end
        prop.intProp1 = prop.intProp1 + config.taste_time
        return prop
    end

    -- 其他道具
    return player:add_senior_prop(prop_id)
end

---! 删除高级道具
function ITEM_D:erase_senior_prop(player, prop_item_id)
    local prop = player:query_temp("item", "seniorProps")
    if not prop then
        return
    end

    player:delete_temp("item", "seniorProps", prop_item_id)

    log_senior_prop_changed(player, prop, -1, reason)
    return prop
end

---! 获取是否由某一类的高级道具
function ITEM_D:get_senior_prop_by_id(player, prop_id)
    for _, prop in pairs(player:get_senior_props()) do
        if prop.propId == prop_id then
            return prop
        end
    end
end

function ITEM_D:get_props(player)
    local props = player:query_temp("item", "props")
    if not props then
        props = player:set_temp("item", "props", {})
    end
    return props
end

function ITEM_D:get_senior_props(player)
    local props = player:query_temp("item", "seniorProps")
    if not props then
        props = player:set_temp("item", "seniorProps", {})
    end
    return props
end

function ITEM_D:init_user_props(player)
    ---! 初始鱼币
    player:change_prop_count(GamePropIds.kGamePropIdsFishIcon, FISH_SERVER_CONFIG.initFishicon)

    ---! 初始水晶
    player:change_prop_count(GamePropIds.kGamePropIdsCrystal, FISH_SERVER_CONFIG.initCrystal)

    ---! 初始启航礼包
    player:add_senior_prop_quick(GamePropIds.kGamePropIdsNewbieGift)

    ---! 初始明日礼包
    player:add_senior_prop_quick(GamePropIds.kGamePropIdsTomorrowGift)
end

function ITEM_D:load_user_props(player, item_dbase)
    if type(item_dbase) ~= "table" then
        return
    end

    if type(item_dbase.props) == "table" then
        player:set_temp("item", "props", item_dbase.props)
    end

    if type(item_dbase.seniorProps) == "table" then
        player:set_temp("maxSeniorPropId", #item_dbase.seniorProps)
        for prop_item_id, prop in ipairs(item_dbase.seniorProps) do
            prop.propItemId = prop_item_id
            player:set_temp("item", "seniorProps", prop_item_id, prop)
        end
    end
end

function ITEM_D:save_user_props(player)
    local item_data = {}

    local item_dbase = player:query_temp("item")
    if not item_dbase then
        return item_data
    end

    if type(item_dbase.props) == "table" then
        item_data.props = table.values(item_dbase.props)
    end

    if type(item_dbase.seniorProps) == "table" then
        item_data.seniorProps = table.values(item_dbase.seniorProps)
    end

    return item_data
end

---! 给予玩家道具
-- player: 玩家对象
-- prop_map: { 道具ID : 道具数量, 道具ID : 道具数量, ... }
-- reason: 原因
function ITEM_D:give_user_props(player, prop_map, reason)
    local props, senior_props = {}, {}
    for prop_id, prop_count in pairs(prop_map) do repeat
        local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
        if not item_config then
            break
        end

        if prop_count <= 0 then
            break
        end

        if item_config.if_senior == 0 then
            player:change_prop_count(prop_id, prop_count, reason)
            table_insert(props, { propId = prop_id, propCount = prop_count, })
            break
        end

        for idx = 1, prop_count do
            table_insert(senior_props, player:add_senior_prop_quick(prop_id))
        end
    until true end
    return props, senior_props
end
