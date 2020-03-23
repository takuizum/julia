# symbol
:foo
ans |> typeof

Symbol(:foo, "bar", 9)

#Every Julia program Starts life as a string
prog = "2x + 1"
ex1 = Meta.parse(prog)
typeof(ex1)

dump(ex1)

# Starts life as a symbol
ex2 = :(2x + 1)
typeof(ex2)
dump(ex2)

# Multiple line quote
ex3 = quote
    x = 0
    y = 2x+1
    x + y
end
typeof(ex3)
dump(ex3)

# Interpolation of AST
ex = 1;
:(2x + $(ex))

# Interpolation of AST (target is Symbol)
