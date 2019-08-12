local table_names = {
    user = "user_data",
    item = "common_data",
}

local function main(conn, msg)
    local path, name, branch, content = msg['path'], msg['name'], msg['branch'], msg['content']
    local table = table_names[path] or "common_data"
    local cmd = string.format("REPLACE INTO `%s` (`update_time`, `path`, `name`, `branch`, `context`) VALUES ('%s', '%s', '%s', '%s', '%s');", table, os.date("%Y-%m-%d %H:%M:%S"), path, name, branch, content)
    print(cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

return main
