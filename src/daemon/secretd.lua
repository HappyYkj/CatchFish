if not DEBUG_VERSION then
    return
end

local json = require "json"

local commands = {}

---! 修改VIP经验
commands[200] = function (player, para)
    if para == 0 then
        return
    end

    player:set_vip_exp(math.max(0, player:get_vip_exp() + para))

    local result = {}
    result.isSuccess = true
    result.playerInfo = player:generate_player_info()
    player:send_packet("MSGS2CGetPlayerInfo", result)
end

---! 修改月卡剩余时间
commands[201] = function (player, para)
    player:set_monthcard_left_days(para)

    local result = {}
    result.isSuccess = true
    result.playerInfo = player:generate_player_info()
    player:send_packet("MSGS2CGetPlayerInfo", result)
end

---! 修改炮倍
commands[301] = function (player, para)
    if para <= 0 then
        return
    end

    local config = CANNON_CONFIG:get_config_by_gunrate(para)
    if not config then
        return
    end

    if para == player:get_max_gunrate() then
        return
    end

    player:set_max_gunrate(para)

    local result = {}
    result.playerId = player:get_id()
    result.newFishIcon = player:get_prop_count(GamePropIds.kGamePropIdsFishIcon)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    result.newGunRate = para
    result.errorCode = UpgradeResult.kUpgradeResultSuccess
    player:brocast_packet("MSGS2CUpgradeCannonResult", result)
end

---! 修改新手任务
commands[302] = function (player, para)
end

---! 新增充值
commands[303] = function (player, para)
    if para <= 0 or para >= 10000000 then
        return
    end

    local data = {}
    data["userid"] = string.format("%d", player:get_id())
    data["order_id"] = string.format("test%d", os.time())
    data["goodstag"] = string.format("%d", 830000000 + para)
    THREAD_D:post("client_channel", "charge_channel", json.encode(data))
end

---! 召唤指定鱼
commands[305] = function (player, para)
end

---! 修改玩家等级
commands[306] = function (player, para)
    local offset = LEVEL_CONFIG:get_exp_by_grade(para) - player:get_grade_experience()
    if offset == 0 then
        return
    end

    player:add_grade_experience(offset)

    local result = {}
    result.playerId = player:get_id()
    result.newGrade = player:get_grade()
    player:brocast_packet("MSGS2CUpgrade", result)
end

---! 奖金鱼抽奖
commands[309] = function (player, para)
    local config = REWARD_CONFIG:get_config_by_id(para)
    if not config then
        return
    end

    ---! 通过玩家当日抽奖次数，获取要求的奖池
    local draw_require = FISH_SERVER_CONFIG:get_fish_draw_require(player:get_draw_count())

    ---! 当日奖金鱼击杀数量
    local fish_count = player:get_kill_reward_fish()

    ---! 修改奖金鱼击杀数量
    local diff_fish_count = draw_require - fish_count
    if diff_fish_count > 0 then
        player:add_kill_reward_fish(diff_fish_count)
    end

    ---! 修改当前奖池的数值
    local draw_rate = math.max(1, config.limit) - player:get_draw_rate()
    if draw_rate ~= 0 then
        player:add_draw_rate(draw_rate)
    end

    FISH_DRAW_D:send_fish_reward(player)
end

local function modify_prop_count(player, prop_id, prop_count)
    local cost_props = {}
    local drop_props = {}
    local senior_props = {}
    if ITEM_CONFIG:is_senior_prop(prop_id) then
        senior_props[#senior_props + 1] = player:add_senior_prop_quick(prop_id)
    else
        local diff_prop_count = prop_count - player:get_prop_count(prop_id)
        if diff_prop_count == 0 then
            return
        end

        player:change_prop_count(prop_id, diff_prop_count, PropRecieveType.kPropChangeTypeSecret)

        if prop_count > 0 then
            drop_props[#drop_props + 1] = { propId = prop_id, propCount = diff_prop_count, }
        else
            cost_props[#cost_props + 1] = { propId = prop_id, propCount = diff_prop_count, }
        end
    end

    local result = {}
    result.playerId = player:get_id()
    result.source = "MSGS2CSetProp"
    result.costProps = cost_props
    result.dropProps = drop_props
    result.dropSeniorProps = senior_props
    player:brocast_packet("MSGS2CUpdatePlayerProp", result)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SECRET_D = {}

function SECRET_D:process_command(player, cmd)
    local func = commands[cmd.propId]
    if not func then
        if type(cmd.propId) == "number" and type(cmd.propCount) == "number" then
            modify_prop_count(player, cmd.propId, cmd.propCount)
        end
        return
    end

    xpcall(function()
        func(player, cmd.propCount)
    end, function(err)
        spdlog.error(err)
        spdlog.error(debug.traceback())
    end)
end
