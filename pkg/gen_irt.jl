using Gen, Distributions, StatsFuns

# generative model
@gen function irt2pl_gen(θ::Vector{Float64}, a::Vector{Float64}, b::Vector{Float64})
    resp = Array{Int64}(undef, length(θ), length(a) )
    for i in 1:length(θ)
        for j in 1:length(a)
            if @trace( bernoulli(StatsFuns.logistic(a[j]*(θ[i]-b[j]))), (:resp, i, j))
                resp[i, j] = 1
            else
                resp[i, j] = 0
            end
        end
    end
    return resp
end;

a = [1.0,2.0,1.0,2.0,1.0];
b = [-2.0:1.0:2.0;];
θ = rand(Normal(),1_0000);
irt2pl_gen(θ, a, b)
trace = Gen.simulate(irt2pl_gen, (θ, a, b,))
Gen.get_args(trace)
println(Gen.get_choices(trace))

# Probability model
@gen function irt2pl(N::Int64, J::Int64)
    n = 9
    a = @trace(uniform(0, 2), :a)
    b = @trace(normal(0, 2), :b)
    θ = @trace(normal(0, 1), :θ)
    for i in 1:N
        for j in 1:J
            @trace( bernoulli(StatsFuns.logistic(a*(θ-b))), (:resp, i, j) )
        end
    end
    return n
end;

irt2pl(100, 10)
Gen.simulate(irt2pl, (100, 10) ) |> println


@gen function foo(prob::Float64)
    z1 = @trace(bernoulli(prob), :a)
    z2 = @trace(bernoulli(prob), :b)
    return z1 || z2
end