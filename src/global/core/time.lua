function get_whole_time(ti)
    ti = ti or os.time()
    local t = os.date("*t", ti)
    t.min = 0
    t.sec = 0
    return os.time(t)
end
