local express_query
express_query = function (db, key, ...)
    if type(db) ~= "table" then
        return nil
    end

    key = tostring(key)
    if select("#", ...) == 0 then
        return db[key]
    end

    if db[key] == nil then
        return nil
    end

    return express_query(db[key], ...)
end

local express_set
express_set = function (db, key, value, ...)
    if type(db) ~= "table" then
        db = {}
    end

    key = tostring(key)
    if select("#", ...) == 0 then
        local ret = db[key]
        db[key] = value
        return value
    end

    db[key] = db[key] or {}
    return express_set(db[key], value, ...)
end

local express_delete
express_delete = function (db, key, ...)
    if type(db) ~= "table" then
        return
    end

    key = tostring(key)
    if select("#", ...) == 0 then
        db[key] = nil
        return
    end

    return express_delete(db[key], ...)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
local M = {}

function M:query_entire_dbase ()
    self.dbase = self.dbase or {}
    return self.dbase
end

function M:set_entire_dbase (dbase)
    self.dbase = dbase or {}
end

function M:query_entire_temp_dbase ()
    self.temp_dbase = self.temp_dbase or {}
    return self.temp_dbase
end

function M:set_entire_temp_dbase (temp_dbase)
    self.temp_dbase = temp_dbase or {}
end

function M:set (key, value, ...)
    local db = self:query_entire_dbase()
    return express_set(db, key, value, ...)
end

function M:query (key, ...)
    local db = self:query_entire_dbase()
    return express_query(db, key, ...)
end

function M:delete (key, ...)
    local db = self:query_entire_dbase()
    express_delete(db, key, ...)
end

function M:set_temp (key, value, ...)
    local db = self:query_entire_temp_dbase()
    return express_set(db, key, value, ...)
end

function M:query_temp (key, ...)
    local db = self:query_entire_temp_dbase()
    return express_query(db, key, ...)
end

function M:delete_temp (key, ...)
    local db = self:query_entire_temp_dbase()
    express_delete(db, key, ...)
end

F_COMN_DBASE = M
