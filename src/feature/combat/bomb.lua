local M = {}

local BOMB_USE_TYPE_PROP    = 0
local BOMB_USE_TYPE_CRYSTAL = 1

function M:add_bomb(playerId, bombId, useType, propId)
    self:set("bomb", playerId, bombId, { useType = useType, propId = propId, })
end

function M:remove_bomb(playerId, bombId)
    self:delete("bomb", playerId, bombId)
end

function M:remove_all_bomb(playerId)
    self:delete("bomb", playerId)
end

function M:get_bomb_use_type(playerId, bombId)
    return self:query("bomb", playerId, bombId)
end

---! 获取挂起的水晶
function M:get_pending_crystal(playerId)
    local player_tbl = self:query("bomb", playerId)
    if not player_tbl then
        return 0
    end

    local count = 0
    for _, bomb_tbl in pairs(player_tbl) do repeat
        if bomb_tbl.useType == BOMB_USE_TYPE_CRYSTAL then
            break
        end

        local config = ITEM_CONFIG:get_config_by_id(bomb_tbl.propId)
        if not config then
            break
        end

        count = count + config.inner_value
    until true end
    return count
end

---! 获取挂起的核弹道具个数
function M:get_pending_bomb_count(playerId, propId)
    local player_tbl = self:query("bomb", playerId)
    if not player_tbl then
        return 0
    end

    local count = 0
    for _, bomb_tbl in pairs(player_tbl) do
        if bomb_tbl.useType == BOMB_USE_TYPE_PROP and bomb_tbl.propId == propId then
            count = count + 1
        end
    end
    return count
end

F_COMBAT_BOMB = M
