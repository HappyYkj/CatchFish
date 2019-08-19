-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
VIOLENT_D = {}

---! 初始狂暴状态
function VIOLENT_D:init_violent(player)
    local config = SKILL_CONFIG:get_config_by_itemid(GamePropIds.kGamePropIdsViolent)
    if not config then
        return
    end

    ---! 获取起始时间
    local start_time = os.time()

    ---! 计算结束时间
    local end_time = start_time + config.duration

    ---! 设置狂暴信息
    player:set_temp("violent", {
        ratio = 4,                  ---! 狂暴系数
        start_time = start_time,    ---! 起始时间
        end_time = end_time,        ---! 结束时间
    })
end

---! 清除狂暴状态
function VIOLENT_D:clear_violent(player)
    player:delete_temp("violent")
end

---! 判断是否处于狂暴状态
function VIOLENT_D:is_on_violent(player)
    ---! 获取当前时间
    local now_time = os.time()

    ---! 获取狂暴开始时间
    local start_time = player:query_temp("violent", "start_time")
    if not start_time or start_time > now_time then
        return false
    end

    ---! 获取狂暴结束时间
    local end_time = player:query_temp("violent", "end_time")
    if not end_time or end_time <= now_time then
        return false
    end

    return true
end

---! 获取当前狂暴倍率
function VIOLENT_D:get_violent_ratio(player)
    if player:is_on_violent() then
        return player:query_temp("violent", "ratio") or 1
    end
    return 1
end

---! 获取当前狂暴倍率
function VIOLENT_D:get_violent_multiply(gunrate, ratio)
    local multiply
    if ratio == 2 then
        if gunrate <= 80 then
            multiply = 250
        elseif gunrate <= 150 then
            multiply = 200
        elseif gunrate <= 700 then
            multiply = math.random(170,200)
        elseif gunrate <= 3000 then
            multiply = math.random(150,200)
        else
            multiply = math.random(150,200)
        end
    elseif ratio == 4 then
        if gunrate <= 80 then
            multiply = 500
        elseif gunrate <= 150 then
            multiply = 400
        elseif gunrate <= 700 then
            multiply = math.random(340,400)
        elseif gunrate <= 3000 then
            multiply = math.random(300,400)
        else
            multiply = math.random(300,400)
        end
    else
        multiply = 100
    end
    return multiply / 100
end

---! 开启狂暴状态
function VIOLENT_D:start_violent(player, use_type)
    local item_config = ITEM_CONFIG:get_config_by_id(GamePropIds.kGamePropIdsViolent)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        player:send_packet("MSGS2CViolent", result)
        return
    end

    ---! 判断所需消耗是否满足条件
    if use_type == 0 then
        ---! 通过消耗道具的方式
        if player:get_prop_count(GamePropIds.kGamePropIdsViolent) < 1 then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CViolent", result)
            return
        end
    else
        ---! 通过消耗水晶的方式
        if player:get_max_gunrate() < item_config.need_cannon then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CViolent", result)
            return
        end

        if player:get_vip_grade() < item_config.require_vip then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CViolent", result)
            return
        end

        if player:get_prop_count(item_config.price_type) < item_config.price_value then
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CViolent", result)
            return
        end
    end

    ---! 扣除对应消耗
    if use_type == 0 then
        ---! 通过消耗道具的方式
        player:change_prop_count(GamePropIds.kGamePropIdsViolent, -1, PropChangeType.kPropChangeTypeUseProp)
    else
        ---! 通过消耗水晶的方式
        player:change_prop_count(item_config.price_type, -item_config.price_value, PropChangeType.kPropChangeTypeViolentWithCrystal)
    end

    ---! 初始狂暴状态
    player:init_violent()

    ---! 广播消息
    local result = {}
    result.isSuccess = true
    result.useType = use_type
    result.playerID = player:get_id()
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    player:brocast_packet("MSGS2CViolent", result)
end

---! 设置狂暴状态
function VIOLENT_D:set_violent(player, ratio)
    local end_time = player:query_temp("violent", "end_time")
    if not end_time or os.time() >= end_time then
        ---! 当前不在狂暴状态
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CSetViolentRatio", result)
        return
    end

    if ratio ~= 2 and ratio ~= 4 then
        ---! 错误的狂暴倍率
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CSetViolentRatio", result)
        return
    end

    ---! 修改狂暴系数
    player:set_temp("violent", "ratio", ratio)

    ---! 发送消息
    local result = {}
    result.isSuccess = true
    result.nRatio = ratio
    player:send_packet("MSGS2CSetViolentRatio", result)
end
