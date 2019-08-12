local M = {}

function M:get_desk()
    return self:query_temp("desk")
end

function M:get_desk_id()
    local desk = self:get_desk()
    if not desk then
        return INVALID_DESK
    end
    return desk:get_id()
end

function M:get_desk_grade()
    local desk = self:get_desk()
    if not desk then
        return 0
    end
    return desk:get_grade()
end

function M:set_desk(desk)
    self:set_temp("desk", desk)
end

function M:get_chair_id()
    local desk = self:get_desk()
    if not desk then
        return INVALID_CHAIR
    end

    return desk:get_chair_by_player(self)
end

F_CHAR_DESK = M
