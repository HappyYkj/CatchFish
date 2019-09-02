local debug = true

local redis
if debug then
redis = {
    auth = "syg23333",
    host = "127.0.0.1",
    port = 6379,
}
else
redis = {
    auth = "syg23333",
    host = "54.210.5.255",
    port = 6379,
}
end

local mysql
if debug then
mysql = {
    data = "catchfish",
    user = "root",
    auth = "weile2018",
    host = "127.0.0.1",
    port = 3306,
}
else
mysql = {
    data = "catchfish",
    user = "root",
    auth = "weile2018",
    host = "39.96.52.103",
    port = 3306,
}
end

local dblog
if debug then
    dblog = {
    data = "catchfish",
    user = "root",
    auth = "weile2018",
    host = "127.0.0.1",
    port = 3306,
}
else
dblog = {
    data = "catchfish",
    user = "root",
    auth = "weile2018",
    host = "39.96.52.103",
    port = 3306,
}
end

local config = {
    debug = debug,
    redis = redis,
    mysql = mysql,
    dblog = dblog,
}

return config
