# Tasks (a.k.a coroutines)

# The merits of tasks
# 1. Swithcing tasks dose not use any space.
# 2. Switching among tasks can occur in any order.

function producer(c::Channel)
    put!(c, "start")
    for n in 1:100000
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

# Channelsを使うと，評価を一回の`put!`実行ごとに行うことができる。

# Parallel computings

# Given Channels c1 and c2,
c1 = Channel(32)
c2 = Channel(32)
# and a function `foo` which reads items from c1, processes the item read
# and writes a result to c2,
function foo()
    while true
        data = take!(c1)
        [...]               # process data
        put!(c2, result)    # write out result
    end
end

# we can schedule `n` instances of `foo` to be active concurrently.
for _ in 1:n
    @async foo()
end
