---! 映射表
local clients_map = {}

local function kickout(clientAddr, clientId, reason)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
LOGIN_D = {}

---! 登录
function LOGIN_D:login(loginTime, clientAddr, clientId, loginInfo)
    local user_id = loginInfo.PlayerID
    if not user_id then
        spdlog.warn("logind", string.format("member[PlayerID] type error, data : %s", loginInfo));
        return
    end

    spdlog.debug("logind", string.format("client [%s] from [%s] try do login user [%s].", clientId, clientAddr, user_id))

    ---! 查找用户对象
    local user_ob = USER_D:find_user(user_id)
    if not user_ob then
        ---! 对象尚未加载，需要做防重入处理，避免多次加载对象
        if USER_D:is_loading(user_id) then
            spdlog.debug("logind", string.format("user [%s] is loading....", user_id))

            ---! 通知客户端下线
            kickout(clientAddr, clientId, 1001)
            return
        end

        ---! 开始加载对象
        user_ob = USER_D:load_user(user_id)
        if not user_ob then
            spdlog.debug("logind", string.format("user [%s] load failed.", user_id))

            ---! 通知客户端下线
            kickout(clientAddr, clientId, 1002)
            return
        end

        ---! 初始玩家数据
        USER_D:init_user(user_ob)

        ---! 更新角色数据
        user_ob:update_data()

        ---! 安排进入游戏
        USER_D:enter_world(user_ob)

        ---! 设置登录信息
        user_ob:set_temp("clientAddr",   clientAddr)
        user_ob:set_temp("clientId",     clientId)
        user_ob:set_temp("loginInfo",    loginInfo)
        user_ob:set_temp("loginTime",    loginTime)
    else
        local last_client_id = user_ob:query_temp("clientId")
        if last_client_id and last_client_id ~= clientId then
            ---! 断开之前连接
            USER_D:disconnect(user_ob)
        end

        ---! 设置登录信息
        user_ob:set_temp("clientAddr",   clientAddr)
        user_ob:set_temp("clientId",     clientId)
        user_ob:set_temp("loginInfo",    loginInfo)
        user_ob:set_temp("loginTime",    loginTime)

        ---! 重新进入游戏
        USER_D:reconnect(user_ob)
    end

    ---! 记录登录成功的玩家对象
    clients_map[clientId] = user_ob

    ---! 发送道具信息
    ITEM_D:send_item_info(user_ob)

    ---! 发送大厅信息
    USER_D:send_hall_info(user_ob)

    ----todo: post_enter_world
    do
        ---! 七日礼包签到
        local result = {}
        result.isSuccess = true
        result.newSignInDays = user_ob:get_days()
        result.sign = user_ob:get_sign()
        user_ob:send_packet("MSGS2CSignIn", result)

        ---! VIP礼包签到
        local result = {}
        result.attrs = { { attrKey = 4, attrValue = user_ob:get_gift_sign(), } }
        user_ob:send_packet("MSGS2CNotifyPlayerAttrs", result)

        ---! 在线奖励领取
        ONLINE_REWARD_D:update_online_reward_data(user_ob)

        ---! 每日分享
        local result = {}
        result.errorCode = 0
        result.newShareInfo = user_ob:get_share_info()
        user_ob:send_packet("MSGS2CCommonShare", result)

        ---! 拉取未处理的订单
        CHARGE_D:request_incomplete_order(user_ob:get_id())
    end

    ---! 记录当前指令处理时间
    user_ob:set_temp("command_time", os.time())
end

---!
function LOGIN_D:logout(user_ob)
    local clientId = user_ob:query_temp("clientId")
    if clientId then
        spdlog.debug("logind", string.format("client [%s] disconnect.", clientId))

        ---! 断开当前连接
        USER_D:disconnect(user_ob)

        ---! 清理关联映射
        user_ob:delete_temp("loginTime")
        user_ob:delete_temp("loginInfo")
        user_ob:delete_temp("clientId")
        user_ob:delete_temp("clientAddr")
        clients_map[clientId] = nil
    end

    ---! 安排离开游戏
    -- USER_D:leave_world(user_ob)
end

---!
function LOGIN_D:find_user(clientId)
    return clients_map[clientId]
end
