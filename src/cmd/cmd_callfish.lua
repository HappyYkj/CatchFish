local function main (userOb, msgData)
    ---!获取可见的召唤鱼
    local callfishes = userOb:get_desk():get_visable_callfishes()

    ---! 召唤鱼个数大于配置的最大个数
    if #callfishes >= CALLFISH_CONFIG:get_callfish_max_count(userOb:get_desk_grade()) then
        local result = {}
        result.isSuccess = false
        result.useType = msgData.useType
        result.failType = CallFishFailType.kCallFishFailTypeFishIsFull
        userOb:send_packet("MSGS2CCallFish", result)
        return
    end

    ---! 直接使用道具
    if msgData.useType == 0 then
        if userOb:get_prop_count(GamePropIds.kGamePropIdsCallFish) <= 0 then
            -- 道具不足，返回失败
            local result = {}
            result.isSuccess = false
            result.useType = msgData.useType
            userOb:send_packet("MSGS2CCallFish", result)
            return
        end
    ---! 使用水晶
    else
        if userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal) < ITEM_CONFIG:get_price_by_itemid(GamePropIds.kGamePropIdsCallFish) then
            -- 水晶不足，返回失败
            local result = {}
            result.isSuccess = false
            result.useType = msgData.useType
            userOb:send_packet("MSGS2CCallFish", result)
            return
        end
    end 

    ---! 获取玩家的会员等级
    local vip_grade = userOb:get_vip_grade()

    ---! 根据vip等级获取召唤出来的鱼类型
    local fishId = CALLFISH_CONFIG:get_callfish_id(vip_grade)

    ---! 获取鱼的类型信息
    local fish_type = FISH_CONFIG:get_config_by_id(fishId)
    if not fish_type then
        local result = {}
        result.isSuccess = false
        result.useType = msgData.useType
        userOb:send_packet("MSGS2CCallFish", result)
        return
    end
    
    if msgData.useType == 0 then
        -- 扣除道具
        userOb:change_prop_count(GamePropIds.kGamePropIdsCallFish, -1, PropRecieveType.kPropChangeTypeUseProp)
    else
        -- 扣除水晶
        local price = ITEM_CONFIG:get_price_by_itemid(GamePropIds.kGamePropIdsCallFish)
        userOb:change_prop_count(GamePropIds.kGamePropIdsCrystal, -price, PropRecieveType.kPropChangeTypeNBombWithCallFish)
    end

    ---! 通过配置，随机获取召唤鱼的路径Id
    local pathId = CALLFISH_CONFIG:get_callfish_path(vip_grade)

    ---! 获取当前游戏帧数
    local frameCount = userOb:get_desk():get_frame_count()

    ---! 将对象加入召唤鱼
    userOb:get_desk():add_callfish(userOb:get_id(), pathId, fishId, frameCount, msgData.callFishId)

    ---! 更新使用技能任务
    TASK_D:update_use_skill_task(userOb, SKILL_CONFIG:get_skill_id(GamePropIds.kGamePropIdsCallFish))

    local result = {}
    result.isSuccess = true
    result.useType = msgData.useType
    result.callFishId = msgData.callFishId
    result.fishId = fishId
    result.pathId = pathId
    result.playerId = userOb:get_id()
    result.newCrystal = userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.frameId = frameCount
    userOb:brocast_packet("MSGS2CCallFish", result)
end

COMMAND_D:register_command("MSGC2SCallFish", GameCmdType.DESK, main)
