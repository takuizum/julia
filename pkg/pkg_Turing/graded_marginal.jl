using Turing
@model graded(data) = begin
    N, J = size(data)
    M = 31 # N of nodes
    node = range(-4, stop = 4; length = M)
    θ = zeros(Float64, N, M)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector(undef, length(cat) - 1)
		for k in 1:K-1
			if k == 1
				β[j][k] ~ truncated(Normal(0, 2), -Inf, β[j][k+1])
			elseif 1 < k < K-1
				β[j][k] ~ truncated(Normal(0, 2), β[j][k], β[j][k+1])
			else # if k == K-1
				β[j][k] ~ truncated(Normal(0, 2), β[j][k], Inf)
			end
		end
	end
	# assign distributon to each element
    for i in 1:N, m in 1:M, j in 1:J
        θ[i, m] += logpdf(GradedLogistic(α[j], β[j], node[m]), data[i,j])[1] + logpdf.(Normal(0, 1), node[m])
	end
   	for i in 1:N
        for j in 1:J
            for m in 1:M
                data[i,j] ~ GradedLogistic(α[j], β[j], θ[i, m])
            end
	    end
    end
end

chain_IS = sample(graded(data), IS(), 500);
