using Gen, Distributions, StatsFuns

# generative model
@gen function irt2pl(θ::Vector{Float64}, a::Vector{Float64}, b::Vector{Float64})
    for i in 1:length(θ)
        for j in 1:length(a)
            @trace(bernoulli(StatsFuns.logistic(a[j]*(θ[i]-b[j])), (:resp, i, j)))
        end
    end
    return(size(resp))
end;

a = [1.0,2.0,1.0,2.0,1.0];
b = [-2.0:1.0:2.0;];
θ = rand(Normal(),1_000);

irt2pl(θ, a, b)

Gen.simulate(irt2pl, ([0 0 1 0; 1 1 0 1], ))