local M = {}

function M:get_match_signup_count(match_id)
    return self:query("match", "signup", match_id) or 0
end

function M:add_match_signup_count(match_id)
    self:set("match", "signup", match_id, self:get_match_signup_count(match_id) + 1)
end

function M:get_match_share_count(match_id)
    return self:query("match", "share", match_id) or 0
end

function M:add_match_share_count(match_id)
    self:set("match", "share", match_id, self:get_match_share_count(match_id) + 1)
end

F_CHAR_MATCH = M
