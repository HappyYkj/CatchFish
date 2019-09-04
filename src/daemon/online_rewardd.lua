-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ONLINE_REWARD_D = {}

---! 更新在线奖励数据
function ONLINE_REWARD_D:update_online_reward_data(player)
    ---! 获取当前时间
    local now = os.time()

    ---! 获取上次更新时间
    local update_time = player:query("onlineReward", "updateTime")
    if not update_time then
        ---! 记录更新时间
        player:set("onlineReward", "updateTime", now)
    else
        ---! 计算间隔时间
        local duration = now - update_time

        ---! 记录更新时间
        player:set("onlineReward", "updateTime", now)

        ---! 更新在线时长
        if duration > 0 then
            player:set("onlineReward", "onlineTime", player:get_online_time() + duration)
        end
    end

    ---! 更新奖励信息
    local prop_id = player:query("onlineReward", "rewardPropId") or 0
    if prop_id <= 0 then
        ---! 获取最大炮倍
        local gunrate = player:get_max_gunrate()

        ---! 获取下一奖励
        local reward_count = player:get_reward_count() + 1
        local prop_id, prop_count = ONLINE_REWARD_CONFIG:get_reward_item(gunrate, reward_count)
        if not prop_id or not prop_count then
            return
        end

        local need_time = ONLINE_REWARD_CONFIG:get_reward_need_time(gunrate, reward_count)
        if not need_time then
            return
        end

        ---! 设置当前等待所需时长
        player:set("onlineReward", "needTime", need_time)

        ---! 设置奖励道具Id及数量
        player:set("onlineReward", "rewardPropId", prop_id)
        player:set("onlineReward", "rewardPropCount", prop_count)
    end

    if not player:query_temp("clientId") then
        player:delete("onlineReward", "updateTime")
    end
end

---! 清理在线奖励数据
function ONLINE_REWARD_D:clear_online_reward_data(player)
    player:delete("onlineReward", "needTime")
    player:delete("onlineReward", "onlineTime")
    player:delete("onlineReward", "rewardCnt")
    player:delete("onlineReward", "rewardPropId")
    player:delete("onlineReward", "rewardPropCount")
end

---! 发送在线奖励数据
function ONLINE_REWARD_D:send_online_reward_data(player)
    local reward_count = player:get_reward_count()
    local max_times = ONLINE_REWARD_CONFIG:get_reward_max_times()
    if reward_count >= max_times then
        ---! 已达领取上限，不处理
        return
    end

    ---! 更新在线奖励数据
    player:update_online_reward_data()

    ---! 通知可获得的奖励信息
    local result = {}
    result.onlineTime = player:get_online_time()
    result.needTime = player:get_need_time()
    result.isLastOne = (reward_count + 1 >= max_times) and 1 or 0
    player:send_packet("MSGS2CNotifyOnlineRewardDatas", result)

    ---! 通知可获得的奖励信息
    local result = {}
    result.rewards = player:get_reward_desc()
    player:send_packet("MSGS2CResponseOnlineReward", result)
end

---! 请求领取在线奖励道具
function ONLINE_REWARD_D:get_online_reward(player)
    local reward_count = player:get_reward_count()
    local max_times = ONLINE_REWARD_CONFIG:get_reward_max_times()
    if reward_count >= max_times then
        ---! 已达领取上限，不处理
        return
    end

    ---! 更新在线奖励数据
    player:update_online_reward_data()

    if player:get_need_time() > player:get_online_time() then
        ---! 在线时间未符合要求
        ONLINE_REWARD_D:send_online_reward_data(player)
        return
    end

    ---! 获取奖励道具信息
    local prop_id = player:get_reward_prop_id()
    local prop_count = player:get_reward_prop_count()

    ---! 清理奖励相关数据
    ONLINE_REWARD_D:clear_online_reward_data(player)

    ---! 获取奖励物品配置
    local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
    if not item_config then
        ---! 奖励道具信息出现异常
        ONLINE_REWARD_D:send_online_reward_data(player)
        return
    end

    ---! 累加奖励领取次数
    player:add_reward_count()

    ---! 发放当前奖励物品
    local props, senior_props = ITEM_D:give_user_props(player, { [prop_id] = prop_count, }, PropChangeType.kPropChangeTypeOnlineReward)

    ---! 广播给奖励信息
    local result = {}
    result.playerId = player:get_id()
    result.dropProps = props
    result.dropSeniorProps = senior_props
    player:brocast_packet("MSGS2CResponeGetOnlineReward", result)

    ---! 更新下次奖励信息
    ONLINE_REWARD_D:send_online_reward_data(player)
end
