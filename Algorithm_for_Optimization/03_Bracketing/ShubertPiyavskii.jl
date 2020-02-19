# a.k.a Sawtooth method

struct Pt
    x
    y
end
function _get_sp_intersection(A, B, l)
    # Searching the intersection of the slope 𝑙 of functions, A and B.
    t = ((A.y - B.y) - l*(A.x - B.x)) / 2l
    return Pt(A.x + t, A.y - t*l)
end
function shubert_piyavskii(f, a, b, l, ε, δ=0.01)
    m = (a+b)/2 # Mid point
    A, M, B = Pt(a, f(a)), Pt(m, f(m)), Pt(b, f(b))
    pts = [A, _get_sp_intersection(A, M, l),
           M, _get_sp_intersection(M, B, l), B]
    Δ = Inf
    while Δ > ε
        # Getting candidate points of global minima
        i = argmin([P.y for P in pts])
        P = Pt(pts[i].x, f(pts[i].x))
        Δ = P.y - pts[i].y
        P_prev = _get_sp_intersection(pts[i-1], P, l)
        P_next = _get_sp_intersection(P, pts[i+1], l)
        deleteat!(pts, i) # Usage : deleteat!([6, 5, 4, 3, 2, 1], 1:2:5)
        insert!(pts, i, P_next)  # Usage : insert!([6, 5, 4, 2, 1], 4, 3)
        insert!(pts, i, P)
        insert!(pts, i, P_prev)
    end
    intervals = []
    i = 2*(argmin([P.y for P in pts[1:2:end]])) - 1 # The adjacent element of the lowest intersection point.
    # `argmin` can be used to get the indices of the minimum elements in arrays.
    # pts[1:2:end] : iterator is the subset of odds elements in `pts`, in which the minimum candidates lie.
    for j in 2:2:length(pts)
        if pts[j].y < pts[i].y
            dy = pts[i].y - pts[j].y
            x_lo = max(a, pts[j].x - dy/l)
            x_hi = min(b, pts[j].x + dy/l)
            if !isempty(intervals) && intervals[end][2] + δ ≥ x_lo
                intervals[end] = (intervals[end][1], x_hi)
            else
                push!(intervals, (x_lo, x_hi))
            end
        end
    end
    return (pts[i], intervals)
end

Base.MathConstants.φ
