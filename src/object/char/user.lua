USER_OB = class("USER_OB")
USER_OB:inherit(F_COMN_DBASE)
USER_OB:inherit(F_CHAR_COMM)
USER_OB:inherit(F_CHAR_AIM)
USER_OB:inherit(F_CHAR_ALM)
USER_OB:inherit(F_CHAR_VIP)
USER_OB:inherit(F_CHAR_SAVE)
USER_OB:inherit(F_CHAR_DESK)
USER_OB:inherit(F_CHAR_ITEM)
USER_OB:inherit(F_CHAR_LEVEL)
USER_OB:inherit(F_CHAR_SHARE)
USER_OB:inherit(F_CHAR_MATCH)
USER_OB:inherit(F_CHAR_UPDATE)
USER_OB:inherit(F_CHAR_CANNON)
USER_OB:inherit(F_CHAR_VIOLENT)
USER_OB:inherit(F_CHAR_LIBRARY)
USER_OB:inherit(F_CHAR_CHECKIN)
USER_OB:inherit(F_CHAR_FISHDRAW)
USER_OB:inherit(F_CHAR_MONTHCARD)
USER_OB:inherit(F_CHAR_BUY_HISTORY)
USER_OB:inherit(F_CHAR_NEWBIE_TASK)
USER_OB:inherit(F_CHAR_ONLINE_REWARD)
USER_OB:inherit(F_CHAR_CYCLE_DATA)

function USER_OB:set_id(user_id)
    self:set_temp("userId", user_id)
end

function USER_OB:get_id()
    return self:query_temp("userId")
end

function USER_OB:get_nick_name()
    return self:query_temp("loginInfo", "nickName") or tostring(self:get_id())
end

function USER_OB:generate_player_info()
    local data = {}
    data.playerId = self:query_temp("userId")
    data.fishIcon = self:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    data.crystal = self:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    data.gradeExp = self:get_grade_experience()
    data.vipExp = self:get_vip_exp()
    data.useGunType = self:get_guntype()
    data.maxGunRate = self:get_max_gunrate()
    data.curGunRate = self:get_cur_gunrate()
    data.leftMonthCardDay = self:get_monthcard_left_days()
    data.monthCardRewardToken = self:get_monthcard_reward_token()
    data.nickName = self:get_nick_name()
    data.headFrame = 0
    data.deskId = self:get_desk_id()
    data.chairId = self:get_chair_id()
    return data
end

-------------------------------------------------------------------------------
---!
-------------------------------------------------------------------------------

---! 更新上次射击时间
function USER_OB:update_shoot_time()
    self:set_temp("lastShootTime", os.time())
end

---! 获取上次射击时间
function USER_OB:get_shoot_time()
    return self:query_temp("lastShootTime") or 0
end
