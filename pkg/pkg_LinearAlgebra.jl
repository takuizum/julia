using LinearAlgebra, BenchmarkTools

function mm1(A, B)
    N = size(A, 1)
    C = zeros(N, N)
    for i in 1:N, j in 1:N
        @views C[i, j] = dot(A[i, :], B[:, j])
    end
    return C
end

function mm2(A, B)
    N = size(A, 1)
    C = zeros(N, N)
    C_tmp = similar(C)
    mul!(C_tmp, A, B)
    copy!(C, C_tmp)
    return C
end

N = 1_000
A = randn(N, N)
B = randn(N, N)

@benchmark mm1(A, B)
@benchmark mm2(A, B)
@benchmark A*B

M1 = mm1(A, B)
M2 = mm2(A, B)
M1 ≈ M2
