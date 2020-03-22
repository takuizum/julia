using Turing, RCall
using DataFrames, StatsFuns, Distributions
# using ForwardDiff: ForwardDiff

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

@model graded(data) = begin # Well defined model!!
	N, J = size(data)
    θ = Vector(undef, N)
	α = Vector(undef, J)
	β = Vector{Vector}(undef, J)
	β_diff = Vector{Vector}(undef, J)
	for j in 1:J
		cat = sort(unique(skipmissing(data[:,j])))
		K = length(cat)
		α[j] ~ LogNormal(0, 2)
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
   	for i in 1:N
		for j in 1:J
			η = α[j]*θ[i]
			data[i,j] ~ OrderedLogistic(η, β[j]) # type unstable
			# data[i,j] ~ OrderedProbit(η, β[j])
	    end
    end
end


# Performance check
model = graded(data)
varinfo = Turing.VarInfo(model)
spl = Turing.SampleFromPrior()
@code_warntype model.f(varinfo, spl, Turing.DefaultContext(), model)

# chain_NUTS = sample(graded(data), NUTS(1000, 0.65), 500);
chain_HMCDA = sample(graded(data), HMCDA(200, 0.65, 0.3), 500);
chain_NUTS = sample(graded(data), NUTS(100, 0.65), 500);
chain_Gibbs = sample(graded(data), Gibbs(NUTS(100, 0.65, :α),
										 NUTS(100, 0.65, :β),
										 NUTS(100, 0.65, :β_diff),
										 NUTS(100, 0.65, :θ)
										 ),
					500);


# multiple chain

chain = mapreduce(
				c -> sample(graded(data),
				HMCDA(200, 0.65, 0.3),
				500),
		chainscat,
		1:4);

# check values
summarystats(chain)
summarystats(chain_HMC)

# visualize
using StatsPlots
# densituy
plot(chain[:, :α, :], seriestype = :density)
# chain(trace plot)
tchain = mapreduce(x -> s)

# ADVI
q = ADVI()
chain_vi = vi(graded(data), q)
