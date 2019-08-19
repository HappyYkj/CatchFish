local M = {}

function M:add_callfish(playerId, pathId, fishId, frameId, callfishId)
    local callfish = {}
    callfish.callFishId = callfishId
    callfish.playerId = playerId
    callfish.pathId = pathId
    callfish.fishId = fishId
    callfish.frameId = frameId
    callfish.freezeTime = 0
    callfish.callFishTimestamp = os.mtime()
    self:set("callfish", playerId, callfishId, callfish)
end

function M:get_callfish(playerId, callfishId)
    return self:query("callfish", playerId, callfishId)
end

function M:remove_callfish(playerId, callfishId)
    return self:delete("callfish", playerId, callfishId)
end

---! 获取可见的召唤鱼
function M:get_visable_callfishes()
    local callfishes = {}
    for _, player_map in pairs(self:query("callfish") or {}) do
        for _, callfish in pairs(player_map) do
            callfishes[#callfishes + 1] = callfish
        end
    end
    return callfishes
end

---! 刷新所有的召唤鱼
function M:flush_visable_callfishes(start_time)
    local callfishes = self:query("callfish")
    if not callfishes then
        return
    end

    local now = os.mtime()
    for playerId, _ in pairs(callfishes) do
        for fishId, callfish in pairs(callfishes[playerId]) do
            local freeze_time = now - math.max(start_time, callfish.callFishTimestamp)
            callfish.freezeTime = callfish.freezeTime + freeze_time
            self:set("callfish", playerId, callfishId, callfish)
        end
    end
end

---! 获取所有的召唤鱼
function M:get_visable_callfishes()
    local callfishes = self:query("callfish")
    if not callfishes then
        return {}
    end

    local fishes = {}
    for player_id, _ in pairs(callfishes) do
        for _, callfish in pairs(callfishes[player_id]) do
            local fish = {}
            fish.playerId = callfish.playerId
            fish.fishTypeId = callfish.fishId
            fish.frameId = callfish.frameId
            fish.callFishId = callfish.callFishId
            fish.pathId = callfish.pathId
            fishes[#fishes + 1] = fish
        end
    end
    return fishes
end

function M:is_fish_visable(callfish)
    local fishpath = FISH_PATH_CONFIG:get_config_by_id(callfish.pathId)
    if not fishpath then
        ---! 对应鱼线未找到，不可见
        return false
    end

    ---! 获取当前时间
    local now = os.mtime()

    ---! 获取冰冻历史时长
    local freeze_history_time = callfish.freezeTime

    ---! 获取冰冻开始时间
    local freeze_start_time = FREEZE_D:get_freeze_start_time(self)
    if freeze_start_time > 0 then
        if freeze_start_time <= callfish.callFishTimestamp then
            -- 冰冻后召唤出来，一定可以见
            return true
        end

        freeze_history_time = freeze_history_time + now - freeze_start_time
    end

    local diff_time = now - callfish.callFishTimestamp - freeze_history_time
    return diff_time < #fishpath.pointdata * FISH_SERVER_CONFIG.pointRate * 50
end

F_COMBAT_CALLFISH = M
