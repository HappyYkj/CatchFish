local M = {}

---! 获取vip等级
function M:get_vip_grade()
    local config = VIP_CONFIG:get_config_by_vip_exp(self:get_vip_exp())
    if not config then
        return 0
    end
    return config.vip_level
end

---! 获取vip经验
function M:get_vip_exp()
    return self:query("vip", "vipExp") or 0
end

---! 设置vip经验
function M:set_vip_exp(exp)
    self:set("vip", "vipExp", exp)
end

---! 累加VIP经验
function M:add_vip_exp(exp)
    self:set("vip", "vipExp", self:get_vip_exp() + exp)
end

---! 获取礼包标识
function M:get_gift_sign()
    return self:query("vip", "giftSign") or 0
end

---! 设置礼包标识
function M:set_gift_sign(sign)
    self:set("vip", "giftSign", sign)
end

---! 设置vip鱼币补足是否已经使用
function M:set_vip_coin_recruit_used()
    return self:query("vip", "vipCoinRecruitUsed") or 0
end

---! 获取vip鱼币补足是否已经使用
function M:get_vip_coin_recruit_used(vipCoinRecruitUsed)
    self:set("vip", "vipCoinRecruitUsed", vipCoinRecruitUsed)
end

F_CHAR_VIP = M
