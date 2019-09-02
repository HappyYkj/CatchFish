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

local load_path_history = {}
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

        local filename = string.sub(loadfile, #root + 1)
        printf("Load file : %s ...", filepath)
        local tick = os.clock()

        local ok, err = pcall(require, filename)
        if not ok then
            printf("Load file : %s Fail. err msg = %s", filepath, err)
            os.exit(0)
            return
        else
            local cost = os.clock() - tick
            printf("Load file : %s OK. cost tick = %s", filepath, cost)
        end

        load_path_history[filepath] = lfs.attributes(filepath).modification
    end
end

function update_all (path, force)
    local root = lfs.currentdir()

    local filepaths = {}
    if not path then
        filepaths = table.keys(load_path_history)
    else
        filepaths = attrdir(root .. sep .. 'src' .. sep .. path)
    end

    local tick = os.clock()
    for _, filepath in ipairs(filepaths) do
        local old_modification = load_path_history[filepath]
        local new_modification = lfs.attributes(filepath).modification
        if not force and old_modification and old_modification == new_modification then
        else
            local loadfile
            local ext = getextension(filepath)
            if ext then
                loadfile = string.sub(filepath, 1, #filepath - #ext - 1)
            else
                loadfile = filepath
            end

            local filename = string.sub(loadfile, #root + 1)
            printf("Update file : %s ...", filepath)
            local tick = os.clock()

            local old_content
            if package.loaded[filename] then
                old_content = package.loaded[filename]
                package.loaded[filename] = nil
            end

            local ok, err = pcall(require, filename)
            if not ok then
                package.loaded[filename] = old_content
                printf("Update file : %s Fail. err msg = %s", filepath, err)
            else
                local cost = os.clock() - tick
                printf("Update file : %s OK. cost tick = %s", filepath, cost)
            end

            load_path_history[filepath] = new_modification
        end
    end

    local cost = os.clock() - tick
    if not path then
        printf("Update all files OK. cost total tick = %s", cost)
    else
        printf("Update %s files OK. cost total tick = %s", path, cost)
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
