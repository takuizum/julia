using Turing
using Turing.RandomMeasures

# Dirichlet process example

function DPexample(P, α = 10.0)
    # Concentration parameter.
    # α

    # Random measure, e.g. Dirichlet process.
    rpm = DirichletProcess(α)

    # Cluster assignments for each observation.
    z = Vector{Int}()

    # Maximum number of observations we observe.
    # P
    for i in 1:P
        # Number of observations per cluster.
        K = isempty(z) ? 0 : maximum(z)
        nk = Vector{Int}(map(k -> sum(z .== k), 1:K))

        # Draw new assignment.
        push!(z, rand(ChineseRestaurantProcess(rpm, nk)))
    end
    return z
end


z = DPexample(500)

using Plots

# Plot the cluster assignments over time
anim = @gif for i in 1:length(z)
    scatter(collect(1:i), z[1:i], markersize = 2, xlabel = "observation (i)", ylabel = "cluster (k)", legend = false, title = "observation $i")
end;
anim

# Infinit Gaussian Mixuture model with Dirichlet Process
@model infiniteGMM(x) = begin

    # Hyper-parameters, i.e. concentration parameter and parameters of H.
    α = 1.0
    μ0 = 0.0
    σ0 = 1.0

    # Define random measure, e.g. Dirichlet process.
    rpm = DirichletProcess(α)

    # Define the base distribution, i.e. expected value of the Dirichlet process.
    H = Normal(μ0, σ0)

    # Latent assignment.
    z = tzeros(Int, length(x))

    # Locations of the infinitely many clusters.
    μ = tzeros(Float64, 0)

    for i in 1:length(x)

        # Number of clusters.
        K = maximum(z)
        nk = Vector{Int}(map(k -> sum(z .== k), 1:K))

        # Draw the latent assignment.
        z[i] ~ ChineseRestaurantProcess(rpm, nk)

        # Create a new cluster?
        if z[i] > K
            push!(μ, 0.0)

            # Draw location of new cluster.
            μ[z[i]] ~ H
        end

        # Draw observation.
        x[i] ~ Normal(μ[z[i]], 1.0)
    end
end

using Plots, Random
# Generate some test data.
Random.seed!(1)
data = vcat(randn(10), randn(10) .- 5, randn(10) .+ 10)
data .-= mean(data)
data /= std(data);
# MCMC sampling
Random.seed!(2)
iterations = 1000
model_fun = infiniteGMM(data);
chain = sample(model_fun, SMC(), iterations);
# Extract the number of clusters for each sample of the Markov chain.
k = map(t -> length(unique(chain[:z].value[t,:,:])), 1:iterations);

# Visualize the number of clusters.
plot(k, xlabel = "Iteration", ylabel = "Number of clusters", label = "Chain 1")
