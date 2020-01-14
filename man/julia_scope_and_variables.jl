# module
module A
a = 1
end;

module B
module C
c = 2
end
b = 2 * C.c
import ..A#他のモジュールから参照する
d = A.a
end;
# "module name" . "a variable in module"
A.a
B.d
C.c # これではダメ
B.C.c
# local and global
for i = 1:10
    global z # でも基本的にGlobalにおくのは避けた方がよさそう
    z = i
end
z

for i ∈ 1:100
    local x # this is also default
    x = i + 1
end
x

# Let blocks
# letから始まるブロックはglobal変数を受けつけるが，letの隣で新たに指定した変数をlocalに保存して参照する。
x, y, z = -1, -1, -1;
let x = 1, z
    println("x: $x, y: $y") # x is local variable, y the global
    println("z: $z") # errors as z has not been assigned yet but is local
end
# undef = alias for UndefInitializer(), which is undefined initializer
Fs = Vector{Any}(undef, 3)
i = 1 # initialize
while i <= 3
    Fs[i] = () -> i
    global i += 1
end
Fs[1] # この指定にはλがはいってる。なぜ？
Fs[2]()
Fs = Vector{Any}(undef, 3)
# ちょっとかえてみる
i = 1 # initialize
while i <= 3
    Fs[i] = i
    global i += 1
end
Fs[2] # ほしい変数が入ってる・
Fs[2]() # ここには何もない
# let blockを入れた場合
Fs = Vector{Any}(undef, 3)
i = 1 # initialize
while i <= 3
    let i = i
        Fs[i] = () -> i
    end
    global i += 1
end
Fs[1] # この指定にはλがはいってる。なぜ？
Fs[2]()
# forloop comprehension
# iはいずこに？
for i = 1:10 # iteration variableはいつも新しく作られるので，localやglobalには残らない
end # iteration variableはいつも新しく作られるので，localやglobalには残らない
i
function f()
    i = 0
    for outer i = 1:3 # ところがouterで指定すると，localにも残る
    end
    return i
end
f()
for outer i = 1:10  # これはダメ
end  # これはダメ

# constants
# 基本的にC++で使ったのと一緒
# invalid redefinition of constant variables
x = nothing # restartingしないとだめっぽ
const x = 1.0
x = 1
const y = 2.0
t = 1.0 # もしも同じ方ならば，warningがでるが，reassignできる
