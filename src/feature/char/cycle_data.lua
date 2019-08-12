local function update_daily_cycle_data(player)
    return CYCLE_DATA_D:update_daily_cycle_data(player)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
local M = {}

function M:update_data()
    ---! 更新每日周期性数据
    update_daily_cycle_data(self)
end

F_CHAR_CYCLE_DATA = M
