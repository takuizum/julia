# Gen tutorial
using Gen, PyPlot

# writing a >probabilistic model as a generative function
@gen function quadline_model(xs::Vector{Float64})
    n = length(xs)
    slope1 = @trace(normal(0, 1), :slope1)
    slope2 = @trace(normal(0, 1), :slope2)
    intercept = @trace(normal(0, 2), :intercept)
    for (i, x) in enumerate(xs) # `enumerate` returns iterator and value
        # `@trace` draws random values from posterior distribution
        @trace(normal(slope1 * x + slope2*x^2 + intercept, 0.1), (:y, i))
    end
    return n
end;
# xcoordinate values
xs = [-5., -4., -3., -.2, -1., 0., 1., 2., 3., 4., 5.];
n = quadline_model(xs)
# Data Gen
trace = Gen.simulate(quadline_model, (xs,));
println(trace)
Gen.get_args(trace)
# Show random pars
println(Gen.get_choices(trace))
choices = Gen.get_choices(trace)
println(choices[:slope1])

println(Gen.get_retval(trace))
# Visualizing trace plot
function render_trace(trace; show_data=true)
    
    # Pull out xs from the trace
    xs = get_args(trace)[1]
    
    xmin = minimum(xs)
    xmax = maximum(xs)
    if show_data
        ys = [trace[(:y, i)] for i=1:length(xs)]
        
        # Plot the data set
        scatter(xs, ys, c="black")
    end
    
    # Pull out slope and intercept from the trace
    slope1 = trace[:slope1]
    slope2 = trace[:slope2]    
    intercept = trace[:intercept]
    
    # Draw the line
    plot([xmin, xmax], slope1*[xmin, xmax] .+ slope2*[xmin, xmax] .+ intercept, color="black", alpha=0.5)
    ax = gca()
    ax[:set_xlim]((xmin, xmax))
    ax[:set_ylim]((xmin, xmax))
end;
figure(figsize=(3,3))
render_trace(trace);