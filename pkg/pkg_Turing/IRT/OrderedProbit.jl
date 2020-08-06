import Random: AbstractRNG

struct OrderedProbit{T1, T2<:AbstractVector} <: DiscreteUnivariateDistribution
   η::T1
   cutpoints::T2

   function OrderedProbit(η, cutpoints)
        if !issorted(cutpoints)
            error("cutpoints are not sorted")
        end
        return new{typeof(η), typeof(cutpoints)}(η, cutpoints)
   end

end

function Distributions.logpdf(d::OrderedProbit, k::Int)
    K = length(d.cutpoints)+1
    c =  d.cutpoints

    if k==1
        logp= -softplus(-(c[k]-d.η))  #logp= log(cdf(Normal(), c[k]-d.η))
    elseif k<K
        logp= log(cdf(Normal(), c[k]-d.η) - cdf(Normal(), c[k-1]-d.η))
    else
        logp= -softplus(c[k-1]-d.η)  #logp= log(1-cdf(Normal(), c[k-1]-d.η))
    end

    return logp
end

Distributions.pdf(d::OrderedProbit, k::Int) = exp(logpdf(d,k))

function Distributions.rand(rng::AbstractRNG, d::OrderedProbit)
    cutpoints = d.cutpoints
    η = d.η

    K = length(cutpoints)+1
    c = vcat(-Inf, cutpoints, Inf)

    ps = [cdf(Normal(), η - i[1]) - cdf(Normal(), η - i[2]) for i in zip(c[1:(end-1)],c[2:end])]

    k = rand(rng, Categorical(ps))

    if all(x -> x > zero(x), ps)
        return(k)
    else
        return(-Inf)
    end
end
