using Turing
@model graded_marginal(data) = begin
    N, J = size(data)
    M = 31 # N of nodes
	node = Vector{Real}(undef, M)
    node = range(-4, stop = 4; length = M)
	weight = pdf.(Normal(0, 1), node) ./ sum(pdf.(Normal(0, 1), node))
    θ = Matrix{Real}(undef, N, M)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	β_diff = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector{Real}(undef, K-1)
		β_diff[j] = Vector{Real}(undef, length(cat) - 2)
		for k in 1:K - 1
		    if k == 1
		        β[j][k] ~ Normal(-3, 1)
		    else
		        β_diff[j][k-1] ~ Normal(0, 1)
		        β[j][k] = β[j][k - 1] + exp(β_diff[j][k-1])
		    end
		end
	end
	# assign distributon to each element
	for i in 1:N, m in 1:M
		θ[i, m] = 0.0
	end
    for i in 1:N, m in 1:M, j in 1:J
        θ[i, m] += logpdf(OrderedLogistic(α[j] * node[m], β[j]), data[i,j]) * weight[m]
	end
   	for i in 1:N
        for j in 1:J
            for m in 1:M
                data[i,j] ~ OrderedLogistic(α[j] * θ[i, m], β[j])
            end
	    end
    end
end

chain_NUTS = sample(graded_marginal(data), NUTS(0.65), 500);
