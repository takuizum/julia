# types
# In julia, the :: operator can be used to attach type annotations to expressions and variables in programs

typeof(1+2)
typeof((1+2)::Int)

# local declaration
local x::Int8
typeof(x)

y::Int8 = 10
