using Pkg

pac = [
    "Queryverse", # DataSci
    "Optim", # Numerical Optimization
    "Statistics", # Statistical function
    "StatsFuns", 
    "StatsBase", 
    "Distributions", # Probability distribution
    "RCall", # Calling R
    "PyCall", 
    "PyPlot", 
    "Conda", 
    "Weave"
]

Pkg.add.(pac)