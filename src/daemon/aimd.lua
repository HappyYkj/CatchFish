-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
AIM_D = {}

---! 开启瞄准锁定鱼
function AIM_D:start_aim_fish(player, duration, skill_plus)
    ---! 计算效果加成
    local duration = 1.0 * duration * skill_plus / 100

    ---! 计算结束时间
    local end_time = os.mtime() + 1.0 * duration * skill_plus / 100 * 1000

    ---! 记录结束时间
    player:set_temp("aim", "end_time", end_time)
end

---! 是否处于瞄准状态
function AIM_D:is_on_aim_fish(player)
    local end_time = player:query_temp("aim", "end_time")
    if not end_time then
        return false
    end

    if end_time < os.mtime() then
        return false
    end

    return true
end

---! 开启瞄准状态
function AIM_D:start_aim(player, use_type, fishArrayId, timelineId)
    local item_config = ITEM_CONFIG:get_config_by_id(GamePropIds.kGamePropIdsAim)
    if not item_config then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        player:send_packet("MSGS2CAimResult", result)
        return
    end

    local skill_config = SKILL_CONFIG:get_config_by_itemid(GamePropIds.kGamePropIdsAim)
    if not skill_config then
        local result = {}
        result.isSuccess = false
        result.useType = use_type
        player:send_packet("MSGS2CAimResult", result)
        return
    end

    if use_type == 0 then
        -- 使用道具
        if player:get_prop_count(GamePropIds.kGamePropIdsAim) < 1 then
            -- 道具不足，失败
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CAimResult", result)
            return
        end
    else
        -- 使用水晶
        if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) < item_config.price_value then
            -- 水晶不足，失败
            local result = {}
            result.isSuccess = false
            result.useType = use_type
            player:send_packet("MSGS2CAimResult", result)
            return
        end
    end

    if use_type == 0 then
        -- 扣除道具
        player:change_prop_count(GamePropIds.kGamePropIdsAim, -1, PropRecieveType.kPropChangeTypeUseProp)
    else
        -- 扣除水晶
        player:change_prop_count(GamePropIds.kGamePropIdsCrystal, -item_config.price_value, PropRecieveType.kPropChangeTypeFreezeWithCrystal)
    end

    ---! 获取瞄准加成
    local skill_plus = VIP_CONFIG:get_aim_skill_plus(player:get_vip_exp())

    ---! 设置瞄准状态
    player:start_aim_fish(skill_config.duration, skill_plus)

    ---! 更新使用技能任务
    TASK_D:update_use_skill_task(player, skill_config)

    ---! 获取当前水晶
    local new_crystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)

    ---! 使用成功
    local result = {}
    result.isSuccess = true
    result.useType = use_type
    result.skillPlus = skill_plus
    result.newCrystal = new_crystal
    player:send_packet("MSGS2CAimResult", result)

    ---! 广播消息
    local result = {}
    result.useType = use_type
    result.fishArrayId = fishArrayId
    result.timelineId = timelineId
    result.newCrystal = new_crystal
    result.playerId = player:get_id()
    player:brocast_packet("MSGS2CAim", result)
end
