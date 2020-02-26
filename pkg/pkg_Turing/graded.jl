using Turing, RCall
using DataFrames, StatsFuns, Distributions

# Define logistic model under GRM

struct GradedLogistic{T1} <: DiscreteUnivariateDistribution
   a::T1
   b::Vector{T1}
   θ::T1
end

function Distributions.logpdf(d::GradedLogistic, k::Int)
    K = length(d.b)+1
    b = [-Inf; d.b; Inf]
    log(logistic(d.a*(d.θ - d.b[k])) - logistic(d.a*(d.θ - d.b[k+1])))
end


@model graded(data) = begin
	N, J = size(data)
    θ = Vector(undef, N)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	data2 = zeros(Int64, N, J)
	for j in 1:J
		# Convert raw data
		cat = sort(unique(skipmissing(data[:,j])))
		for (k, v) in enumerate(cat)
			println("Item: ", j, " Category: ", k, " Observed: ", v)
			data2[data[:,j] .==  v, j] .= k
		end
		# Assign normal prior with ordered constraints
	end
   	# assign distributon to each element
   	θ .~ Normal(0, 1)
	α .~ LogNormal(0, 2)
	println("Starts sampling here")   
   	for i = 1:N
		for j = 1:J
			data2[i,j] ~ GradedLogistic(α[j], β[j], θ[i])
	    end
    end
end

R"""
a <- matrix(c(.8,.4,.7, .8, .4, .7, 1, 1, 1, 1))
d <- matrix(rep(c(2.0,0.0,-1,-1.5),10), ncol=4, byrow=TRUE)
data <- mirt::simdata(a,d,2000, itemtype = rep('graded', 10)) - 1
"""
@rget data

chain_NUTS = sample(graded(data), NUTS(0.65), 500);