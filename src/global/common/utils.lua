local function patternescape (str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

 function serialize (x, stk)
    local serialize_map = {
        [ "boolean" ] = tostring,
        [ "nil"     ] = tostring,
        [ "string"  ] = function(v) return string.format("%q", v) end,
        [ "number"  ] = function(v)
            if      v ~=  v     then return  "0/0"      --  nan
            elseif  v ==  1 / 0 then return  "1/0"      --  inf
            elseif  v == -1 / 0 then return "-1/0" end  -- -inf
            return tostring(v)
        end,
        [ "table"   ] = function(t, stk)
            stk = stk or {}
            if stk[t] then error("circular reference") end
            local rtn = {}
            stk[t] = true
            for k, v in pairs(t) do
                rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
            end
            stk[t] = nil
            return "{" .. table.concat(rtn, ",") .. "}"
        end,
    }

    setmetatable(serialize_map, {
        __index = function(_, k) error("unsupported serialize type: " .. k) end
    })

    return serialize_map[type(x)](x, stk)
end

function deserialize (str)
    return assert((loadstring or load)(str))()
end

function array (...)
    local t = {}
    for x in ... do t[#t + 1] = x end
    return t
end

--[[
function split (str, sep)
    if not sep then
        return array(str:gmatch("([%S]+)"))
    else
        assert(sep ~= "", "empty separator")
        local psep = patternescape(sep)
        return array((str..sep):gmatch("(.-)("..psep..")"))
    end
end
--]]

function split (input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function trim (str, chars)
    if not chars then return str:match("^[%s]*(.-)[%s]*$") end
    chars = patternescape(chars)
    return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function dump (t, prefix)
    prefix = prefix or ""
	for k,v in pairs(t) do
		print(prefix, k, v)
		if type(v) == "table" then
			dump(v, prefix .. "." .. k)
		end
	end
end

function table.len(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

function table.clone(t)
    local rtn = {}
    for k, v in pairs(t) do rtn[k] = v end
    return rtn
end

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

function table.extend(t, ...)
    for i = 1, select("#", ...) do
        local x = select(i, ...)
        if x then
        for k, v in pairs(x) do
            t[k] = v
        end
        end
    end
    return t
end

function table.shuffle(t)
    local rtn = {}
    for i = 1, #t do
        local r = math.random(i)
        if r ~= i then
        rtn[i] = rtn[r]
        end
        rtn[r] = t[i]
    end
    return rtn
end

local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
setmetatableindex = setmetatableindex_

function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end
    cls.inherit = function(_, ...)
        for i = 1, select("#", ...) do
            local x = select(i, ...)
            if type(x) == "table" then
                for k, v in pairs(x) do
                    cls[k] = v
                end
            end
        end
    end

    return cls
end

local socket = require "socket"
function sleep (sec)
    socket.select(nil, nil, sec)
end

function random(a, b)
    if not a then a, b = 0, 1 end
    if not b then b = 0 end
    return a + math.random() * (b - a)
end

function randomchoice(t)
    return t[math.random(#t)]
end

function weightedchoice(t)
    local sum = 0
    for _, v in pairs(t) do
        assert(v >= 0, "weight value less than zero")
        sum = sum + v
    end
    assert(sum ~= 0, "all weights are zero")
    local rnd = random(sum)
    for k, v in pairs(t) do
        if rnd < v then return k end
        rnd = rnd - v
    end
end

function os.mtime()
    local socket = require "socket"
    return math.floor(socket.gettime() * 1000)
end
