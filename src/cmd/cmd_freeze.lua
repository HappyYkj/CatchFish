local function main (userOb, msgData)
    local itemConfig = ITEM_CONFIG:get_config_by_id(GamePropIds.kGamePropIdsFreeze)
    if not itemConfig then
        local result = {}
        result.isSuccess = false
        result.useType = msgData.useType
        userOb:send_packet("MSGS2CFreezeResult", result)
        return        
    end

    ---! 悬赏任务中，禁止冰冻
    ----todo:
    if false then
        local result = {}
        result.isSuccess = false
        result.useType = msgData.useType
        userOb:send_packet("MSGS2CFreezeResult", result)
        return    
    end

    if msgData.useType == 0 then
        -- 使用道具
        if userOb:get_prop_count(GamePropIds.kGamePropIdsFreeze) < 1 then
            -- 道具不足，失败
            local result = {}
            result.isSuccess = false
            result.useType = msgData.useType
            userOb:send_packet("MSGS2CFreezeResult", result)
            return
        end

        -- 扣除道具
        userOb:change_prop_count(GamePropIds.kGamePropIdsFreeze, -1, PropRecieveType.kPropChangeTypeUseProp)
    else
        -- 使用水晶
        if userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal) < itemConfig.price_value then
            -- 水晶不足，失败
            local result = {}
            result.isSuccess = false
            result.useType = msgData.useType
            userOb:send_packet("MSGS2CFreezeResult", result)
            return
        end

        -- 扣除水晶
        userOb:change_prop_count(GamePropIds.kGamePropIdsCrystal, -itemConfig.price_value, PropRecieveType.kPropChangeTypeFreezeWithCrystal)
    end

    ---! 设置冰冻状态
    userOb:get_desk():begin_freeze(userOb)

    ---! 更新使用技能任务
    TASK_D:update_use_skill_task(userOb, SKILL_CONFIG:get_skill_id(GamePropIds.kGamePropIdsFreeze))

    ---! 使用成功
    local result = {}
    result.isSuccess = true
    result.useType = msgData.useType
    result.newCrystal = userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    userOb:send_packet("MSGS2CFreezeResult", result)
end

COMMAND_D:register_command("MSGC2SFreezeStart", GameCmdType.DESK, main)
