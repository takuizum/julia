# types

# type operator
# 任意の型を変数に与えるためには`::`を用いる

変数 = (1 + 2)::Int
typeof(変数)

変数::Float16 # これはダメ
変数2 = (1 + 2)::Float16
変数2::Float16
変数2 = (1+2.1)
typeof(変数2) # ????
convert(Int64,変数2) # これはだめ。小数点以下があるので，Int型に変換できない。
convert(Float16,変数2);typeof(変数2)


# USER DEFINED TYPE
# 極座標向けの型を用意する

struct Polor{T<:Real} <: Number # <: はサブタイプを表す演算子。つまり，TはRealに含まれ，その関数であるPolorはNumberに含まれる
    θ::T
    r::T
end

Polar(r::Real,Θ::Real) = Polar(promote(r,Θ)...) # より大きな型に昇格させる`promote`
typeof(Polor)
Polor(3.0, 1.0) # ただ型を返すだけ
# さらにstructを制御して，与えた変数を表示するように細かく制御する。
Base.show(io::IO, z::Polor) = print(io, z.r, "* exp", z.θ, "im")

# Base.show{T}(io::IO, ::MIME"text/plain", z::Polar{T}) = print(io, "Polar{$T} complex number:\n   ", z)
Polar(3, 2.0)
