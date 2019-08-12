local M = {}

function M:add_bullet(bullet)
    local playerId = bullet.playerId
    local bulletId = bullet.bulletId
    self:set("bullet", playerId, bulletId, bullet)
    return bullet
end

function M:get_bullet(playerId, bulletId)
    return self:query("bullet", playerId, bulletId)
end

function M:remove_bullet(playerId, bulletId)
    self:delete("bullet", playerId, bulletId)
end

function M:remove_player_bullets(playerId)
    self:delete("bullet", playerId)
end

function M:get_player_bullets(playerId)
    local bullets = self:query("bullet", playerId) or {}
    return table.values(bullets)
end

function M:get_player_bullet_count(playerId)
    local bullets = self:get_player_bullets(playerId)
    return #bullets
end

function M:remove_all_bullets()
    self:delete("bullet")
end

function M:get_all_bullets()
    return self:query("bullet") or {}
end

function M:change_bullet_target(playerId, bulletId, timelineId, fishArrayId)
    local bullet = self:get_bullet(playerId, bulletId)
    if not bullet then
        return
    end

    bullet.timelineId = timelineId
    bullet.fishArrayId = fishArrayId
end

function M:is_bullet_validate(player, bullet)
    if bullet.gunRate > player:get_max_gunrate() then
        return false
    end

    return true
end

F_COMBAT_BULLET = M
