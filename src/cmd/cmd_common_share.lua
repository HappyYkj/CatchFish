local function main (userOb, msgData)
    SHARE_D:process_share(userOb, msgData.shareType, msgData.shareArgs)
end

COMMAND_D:register_command("MSGC2SCommonShare", GameCmdType.NONE, main)
