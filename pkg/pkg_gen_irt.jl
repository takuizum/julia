using Gen, Distributions, StatsFuns

@gen function irt2pl(resp::Array{Int64, 2})
    a = @trace(Distributions.LogNormal(0, 1), :a)
    b = @trace(normal(0, 2), :b)
    θ = @trace(normal(0, 1), :θ)
    for i in 1:nrow(resp)
        for j in 1:ncol(resp)
            @trace(bernoulli(StatsFuns.logistic(a*(θ-b)), (:resp, i, j)))
        end
    end
    return(size(resp))
end;

a = [1,2,1,2,1];
b = [-2:1:2;];
θ = rand(Normal(),1_000);

Gen.simulate(irt2pl, ([0 0 1 0; 1 1 0 1], ))