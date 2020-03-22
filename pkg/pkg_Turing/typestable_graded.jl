@model graded(data, ::Type{T} = Float64) where {T} = begin # Well defined model!!
	# 500 subjects, 5 items => 05:00
	N, J = size(data)
    θ = Vector{T}(undef, N)
	α = Vector{T}(undef, J)
	β = Vector{Vector{T}}(undef, J)
	β_diff = Vector{Vector{T}}(undef, J)
	η = zero(T)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
		# Assign normal prior with ordered constraints
		β[j] = Vector{T}(undef, K-1)
		β_diff[j] = Vector{T}(undef, length(cat) - 2)
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
	# θ ~ MvNormal(fill(0, N), 1)
   	for i in 1:N
		for j in 1:J
			η = α[j]*θ[i]
			data[i,j] ~ OrderedLogistic(η, β[j]) # type unstable
	    end
    end
end

model = graded(data)
varinfo = Turing.VarInfo(model)
spl = Turing.SampleFromPrior()
@code_warntype model.f(varinfo, spl, Turing.DefaultContext(), model)

chain_HMCDA = sample(graded(data), HMCDA(200, 0.65, 0.3), 500);
chain_HMCDA = sample(graded(data), NUTS(100, 0.65), 500);
