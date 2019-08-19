local process_share_map = {}

---! 升级成功
process_share_map[4] = function(player, share_type, share_args)
    if player:get_grade() ~= share_args then
        return
    end

    local level_config = LEVEL_CONFIG:get_config_by_level(share_args)
    if not level_config then
        return
    end

    if level_config.doubleshare ~= 1 then
        return
    end

    if not player:can_grade_share(share_args) then
        return
    end

    ---! 记录当前等级已分享
    player:set_grade_share(share_args)

    ---! 返回分享获得的奖励
    return config.level_reward
end

---! 炮倍升级成功
process_share_map[5] = function(player, share_type, share_args)
    if player:get_max_gunrate() ~= share_args then
        return
    end

    local cannon_config = CANNON_CONFIG:get_config_by_gunrate(share_args)
    if not cannon_config then
        return
    end

    if not player:can_gunrate_share(share_args) then
        return
    end

    ---! 记录当前等级已分享
    player:set_gunrate_share(share_args)

    ---! 返回分享获得的奖励
    return cannon_config.share_reward
end

---! 新手任务分享
process_share_map[9] = function(player, share_type, share_args)
    if player:get_last_task_id() ~= share_args then
        return
    end

    local task_config = NEW_TASK_CONFIG:get_config_by_id(share_args)
    if not task_config then
        return
    end

    if #task_config.share_reward <= 0 then
        return
    end

    if not player:can_new_task_share(share_args) then
        return
    end

    ---! 记录当前等级已分享
    player:set_new_task_share(share_args)

    ---! 返回分享获得的奖励
    return task_config.share_reward
end

---! 观看有礼广告分享
process_share_map[32] = function(player, share_type, share_args)
    local ad_config = AD_CONFIG:get_config_by_times(player:get_share_count(share_type) + 1)
    if not ad_config then
        return
    end

    ---! 返回分享获得的奖励
    return ad_config.reward_props
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SHARE_D = {}

function SHARE_D:process_share(player, share_type, share_args)
    local share_config = SHARE_CONFIG:get_config_by_type(share_type)
    if not share_config then
        local result = {}
        result.errorCode = -1
        result.shareType = share_type
        result.shareArgs = share_args
        result.newShareInfo = player:get_share_info()
        player:send_packet("MSGS2CCommonShare", result)
        return
    end

    if player:get_share_count(share_type) >= share_config.awardnum then
        local result = {}
        result.errorCode = -1
        result.shareType = share_type
        result.shareArgs = share_args
        result.newShareInfo = player:get_share_info()
        player:send_packet("MSGS2CCommonShare", result)
        return
    end

    local share_func = process_share_map[share_type]
    local rewards = share_func and share_func(player, share_type, share_args) or share_config.reward
    if not rewards or table.len(rewards) <= 0 then
        local result = {}
        result.errorCode = -1
        result.shareType = share_type
        result.shareArgs = share_args
        result.newShareInfo = player:get_share_info()
        player:send_packet("MSGS2CCommonShare", result)
        return
    end

    ---! 累加分享次数
    player:add_share_count(share_type)

    ---! 发放分享奖励
    local props, senior_props = ITEM_D:give_user_props(player, rewards, PropChangeType.kPropChangeTypeShare)

    local result = {}
    result.errorCode = 0
    result.shareType = share_type
    result.shareArgs = share_args
    result.newShareInfo = player:get_share_info()
    player:send_packet("MSGS2CCommonShare", result)

    if #props > 0 or #senior_props > 0 then
        ---! 广播其他玩家
        local result = {}
        result.playerId = player:get_id()
        result.source = "MSGS2CCommonShare"
        result.dropProps = props
        result.dropSeniorProps = senior_props
        player:brocast_packet("MSGS2CUpdatePlayerProp", result)
    end
end
