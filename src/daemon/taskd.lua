local ENUM_TASK_TYPE = {
    GET_FISHICON        = 1,    -- 杀鱼获得鱼币
    KILL_FISH           = 2,    -- 捕获任意鱼
    GET_CRYSTAL         = 3,    -- 杀鱼获得水晶
    UPGRADE_CANNON      = 4,    -- 升级炮倍
    USE_SKILL           = 5,    -- 使用技能
    KILL_REWARD_FISH    = 6,    -- 捕获奖金鱼
}

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
TASK_D = {}

---! 发送新手任务信息
function TASK_D:send_task_info(player)
    local task_id = player:get_task_id()
    local config = NEW_TASK_CONFIG:get_config_by_id(task_id)
    if not config then
        return
    end

    ---! 发送新手任务信息
    if ENUM_TASK_TYPE.UPGRADE_CANNON == config.task_type then
        ---! 炮倍升级任务
        local result = {}
        result.nTaskID = task_id
        result.nTaskData = player:get_max_gunrate()
        result.isSuccess = true
        player:send_packet("MSGS2CGetNewTaskInfo", result)
        return
    end

    ---! 普通计数任务
    local result = {}
    result.nTaskID = task_id
    result.nTaskData = player:get_task_count()
    result.isSuccess = true
    player:send_packet("MSGS2CGetNewTaskInfo", result)
end

---! 更新杀鱼任务
function TASK_D:update_kill_fish_task(player, fishes)
    if #fishes <= 0 then
        return
    end

    if player:get_desk_grade() ~= 1 then
        return
    end

    local config = NEW_TASK_CONFIG:get_config_by_id(player:get_task_id())
    if not config then
        return
    end

    if config.task_type ~= ENUM_TASK_TYPE.KILL_FISH and config.task_type ~= ENUM_TASK_TYPE.KILL_REWARD_FISH then
        return
    end

    if player:get_task_count() >= config.task_data then
        return
    end

    if config.task_type == ENUM_TASK_TYPE.KILL_FISH then
        ---! 累加杀鱼计数
        player:add_task_count(#fishes)

        ---! 刷新杀鱼任务
        TASK_D:send_task_info(player)
    else
        local count = 0
        for _, fish in ipairs(fishes) do repeat
            local fish_type = FISH_CONFIG:get_config_by_id(fish.fishId)
            if not fish_type then
                break
            end

            if fish_type:isRewardFish() then
                count = count + 1
            end
        until true end

        if count > 0 then
            ---! 累加杀鱼计数
            player:add_task_count(count)

            ---! 刷新杀鱼任务
            TASK_D:send_task_info(player)
        end
    end
end

---! 更新技能使用任务
function TASK_D:update_use_skill_task(player, skill_id)
    if player:get_desk_grade() ~= 1 then
        return
    end

    local config = NEW_TASK_CONFIG:get_config_by_id(player:get_task_id())
    if not config then
        return
    end

    if config.task_type ~= ENUM_TASK_TYPE.USE_SKILL then
        return
    end

    if config.task_data2 ~= skill_id then
        return
    end

    if player:get_task_count() >= config.task_data then
        return
    end

    ---! 累加任务计数
    player:add_task_count(1)

    ---! 刷新使用技能任务
    TASK_D:send_task_info(player)
end

---! 更新升级炮倍任务
function TASK_D:update_gunrate_task(player)
    if player:get_desk_grade() ~= 1 then
        return
    end

    local config = NEW_TASK_CONFIG:get_config_by_id(player:get_task_id())
    if not config then
        return
    end

    if config.task_type ~= ENUM_TASK_TYPE.UPGRADE_CANNON then
        return
    end

    if player:get_task_count() >= config.task_data then
        return
    end

    ---! 更新任务计数
    player:set_task_count(player:get_max_gunrate())

    ---! 刷新升级炮倍任务
    TASK_D:send_task_info(player)
end

---! 通过重置完成新手任务
function TASK_D:finish_task_by_rechage(player)
    local rewards = {}
    while true do
        local task_id = player:get_task_id()
        local config = NEW_TASK_CONFIG:get_config_by_id(task_id)
        if not config then
            break
        end

        ---! 更新新手任务
        player:next_task_data()

        for prop_id, prop_count in pairs(config.reward) do
            if not rewards[prop_id] then
                rewards[prop_id] = prop_count
            else
                rewards[prop_id] = rewards[prop_id] + prop_count
            end
        end
    end

    ---! 为玩家升级炮倍至少100倍
    local props = CANNON_D:upgrade_gunrate_finish_task(player, 100)
    if props then
        for _, prop in ipairs(props) do
            local prop_id = prop.propId
            local prop_count = prop.propCount
            if not rewards[prop_id] then
                rewards[prop_id] = prop_count
            else
                rewards[prop_id] = rewards[prop_id] + prop_count
            end
        end
    end

    ---! 发放任务奖励
    local props, senior_props = ITEM_D:give_user_props(player, rewards, PropChangeType.kPropChangeTypeNewTaskReward)

    ---! 刷新新手任务
    TASK_D:send_task_info(player)

    ---! 发送奖励消息
    local result = {}
    result.playerId = player:get_id()
    result.gunRate = player:get_max_gunrate()
    result.playerProp = {}
    result.playerProp.playerId = player:get_id()
    result.playerProp.source = "MSGS2CFinishNewTask"
    result.playerProp.dropProps = props
    result.playerProp.dropSeniorProps = senior_props
    player:brocast_packet("MSGS2CFinishNewTask", result)
end

---! 领取新手任务奖励
function TASK_D:get_task_reward(player)
    local config = NEW_TASK_CONFIG:get_config_by_id(player:get_task_id())
    if not config then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CGetNewTaskReward", result)
        return
    end

    if player:get_task_count() < config.task_data then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CGetNewTaskReward", result)
        return
    end

    ---! 更新新手任务
    player:next_task_data()

    ---! 发放任务奖励
    local props, senior_props = ITEM_D:give_user_props(player, config.reward, PropChangeType.kPropChangeTypeNewTaskReward)

    ---! 广播消息
    local result = {}
    result.isSuccess = true
    result.playerID = player:get_id()
    result.props = props
    result.SeniorProps = senior_props
    player:brocast_packet("MSGS2CGetNewTaskReward", result)

    ---! 刷新新手任务
    TASK_D:send_task_info(player)
end
