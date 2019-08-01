# Juliaの計算制度
rs = Array{Float64, 1}(0:1:100)
function arcsin(x, X)
    @. x = 0.5(asin(sqrt(x/(X+1))) + asin(sqrt((x+1)/(X+1))))
    x
end

sc = arcsin(rs, 100)

tgt_pts = (2.5, 50.0)
ref_pts = (sc[11], sc[96])

A = (tgt_pts[1]-tgt_pts[2]) / (ref_pts[1]-ref_pts[2])
@show A

K1 = -A*ref_pts[1] + tgt_pts[1]
K2 = -A*ref_pts[2] + tgt_pts[2]

@show K1, K2

K1 = K2

BigFloat(-A*ref_pts[1] + tgt_pts[1])
BigFloat(-A*ref_pts[2] + tgt_pts[2])
