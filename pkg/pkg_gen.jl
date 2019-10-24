# Gen tutorial
using Gen, PyPlot

# writing a >probabilistic model as a generative function

@gen function line_model(xs::Vector{Float64})
    n = length(xs)
    
    # We begin by sampling a slope and intercept for the line.
    # Before we have seen the data, we don't know the values of
    # these parameters, so we treat them as random choices. The
    # distributions they are drawn from represent our prior beliefs
    # about the parameters: in this case, that neither the slope nor the
    # intercept will be more than a couple points away from 0.
    slope = @trace(normal(0, 1), :slope)
    intercept = @trace(normal(0, 2), :intercept)
    
    # Given the slope and intercept, we can sample y coordinates
    # for each of the x coordinates in our input vector.
    for (i, x) in enumerate(xs)
        @trace(normal(slope * x + intercept, 0.1), (:y, i))
    end
    
    # The return value of the model is often not particularly important,
    # Here, we simply return n, the number of points.
    return n
end;

@gen function quadline_model(xs::Vector{Float64})
    n = length(xs)
    slope1 = @trace(normal(0, 3), :slope1)
    slope2 = @trace(normal(0, 3), :slope2)
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
    plot([xmin:.1:xmax;], slope1*[xmin:.1:xmax;] .+ slope2*[xmin:.1:xmax;] .+ intercept, color="black", alpha=0.5)
    ax = gca()
    ax.set_xlim((xmin, xmax))
    ax.set_ylim((xmin, xmax))
end;
figure(figsize=(3,3))
render_trace(trace);

# Doing Posterior inference

ys = [6.75003, 6.1568, 4.26414, 1.84894, 3.09686, 1.94026, 1.36411, -0.83959, -0.976, -1.93363, -2.91303];
figure(figsize=(3,3))
scatter(xs, ys, color="black");

function do_inference(model, xs, ys, amount_of_computation)
    
    # Create a choice map that maps model addresses (:y, i)
    # to observed values ys[i]. We leave :slope and :intercept
    # unconstrained, because we want them to be inferred.
    observations = Gen.choicemap()
    for (i, y) in enumerate(ys)
        observations[(:y, i)] = y
    end
    
    # Call importance_resampling to obtain a likely trace consistent
    # with our observations.
    (trace, _) = Gen.importance_resampling(model, (xs,), observations, amount_of_computation);
    return trace
end;

trace = do_inference(quadline_model, xs, ys, 100000)
figure(figsize=(3,3))
render_trace(trace);
display(gcf()) # Plotを表示