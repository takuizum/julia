a = [1.0 2.0 3.0]
b = [4.0 5.0]

list = push!(a, b, a) # これはだめぽ

list = [(1,2,3);(2,3);(1,2,3,4,5)]
list[1][1]

# tuplesで作ればリストもどきにはなる・
mutable struct 2PL
    prob::
end

# 優先して配置しておくべきもの
# rpをhelperとして動く，反応確率を計算して，適当な配列にするための関数。
# rpを配置しておくための配列の構造をどうするか。
# respのカテゴリ（もしくは型）に任意のものを加えるためにはどうすればよいか。

using StatsFuns
# Missing
rp = function(resp::Missing, pars, θ)
    1
end

# 2PL
rp = function(resp::2PL, pars, θ)
    a = pars[1]
    d = pars[2]
    p = Statsfuns.logistic(-a*θ+d)
    resp == 1 ? p : 1-p
end

# 3PL
rp = function(resp::3PL, pars, θ)
    a = pasr[1]
    d = pars[2]
    c = pars[3]
    2pl = Statsfuns.logistic(-a*θ+d)
    p = c + (1-c)*2pl
    resp == 1 ? p : 1-p
end

# GRM
rp = function(resp::GRM, pars, θ)
    a = pars[1]
    d0 = pars[2]
    d1 = pars[3]
    p0 = Statsfuns.logistic(-a*θ+d0)
    p1 = Statsfuns.logistic(-a*θ+d1)
    if(0 < resp < )
    p0 - p1

# GPCM
rp = function(model::GPCM)