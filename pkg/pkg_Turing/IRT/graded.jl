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
	p[1] = logistic(s.a*(s.θ - b[1])) - logistic(s.a*(s.θ - b[2]))
	for k in 2:K
		p[k] = p[k-1] + logistic(s.a*(s.θ - b[k])) - logistic(s.a*(s.θ - b[k+1]))
	end
	sum(p .< rand()) + 1
end

function Distributions.logpdf(d::GradedLogistic, k::Int)
	if k == 1
		-softplus(d.a*(d.θ - d.b[k]))
	elseif k ≤ length(d.b)
		log(logistic(d.a*(d.θ - d.b[k-1])) - logistic(d.a*(d.θ - d.b[k])))
	else
		-softplus(-d.a*(d.θ - d.b[k-1]))
	end
end

function Distributions.pdf(d::GradedLogistic, k::Int)
	if k == 1
		1.0 - logistic(d.a*(d.θ - d.b[k]))
	elseif k ≤ length(d.b)
		logistic(d.a*(d.θ - d.b[k-1])) - logistic(d.a*(d.θ - d.b[k]))
	else
		logistic(d.a*(d.θ - d.b[k-1]))
	end
end

@model graded(data) = begin
	N, J = size(data)
    θ = Vector(undef, N)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector(undef, K-1)
		bounds = [-Inf; sort(rand(Normal(0, 2), K-2)); Inf]
		for k in 1:K-1
			β[j][k] ~ truncated(Normal(0, 2), bounds[k], bounds[k+1])
		end
	end
	# assign distributon to each element
	for i in 1:N
		θ[i] ~ Normal(0, 1)
	end
   	for i in 1:N
		for j in 1:J
			# data[i,j] ~ GradedLogistic(α[j], β[j], θ[i])
			data[i,j] ~ OrderedLogistic(α[j]*θ[i], β[j])
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
			data2[data[:,j] .==  v, j] .= k
		end
	end
	return data2
end
data = convert2graded(data)

chain_NUTS = sample(graded(data), HMCDA(200, 0.65, 0.3), 2000);

summarystats(chain_NUTS)

using StatsPlots
plot(chain_NUTS[:, :β, :])



chain_IS[:, :θ, :]
