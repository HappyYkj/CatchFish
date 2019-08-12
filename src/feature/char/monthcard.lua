local M = {}

---! 获取剩余月卡天数
function M:get_monthcard_left_days()
    return MONTHCARD_D:get_monthcard_left_days(self)
end

---! 设置月卡剩余天数
function M:set_monthcard_left_days(days)
    return MONTHCARD_D:set_monthcard_left_days(self, days)
end

---! 获取是否已经领取月卡奖励
function M:get_monthcard_reward_token()
    return MONTHCARD_D:get_monthcard_reward_token(self)
end

---! 设置是否已经领取月卡奖励
function M:set_monthcard_reward_token()
    return MONTHCARD_D:set_monthcard_reward_token(self)
end

F_CHAR_MONTHCARD = M
