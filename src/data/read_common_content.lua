local json = require "cjson"

local table_names = {
    user = "user_data",
    item = "common_data",
}

local function main(conn, msg)
    local path, name, branch = msg['path'], msg['name'], msg['branch']
    local table = table_names[path] or "common_data"
    local cmd = string.format("SELECT `context` FROM `%s` WHERE path = '%s' AND name = '%s' AND branch = '%s'", table, path, name, branch)

    local cur = conn:execute(cmd)
    local row = cur:fetch({}, "a")
    cur:close()

    local content = row and row.context or ""
    return content
end

return main
