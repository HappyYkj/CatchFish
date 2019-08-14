local config = require "config"

---! 映射表
local load_map = {}     ---! 正在加载的玩家对象
local user_map = {}     ---! 已经加载的玩家对象
local temp_map = {}     ---! 临时缓存的玩家对象

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
local function _load_user(user_id)
    ---! 临时对象
    local user_ob = temp_map[user_id]
    if user_ob then
        return user_ob
    end

    ---! 创建对象
    local user_ob = USER_OB:create()

    ---! 设置Id
    user_ob:set_id(user_id)

    ---! 加载数据
    local ok = user_ob:load()
    if not ok then
        return
    end

    ---! 记录对象
    temp_map[user_id] = user_ob

    ---! 返回对象
    return user_ob
end

local function _check_user()
    ---! 获取当前时间
    local now_time = os.time()

    ---! 遍历在线玩家
    for _, user_ob in pairs(user_map) do
        local ok = pcall(function()
            local save_time = user_ob:query_temp("save_time")
            if not save_time then
                ---! 记录保存时间
                user_ob:set_temp("save_time", now_time)
                return
            end

            local cmd_time = user_ob:query_temp("command_time")
            if not cmd_time or now_time - cmd_time > 300 then
                ---! 断开玩家连接
                USER_D:disconnect(user_ob, 2)

                ---! 清理临时数据
                user_ob:delete_temp("save_time")
                user_ob:delete_temp("command_time")

                ---! 安排玩家下线
                USER_D:leave_world(user_ob)
                return
            end

            if now_time - save_time > 180 then
                ---! 保存玩家数据
                user_ob:save()
            end
        end)

        if not ok then
            spdlog.error("user", string.format("save user data failed, user = %s, data = %s", user_ob:get_id(), serialize(user_ob:query_entire_dbase())))
        end
    end

    ---! 遍历缓存玩家
    for user_id, user_ob in pairs(temp_map) do
        local ok = pcall(function()
            if USER_D:is_loading(user_id) then
                return
            end

            if USER_D:find_user(user_id) then
                return
            end

            local cached_time = user_ob:query_temp("cached_time")
            if not cached_time then
                return
            end

            if now_time < cached_time + 1800 then
                return
            end

            temp_map[user_id] = nil
        end)

        if not ok then
            spdlog.error("user", string.format("clean cached data failed, user = %s, data = %s", user_ob:get_id(), serialize(user_ob:query_entire_dbase())))
        end
    end

    spdlog.info("user", string.format("user_map size : %d, temp_map size : %d, load_map size : %d", table.len(user_map), table.len(temp_map), table.len(load_map)))
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
USER_D = {}

function USER_D:find_user(user_id)
    local user_ob = user_map[tonumber(user_id)]
    if user_ob then
        return user_ob
    end
end

---! 查找临时对象
function USER_D:find_temp_user(user_id)
    local user_ob = temp_map[tonumber(user_id)]
    if user_ob then
        return user_ob
    end
end

---! 查找或临时加载对象
function USER_D:find_load_user(user_id)
end

---! 判断是否正在加载
function USER_D:is_loading(user_id)
    return load_map[user_id] and true or false
end

---! 加载对象
function USER_D:load_user(user_id)
    user_id = tonumber(user_id)

    ---! 获取当前时间
    local now = os.mtime()

    ---! 设置加载状态
    load_map[user_id] = now

    ---! 开始加载对象
    spdlog.debug("userd", string.format("user [%s] start load ...", user_id))
    local user_ob = _load_user(user_id)
    spdlog.debug("userd", string.format("user [%s] load cost time = %s", user_id, os.mtime() - now))

    ---! 解除加载状态
    load_map[user_id] = nil

    ---! 返回对象
    return user_ob
end

---! 销毁对象
function USER_D:destroy_user(user_ob)
    local user_id = user_ob:get_id()
    user_map[user_id] = nil
    temp_map[user_id] = nil
end

---! 初始对象
function USER_D:init_user(user_ob)
    if user_ob:get_max_gunrate() > 0 then
        return
    end

    spdlog.info("user", string.format("init user [%s] data", user_ob:get_id()))

    ---! 设置初始炮倍
    user_ob:set_max_gunrate(1)
    user_ob:set_cur_gunrate(1)
    user_ob:set_guntype(1)

    ---! 设置初始补贴库值
    user_ob:set_allowance_rate(0)

    ---! 设置初始历史输赢库值
    user_ob:set_history_icon_drop_rate(FISH_SERVER_CONFIG.initHistoryIconDropValue)

    ---! 设置初始道具
    user_ob:init_item()

    ---! 设置新手任务
    user_ob:init_newbie_task()

    ---! 保存玩家数据
    user_ob:save()
end

---! 进入游戏
function USER_D:enter_world(user_ob)
    local user_id = user_ob:get_id()
    user_map[user_id] = user_ob
    spdlog.debug("userd", string.format("user [%s] enter world succ.", user_id))

    ---! 记录登录时间
    user_ob:set_temp("login_time", os.time())
end

---! 离开游戏
function USER_D:leave_world(user_ob)
    ----todo: 后期做延迟保存
    user_ob:save()

    local user_id = user_ob:get_id()
    user_map[user_id] = nil
    spdlog.debug("userd", string.format("user [%s] leave world succ.", user_id))

    ---! 记录缓存时间
    user_ob:set_temp("cached_time", os.time())
end

---! 重连游戏
function USER_D:reconnect(user_ob)
    local user_id = user_ob:get_id()
    spdlog.debug("userd", string.format("user [%s] reconnect world ...", user_id))

    local func = user_ob:query_temp("reconnect_callback")
    if func then
        func(user_ob)
    end
end

---! 断开游戏
function USER_D:disconnect(user_ob, reason)
    local user_id = user_ob:get_id()
    spdlog.debug("userd", string.format("user [%s] disconnect world ...", user_id))

    local func = user_ob:query_temp("disconnect_callback")
    if func then
        func(user_ob)
    end

    ---! 通知玩家离开游戏
    local result = {}
    result.reason = reason or 1
    user_ob:send_packet("MSGS2CLeaveGame", result)
end

---! 获取所有在线玩家
function USER_D:get_all_users()
    return user_map
end

---! 获取所有临时玩家
function USER_D:get_all_temp_users()
    return temp_map
end

---! 获取所有加载玩家
function USER_D:get_all_load_users()
    return load_map
end

---! 发送大厅消息
function USER_D:send_hall_info(user_ob)
    local result = {}
    result.playerInfo = user_ob:generate_player_info()
    result.serverTime = os.time()
    result.enableDebug = config.debug and true or false
    user_ob:send_packet("MSGS2CGetHallInfo", result)
end

---! 检测玩家升级
function USER_D:check_player_upgrade(player, fishicon, gunrate)
    if fishicon <= 0 then
        return
    end

    local old_grade = player:get_grade()
    if old_grade >= player:get_max_grade() then
        return
    end

    ---! 等级经验 = 鱼币*(炮倍 ^ (-0.5))
    local exp = math.floor(1.0 * fishicon * (gunrate ^ -0.5))
    spdlog.debug("upgrade", string.format("catch fish drop fishicon = %d, gunrate = %d, current_exp = %d, current_grade = %d, add_exp = %d",
                            fishicon, gunrate, player:get_grade_experience(), old_grade, exp))

    ---! 增加等级经验
    player:add_grade_experience(exp)

    local new_grade = player:get_grade()
    if new_grade <= old_grade then
        return
    end

    ---! 收集升级奖励
    local rewards = {}
    for grade = old_grade + 1, new_grade do repeat
        local config = LEVEL_CONFIG:get_config_by_level(grade)
        if not config then
            break
        end

        for prop_id, prop_count in pairs(config.level_reward) do
            if not rewards[prop_id] then
                rewards[prop_id] = prop_count
            else
                rewards[prop_id] = rewards[prop_id] + prop_count
            end
        end
    until true end

    ---! 发放升级奖励
    local props = {}
    local senior_props = {}
    for prop_id, prop_count in pairs(rewards) do repeat
        local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
        if not item_config then
            break
        end

        if not item_config.if_senior then
            player:change_prop_count(prop_id, prop_count, PropRecieveType.kPropChangeTypeUpgrade)
            props[#props + 1] = { propId = prop_id, propCount = prop_count, }
            break
        end

        for idx = 1, prop_count do
            senior_props[#senior_props + 1] = player:add_senior_prop_quick(prop_id)
        end
    until true end

    ---! 广播升级消息
    local result = {}
    result.playerId = player:get_id()
    result.newGrade = new_grade
    result.dropProps = props
    result.dropSeniorProps = senior_props
    player:brocast_packet("MSGS2CUpgrade", result)

    local desk = player:get_desk()
    if desk and not ROOM_CONFIG:is_grade_validate(desk:get_grade(), new_grade) then
        ---! 玩家升级炮倍至少80倍
        CANNON_D:upgrade_gunrate_free(player, 80)

        ---! 将玩家踢出当前房间
        ROOM_D:force_leave_desk(player, 2)
    end
end

-------------------------------------------------------------------------------
---! 启动接口
-------------------------------------------------------------------------------
register_post_init(function()
    TIMER_D:start_timer(60, _check_user)
end)
