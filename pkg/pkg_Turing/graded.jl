using Turing, RCall
using DataFrames, StatsFuns, Distributions

# Define logistic model under GRM

struct GradedLogistic{T1} <: DiscreteUnivariateDistribution
   a::T1
   b::Vector{T1}
   θ::T1
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
	b = [-Inf; d.b; Inf]
    log(logistic(d.a*(d.θ - b[k])) - logistic(d.a*(d.θ - b[k+1])))
end

function Distributions.pdf(d::GradedLogistic, k::Int)
	b = [-Inf; d.b; Inf]
    logistic(d.a*(d.θ - b[k])) - logistic(d.a*(d.θ - b[k+1]))
end


@model graded(data) = begin
	N, J = size(data)
    θ = Vector(undef, N)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	β_diff = Vector{Vector}(undef, J)
	data2 = zeros(Int64, N, J)
	for j in 1:J
		# Convert raw data
		cat = sort(unique(skipmissing(data[:,j])))
		for (k, v) in enumerate(cat)
			# println("Item: ", j, " Observed: ", v, " is converted to Category: ", k)
			data2[data[:,j] .==  v, j] .= k
		end
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector(undef, length(cat) - 1)
		β_diff[j] = Vector(undef, length(cat) - 2)
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
	
	@show β
	# println("Starts sampling here")   
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