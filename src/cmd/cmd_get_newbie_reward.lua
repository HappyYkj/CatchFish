local function main (userOb, msgData)
    local level_config = LEVEL_CONFIG:get_config_by_level(1)
    if not level_config then
        -- 奖励配置已丢失
        local result = {}
        result.errorCode = -1
        userOb:send_packet("MSGS2CGetNewerReward", result)
        return
    end

    ---! 是否有启航礼包
    local senior_prop = userOb:get_senior_prop_by_id(GamePropIds.kGamePropIdsNewbieGift)
    if not senior_prop then
        local result = {}
        result.errorCode = -1
        userOb:send_packet("MSGS2CGetNewerReward", result)
        return
    end

    ---! 删除启航礼包
    userOb:erase_senior_prop(senior_prop.propItemId)

    ---! 给予礼包奖励
    local props = ITEM_D:give_user_props(userOb, level_config.level_reward, PropChangeType.kPropChangeTypeNewerReward)

    ---! 广播消息
    local result = {}
    result.errorCode = 0
    result.props = props
    userOb:send_packet("MSGS2CGetNewerReward", result)
end

COMMAND_D:register_command("MSGC2SGetNewerReward", GameCmdType.HALL, main)
