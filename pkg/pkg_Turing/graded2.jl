using Turing, RCall
using DataFrames, StatsFuns, Distributions

# Define logistic model under GRM

mutable struct GradedLogistic{T1} <: DiscreteUnivariateDistribution
   a::T1
   b::Vector{T1}
   θ::T1
   function GradedLogistic(a, b, θ)
	   d = new{typeof(θ)}()
	   d.a = a
	   d.b = b
	   d.θ = θ
	   return d
   end
end

function Distributions.rand(s::GradedLogistic)
    K = length(s.b)+1
	b = [-Inf; s.b; Inf]
	p = zeros(K)
	p[1] = cdf(Normal(0,1), s.a*(s.θ - b[1])) - cdf(Normal(0,1), s.a*(s.θ - b[2]))
	for k in 2:K
		p[k] = p[k-1] + cdf(Normal(0,1), s.a*(s.θ - b[k])) - cdf(Normal(0,1), s.a*(s.θ - b[k+1]))
	end
	sum(p .< rand()) + 1
end

function Distributions.logpdf(d::GradedLogistic, k::Int)
	b = d.b
	if 1 < k < length(d.b)-1
		log(cdf(Normal(0,1), d.a*(d.θ - b[k])) - cdf(Normal(0,1), d.a*(d.θ - b[k+1])))
	elseif k == 1
		log(1 - cdf(Normal(0,1), d.a*(d.θ - b[k])))
	else
		log(cdf(Normal(0,1), d.a*(d.θ - b[k-1])))
	end
end

function Distributions.pdf(d::GradedLogistic, k::Int)
	b = d.b
	if 1 < k < length(d.b)-1
		cdf(Normal(0,1), d.a*(d.θ - b[k])) - cdf(Normal(0,1), d.a*(d.θ - b[k+1]))
	elseif k == 1
		1 - cdf(Normal(0,1), d.a*(d.θ - b[k]))
	else
		cdf(Normal(0,1), d.a*(d.θ - b[k-1]))
	end
end

# test
par = GradedLogistic(1.0, [-1.0, 0.0, 1.0], 0.0)
logpdf(par, 4)

@model graded(data) = begin
	N, J = size(data)
    θ = Vector{Real}(undef, N)
	α = Vector{Real}(undef, J)
	β = Vector{Vector}(undef, J)
	β_diff = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector{Real}(undef, K-1)
		β_diff[j] = Vector{Real}(undef, length(cat) - 2)
		for k in 1:length(cat) - 1
		    if k == 1
		        β[j][k] ~ Normal(-3, 1)
		    else
		        β_diff[j][k-1] ~ Normal(0, 1)
		        β[j][k] = β[j][k - 1] + exp(β_diff[j][k-1])
		    end
		end
	end
	# assign distributon to each element
	for i in 1:N
		θ[i] ~ Normal(0, 1)
	end
   	for i in 1:N
		for j in 1:J
			data[i,j] ~ GradedLogistic(α[j], β[j], θ[i])
	    end
    end
end



R"""
a <- matrix(c(.8,.4,.7, .8, .4))
d <- matrix(rep(c(2.0,0.0,-1,-1.5),5), ncol=4, byrow=TRUE)
data <- mirt::simdata(a,d,500, itemtype = rep('graded', 5)) - 1
"""
@rget data

function convert2graded(data)
	N, J = size(data)
	data2 = zeros(Int64, N, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		for (k, v) in enumerate(cat)
			println("Item: ", j, " Observed: ", v, " is converted to Category: ", k)
			data2[data[:,j] .==  v, j] .= k# Int64(k)
		end
	end
	return data2
end
data = convert2graded(data)

chain_NUTS = sample(graded(data), NUTS(0.65), 500);
chain_IS = sample(graded(data), IS(), 5000);
using Plots, StatsPlots
plot(chain_IS[:, :β, :])



chain_IS[:, :θ, :]
