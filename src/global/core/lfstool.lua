local lfs = require "lfs"

local string_match = string.match
local sep = string_match(package.config, "[^\n]+")
local upper = ".."

---! 获取文件名
function getfilename (filename)
    return string_match(filename, ".+/([^/]*%.%w+)$")
end

---! 获取路径
function getpath (filename)
    return string_match(filename, "(.+)/[^/]*%.%w+$")
end

---! 获取扩展名
function getextension (filename)
    return string_match(filename, ".+%.(%w+)$")
end

function attrdir (path)
    local ret = {}

    local defer = {}
    for file in lfs.dir(path) do
        -- if file ~= "." and file ~= ".." then
        if string.sub(file, 1, 1) ~= "." then
            local f = path..sep..file
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                table.insert(defer, f)
            else
                table.insert(ret, f)
            end
        end
    end

    for _, dir in ipairs(defer) do
        for _, f in pairs(attrdir(dir)) do
            table.insert(ret, f)
        end
    end

    return ret
end

function load_all (path)
    local root = lfs.currentdir()
    for _, filepath in ipairs(attrdir(root .. sep .. 'src' .. sep .. path)) do
        local loadfile
        local ext = getextension(filepath)
        if ext then
            loadfile = string.sub(filepath, 1, #filepath - #ext - 1)
        else
            loadfile = filepath
        end

        printf("Load file : %s ...", filepath)
        local tick = os.clock()
        require(string.sub(loadfile, #root + 1))
        local cost = os.clock() - tick
        printf("Load file : %s OK. cost tick = %s", filepath, cost)
    end
end

function load_file (path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end
