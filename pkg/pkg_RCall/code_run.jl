using RCall
# forcats
R"""
library(forcats)
x <- haven::labelled(sample(5, 10, replace = TRUE), c(Bad = 1, Good = 5))

list(
# Default method uses values where available
as_factor(x),
# You can also extract just the labels
as_factor(x, levels = "labels"),
# Or just the values
as_factor(x, levels = "values"),
# Or combine value and label
as_factor(x, levels = "both")

)
# }
"""
