function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local super_type = type(super)
        assert(super_type == "nil" or super_type == "table" or super_type == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"", classname, super_type))

        if super_type == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function", classname))

            -- if super is function, set it to __create
            cls.__create = super
        elseif super_type == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class", classname))

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
            error(string.format("class() - create class \"%s\" with invalid super type", classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            for _, super in ipairs(cls.__supers) do
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
