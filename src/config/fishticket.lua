-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FISHTICKET_CONFIG = {}

-- 奖券鱼掉落数
-- gunRate:炮倍
-- roomType:房间类型
function FISHTICKET_CONFIG:getFishTicketFishDrop(roomType, gunRate)
    local drop_base = 10
	if roomType == 1 then
		drop_base = 1
	elseif roomType == 2 then
		drop_base = 2
	elseif roomType == 3 then
		drop_base = 5
	end

    local multiply = 35
    if gunRate <= 100 then
		multiply = 4
	elseif gunRate <= 300 then
		multiply = 6
	elseif gunRate <= 500 then
		multiply = 10
	elseif gunRate <= 1000 then
		multiply =  15
	elseif gunRate <= 2500 then
		multiply =  20
	elseif gunRate <= 6000 then
		multiply = 25
	elseif gunRate <= 9500 then
		multiply = 30
    end

    if roomType == 1 then
		multiply = math.max(multiply, 8)
	elseif roomType == 2 then
		multiply = math.max(multiply, 10)
	elseif roomType == 3 then
        multiply = math.max(multiply, 20)
    else
        multiply = math.max(multiply, 40)
    end

    return drop_base * multiply
end

-- 奖券鱼房间最大翻倍数
-- roomType:房间类型
function FISHTICKET_CONFIG:getFishTicketFishDropByRoomType(roomType)
	if roomType == 1 then
		return 8
	elseif roomType == 2 then
		return 10
	elseif roomType == 3 then
		return 20
	else
		return 40
	end
end

-- 最大鱼券/水晶掉落个数
-- propId:道具id
-- roomType:房间类型
-- gunRate:炮倍
function FISHTICKET_CONFIG:getMaxCrystalPropDrop(propId, roomType, gunRate)
	if gunRate <= 50 then
		return 1
	elseif gunRate <= 80 then
		return 2
	elseif gunRate <= 200 then
		return 3
	elseif gunRate <= 500 then
		return 4
	elseif gunRate <= 1000 then
		return 5
	elseif gunRate <= 3000 then
		return 6
	elseif gunRate <= 8000 then
		return 8
	else
		return 4
	end
end
