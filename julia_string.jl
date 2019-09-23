# julia string
＃ string
Char(111) # unicode point character
Char(0110)
Char(0111)
# その逆
Int('n') # シングルクオートは文字リテラルを表現する。

println("test\ntest")

for i = 1:100
    #println(i, "\r")
    println(i)
end

stri = "Hello, world.\n"
stri[2] # 文字のアクセスも非常に楽
stri[end]

stri2 = "吾輩は猫である"
stri2[1]
SubString(stri, 1:5)
SubString(stri2, 1:4)
SubString(stri2, 1:5) # 全角は2の倍数で

string("abc", stri2)

# 補完内挿 interpolation
"$stri2 は夏目漱石の著作である"
"1 + 2 = $(1 + 2)"

# String Library
uppercase("Hello")
lowercase("BAKE")

# 文字列のサーチ
# 位置
findfirst(isequal('a'), "abcdefabab", )
findfirst("a", "abcdefabab", )
findlast(isequal('a'), "abcdefabab")

# マッチ
occursin("A", "abcd")
occursin("A", "Abcd")
'a' ∈ "banana"
"a" == 'a' # !?!?!?!?!?
# マッチした文字列を取得
function inboth(word1, word2)
    for letter in word1
        if letter ∈ word2
            print(letter, " ")
        end
    end
end
inboth("apples", "berry")
inboth("apples", "oranges")

# 文字列比較
"banana" > "apples"
function wordcomp(lhs, rhs)
    if lhs < rhs
        print("$lhs comes BEFORE $rhs .")
    elseif lhs > rhs
        print("$lhs comes AFTER $rhs .")
    else
        print("All right, $lhs")
    end
end
wordcomp("male", "female")
wordcomp(1,2)

# 複製
repeat("abc", 5)
"abc"^5
# 結合
join(["a", "b", "c"], " and ", ", ")
"a"*"b"*"c"
# minimal bite index
"abcd" |> firstindex
"bcda" |> firstindex
# length
# arrayにすれば単語単位で数える？というかArrayの長さかな？
["I", "am", "a", "super", "star"] |> length　
"I am a super star" |> length # これだと1文字ごとに数える

length("I am a super star" , 1, 5)

# Regular Expressions
# r""で正規表現を呼び出せるのか
occursin(r"#", "# is a comment")
match(r"#", "# is a comment")
match(r"#", "sharp string is a comment") # returns nothing
match(r"[a-z]", "1234567890a12345", 1)
match(r"[a-z]", "1234567890a12345", 13) # 3つ目の引数はserchをはじめる位置
