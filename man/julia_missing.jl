# missing
# missing in julia is equivalent to NA in R
#  missing values propagate automatically when passed to standard operators and functions, in particular mathematical functions.
# behavior

# 以下はすべてmissing
missing + 1  # missing
"abc" * missing
abs(missing)
missing == missing
missing > 1
missing <= "abc"


# ismissing()
ismissing(missing) # true

# special comparison
# isequal
isequal(missing, missing)
missing === 1
# isless
isless(1, 2)
isless(2, 1)
isless(missing, 1)
isless(1, missing)
isless(missing, missing)

# logical operators
true | missing # missingは基本的に評価されない，としてら，この結果にも納得できる
true || missing
false | missing
false || missing

true & missing
true && missing
false & missing
false && missing

missing || false # !?
missing && true
missing | false
missing & true
