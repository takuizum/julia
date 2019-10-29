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

# sample parameter
a = [1.0,2.0,1.0,2.0,1.0];
b = [-2.0:1.0:2.0;];
θ = rand(Normal(),1_000);

irt2pl_gen(θ, a, b)
trace = Gen.simulate(irt2pl_gen, (θ, a, b,))
Gen.get_args(trace)
println(Gen.get_choices(trace))
# generate datum
@gen function generate_response(θ::Float64, a::Float64, b::Float64)
    return @trace( bernoulli(StatsFuns.logistic(a*(θ-b))), (:resp, i, j) )
end;
# Probability model
@gen function irt2pl(N::Int64, J::Int64)
    n = 9
    a = b = zeros(J)
    θ = seros(N)
    for i in 1:N
        θ[i] = @trace(normal(0, 1), (:θ, i))
    end
    for j in 1:J
        a[j] = @trace(uniform(0, 2), (:a, j))
        b[j] = @trace(normal(0, 2), (:b, j))
    end
    
    for i in 1:N
        for j in 1:J
            generate_response(θ[i], a[j], b[j])
        end
    end
    return n
end;

irt2pl(100, 10)
Gen.simulate(irt2pl, (100, 10) ) |> println


# posterior inference
function do_inference(model, resp, amount_of_computation)
    N = size(resp, 1)
    J = size(resp, 2)
    observations = Gen.choicemap()
    for i in 1:N
        for j in 1:J
            observations[(:resp, i, j)] = resp[i, j]
        end
    end
    (trace, ) = Gen.importance_resampling(model, (N, J), observations, amount_of_computation);
    return trace
end


data = irt2pl_gen(θ, a, b)
data

fit = do_inference(irt2pl, data, 1000)
choices = Gen.get_choices(fit)
choices[:b]


