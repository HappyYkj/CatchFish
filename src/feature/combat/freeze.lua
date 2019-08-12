local M = {}

function M:begin_freeze(player)
    return FREEZE_D:begin_freeze(self, player)
end

function M:is_in_freeze()
    return FREEZE_D:is_in_freeze(self)
end

function M:get_freeze_timespan()
    return FREEZE_D:get_freeze_timespan(self)
end

function M:get_freeze_player_id()
    return FREEZE_D:get_freeze_player_id(self)
end

function M:reset_freeze()
    return FREEZE_D:reset_freeze(self)
end

F_COMBAT_FREEZE = M
