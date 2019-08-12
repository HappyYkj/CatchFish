local function main (userOb, msgData)
    local changePropInfo = {}
    for _, config in pairs(EXCHANGE_CONFIG:get_configs()) do
        local props = {}
        if config.reward then
            local propId = next(config.reward)
            local propCount = config.reward[propId]
            if propId and propCount then
                props = { propId = propId, propCount = propCount, }
            end
        end
        
        local buyProps = {}
        if config.reward then
            local propId = next(config.need_item)
            local propCount = config.need_item[propId]
            if propId and propCount then
                buyProps = { propId = propId, propCount = propCount, }
            end
        end

        changePropInfo[#changePropInfo + 1] = {
            changeId = config.id,
            changeName = config.name,
            props = props,
            buyProps = buyProps,
            type = 2,
            leftCount = -1,
        }
    end
    
    local result = {}
    result.changePropInfo = changePropInfo
    userOb:send_packet("MSGS2CGetChangePropInfo", result)
end

COMMAND_D:register_command("MSGC2SGetChangePropInfo", GameCmdType.NONE, main)
