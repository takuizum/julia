using RCall
@rlibrary irtfun2
res = estip2(data, fc = 3)
res
@rput res
# REPLで$を入力すると，R mode になる
@rget para
@rget se

se
