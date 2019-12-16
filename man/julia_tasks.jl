# Tasks (a.k.a coroutines)

# The merits of tasks
# 1. Swithcing tasks dose not use any space.
# 2. Switching among tasks can occur in any order.

function producer(c::Channel)
    put!(c, "start")
    for n in 1:4
        put!(c, 2n)
    end
    put!(c, "stop")
end;

# Channel constructer
# TaskをChannelsに投げるための特殊な構造体
chnl = Channel(producer);

take!(chnl)

# Channel can be used as iterable object.
for x in Channel(producer)
    println(x)
end
