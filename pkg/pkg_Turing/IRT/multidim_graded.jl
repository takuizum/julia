@model MGraded(pre, post) = begin # Well defined model!!
	N1, J = size(pre)
	N2 = size(post, 1)
    θ_pre = Matrix(undef, N, 2)
	θ_post = Matrix(undef, N, 2)
	α = Matrix(undef, J, 2)
	β = Vector{Vector}(undef, J)
	β_diff = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ MvLogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector(undef, K-1)
		β_diff[j] = Vector(undef, length(cat) - 2)
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
	for i in 1:N
		θ[i] ~ Normal(0, 1)
	end
	# θ ~ MvNormal(fill(0.0, N), 1.0)
	η = Real[]
   	for i in 1:N
		for j in 1:J
			η = α[j]*θ[i]
			data[i,j] ~ OrderedLogistic(η, β[j]) # type unstable
			# data[i,j] ~ OrderedProbit(η, β[j])
	    end
    end
end
