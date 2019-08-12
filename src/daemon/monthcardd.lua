local function get_today_time()
    local ti = os.date("*t")
    ti.hour = 0
    ti.min = 0
    ti.sec = 0
    return os.time(ti)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
MONTHCARD_D = {}

---! 月卡炮台，是否在月卡期限内
function MONTHCARD_D:is_use_remain_cannon(player, gunType)
    if gunType == 30 and player:get_monthcard_left_days() > 0 then
        ---! 月卡炮台，且在月卡期限内
        return true
    end

    for _, itemProp in pairs(player:get_senior_props()) do repeat
        local config = ITEM_CONFIG:get_config_by_id(itemProp.propId)
        if not config then
            break
        end

        if gunType ~= config.use_outlook then
            break
        end

        if config.taste_time > 0 and itemProp.intProp1 < os.time() then
            ---! 限时炮台，且不在使用期限内
            break
        end

        return true
    until true end
    return false
end

---! 获取剩余月卡天数
function MONTHCARD_D:get_monthcard_left_days(player)
    local today_time = get_today_time()
    local expired_time = player:query("monthCard", "expiredTime") or 0
    if expired_time < today_time then
        ---! 之前的月卡已过期
        return 0
    end

    return math.ceil(1.0 * (expired_time - today_time) / 86400)
end

---! 设置月卡剩余天数
function MONTHCARD_D:set_monthcard_left_days(player, days)
    --- 默认设置剩余天数为30天
    days = days or 30
    if days <= 0 then
        ---! 视为月卡已过期
        player:delete("monthCard", "expiredTime")
        return
    end

    local today_time = get_today_time()
    local expired_time = player:query("monthCard", "expiredTime") or 0
    if expired_time < today_time then
        ---! 之前月卡已过期
        expired_time = today_time
    end

    ---! 累加月卡剩余时间
    player:set("monthCard", "expiredTime", expired_time + days * 86400)
end

---! 获取是否已经领取月卡奖励
function MONTHCARD_D:get_monthcard_reward_token(player)
    local today_time = get_today_time()
    local reward_time = player:query("monthCard", "rewardTime") or 0
    if reward_time < today_time then
        return false
    end
    return true
end

---! 设置是否已经领取月卡奖励
function MONTHCARD_D:set_monthcard_reward_token(player)
    player:set("monthCard", "rewardTime", os.time())
end
