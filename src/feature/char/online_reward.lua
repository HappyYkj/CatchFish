local M = {}

---! 更新在线奖励数据
function M:update_online_reward_data()
    return ONLINE_REWARD_D:update_online_reward_data(self)
end

---! 清理在线奖励数据
function M:clear_online_reward_data()
    return ONLINE_REWARD_D:clear_online_reward_data(self)
end

---! 获取当前在线时长
function M:get_online_time()
    return self:query("onlineReward", "onlineTime") or 0
end

---! 获取当前所需时长
function M:get_need_time()
    return self:query("onlineReward", "needTime") or 0
end

---! 获取在线奖励次数
function M:get_reward_count()
    return self:query("onlineReward", "rewardCnt") or 0
end

---! 累加在线奖励次数
function M:add_reward_count()
    self:set("onlineReward", "rewardCnt", self:get_reward_count() + 1)
end

---! 获取可获得的道具Id
function M:get_reward_prop_id()
    return self:query("onlineReward", "rewardPropId") or 0
end

---! 获取可获得道具数量
function M:get_reward_prop_count()
    return self:query("onlineReward", "rewardPropCount") or 0
end

---! 获取可获得的道具奖励
function M:get_reward_desc()
    return string.format("%d,%d", self:get_reward_prop_id(), self:get_reward_prop_count())
end

F_CHAR_ONLINE_REWARD = M
