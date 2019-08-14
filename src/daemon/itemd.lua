-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
ITEM_D = {}

function ITEM_D:send_item_info(userOb)
    local props = {}
    for _, prop in pairs(userOb:get_props()) do
        props[#props + 1] = prop
    end

    local seniorProps = {}
    for _, seniorProp in pairs(userOb:get_senior_props()) do
        seniorProps[#seniorProps + 1] = seniorProp
    end

    local result = {}
    result.props = props
    result.seniorProps = seniorProps
    userOb:send_packet("MSGS2CPropInfo", result)
end
