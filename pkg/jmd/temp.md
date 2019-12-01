---
title: How to handle DataFrame via `Query.jl`
author: Takumi SHIBUYA
date: 30th Nov 2019
---

# `Query.jl`とは
[`Query.jl`](http://www.queryverse.org/Query.jl/stable/)は`DataFramesMeta`のようにデータフレームを操作するためのパッケージです。
実は必ずしもデータフレームの操作に限らず配列でも扱えます。


<pre class='hljl'>
<span class='hljl-k'>using</span><span class='hljl-t'> </span><span class='hljl-n'>Query</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrames</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-n'>RDatasets</span><span class='hljl-t'>
</span><span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>dataset</span><span class='hljl-p'>(</span><span class='hljl-s'>&quot;datasets&quot;</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-s'>&quot;iris&quot;</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>iris</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span>
</pre>



<table class="data-frame"><thead><tr><th></th><th>SepalLength</th><th>SepalWidth</th><th>PetalLength</th><th>PetalWidth</th><th>Species</th></tr><tr><th></th><th>Float64</th><th>Float64</th><th>Float64</th><th>Float64</th><th>Categorical…</th></tr></thead><tbody><p>5 rows × 5 columns</p><tr><th>1</th><td>5.1</td><td>3.5</td><td>1.4</td><td>0.2</td><td>setosa</td></tr><tr><th>2</th><td>4.9</td><td>3.0</td><td>1.4</td><td>0.2</td><td>setosa</td></tr><tr><th>3</th><td>4.7</td><td>3.2</td><td>1.3</td><td>0.2</td><td>setosa</td></tr><tr><th>4</th><td>4.6</td><td>3.1</td><td>1.5</td><td>0.2</td><td>setosa</td></tr><tr><th>5</th><td>5.0</td><td>3.6</td><td>1.4</td><td>0.2</td><td>setosa</td></tr></tbody></table>


`Query.jl`には2つの異なる操作方法が存在します。
1. Standalone query operators
2. LINQ style queries

----
**Standalone query operators**
基本的にはマクロ&パイプでつなげていく感じ操作をつなげていきます。処理の最後に`DataFrame`関数を噛ませないと，DataFrame形式で出力されません。

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'>
  </span><span class='hljl-nd'>@filter</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>PetalLength</span><span class='hljl-t'> </span><span class='hljl-oB'>.&gt;</span><span class='hljl-t'> </span><span class='hljl-nfB'>1.4</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'>
  </span><span class='hljl-nd'>@groupby</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>Species</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'>
  </span><span class='hljl-nd'>@map</span><span class='hljl-p'>({</span><span class='hljl-n'>Species</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>key</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-p'>),</span><span class='hljl-t'> </span><span class='hljl-n'>SepalLengthTotal</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>sum</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>SepalLength</span><span class='hljl-p'>)})</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-cs'># keyはグループ分けした要素をgetfieldで取得する関数。</span><span class='hljl-t'>
  </span><span class='hljl-n'>DataFrame</span>
</pre>



<table class="data-frame"><thead><tr><th></th><th>Species</th><th>SepalLengthTotal</th></tr><tr><th></th><th>Categorical…</th><th>Float64</th></tr></thead><tbody><p>3 rows × 2 columns</p><tr><th>1</th><td>setosa</td><td>132.8</td></tr><tr><th>2</th><td>versicolor</td><td>296.8</td></tr><tr><th>3</th><td>virginica</td><td>329.4</td></tr></tbody></table>



Command 一覧

- `@map` groupbyしたquery resultに対して用い，指定した列に対してグループごとに任意の関数を適用し，列として返します。関数は無名関数で，一つの要素を受け取る必要があります。関数を適用せず複数の列を指定して返す場合`{}`で囲む必要があります。
- `@filter` 指定した列に対して特定の条件でフィルタリングします。
- `@groupby` 特定の列の要素が同じものどうしでまとまりを作成します。`@groupby`したあとに`@map`でグループごとに統計処理をしたりすることが一般的な使い方です。
- `@orderby` 指定した列の要素でソートをかけます。デフォルトは昇順ですが，降順に変換する亜種`@orderby_descending`もあります。
- `@thenby` `@orderby`でソートしたオブジェクトを受け取り，さらに新たな列をソートする。もし与えられたデータフレームがソートされていなければ，`@orderby`関数と同じように機能します。
- `@groupjoin`
- `@join`
- `@mapmany` 引数の中に現れるアンダースコア`_`は通常の`map(i -> funs(x[i]), I)`における`i`の役割を果たしています。
- `@take` 必ず整数値を引数にとり，何行目までデータを読み込むかを指定します。
- `@drop`　`@take`の逆バージョンで，何行目までのデータを落とすかを指定します。
- `@unique` 指定した列の中でユニークな要素だけを保持します。
- `@select` `DataFramesMeta`の`select`よりもより`dplyr`チックな操作が可能なマクロ。列の位置，正規表現マッチ，symbolなどで任意の列を指定できる。不要な列は`-`をprefixにつけるだけ。
- `@rename` 既存の列を上書きする形で，新しい名前の列を作成して返す。名前は必ずsymbolで指定し，`=`ではなく`=>`でつなぐ。`:old => :new`
- `@mutate` 既存の列名に任意の関数を当てて，新しい列名とともに返す。新しい列の名前が既存のものと同じ場合，上書きされる。`new = funs(old)`という感じ。

**特殊な表記**

アンダースコアはstandalone query syntaxのみで動作する構文で，無名関数の表現をより簡潔に表現してくれます。
例えば`@map(i -> i.a)`は`@map(_.a)`と書くことができます。パイプで連続した処理を行うときは，無名関数で連続してデータフレームを渡していくことになりますが，この表現を使うことで`->`部分の余分な表現を短くしてくれています。
- `_`　第一引数の要素
- `__` 第二引数の要素

---
`@map`

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@map</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>SepalLength</span><span class='hljl-oB'>^</span><span class='hljl-ni'>2</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>collect</span>
</pre>




150-element Array{Float64,1}:
 26.009999999999998
 24.010000000000005
 22.090000000000003
 21.159999999999997
 25.0              
 29.160000000000004
 21.159999999999997
 25.0              
 19.360000000000003
 24.010000000000005
  ⋮                
 47.61000000000001 
 33.64             
 46.239999999999995
 44.89             
 44.89             
 39.69             
 42.25             
 38.440000000000005
 34.81




---
`@filter`

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'>
  </span><span class='hljl-nd'>@filter</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>PetalLength</span><span class='hljl-t'> </span><span class='hljl-oB'>.&gt;</span><span class='hljl-t'> </span><span class='hljl-nfB'>1.4</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'>
  </span><span class='hljl-nd'>@groupby</span><span class='hljl-p'>(</span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>Species</span><span class='hljl-p'>)</span>
</pre>




?-element query result
 NamedTuple{(:SepalLength, :SepalWidth, :PetalLength, :PetalWidth, :Species
),Tuple{Float64,Float64,Float64,Float64,CategoricalString{UInt8}}}[(SepalLe
ngth = 4.6, SepalWidth = 3.1, PetalLength = 1.5, PetalWidth = 0.2, Species 
= "setosa"), (SepalLength = 5.4, SepalWidth = 3.9, PetalLength = 1.7, Petal
Width = 0.4, Species = "setosa"), (SepalLength = 5.0, SepalWidth = 3.4, Pet
alLength = 1.5, PetalWidth = 0.2, Species = "setosa"), (SepalLength = 4.9, 
SepalWidth = 3.1, PetalLength = 1.5, PetalWidth = 0.1, Species = "setosa"),
 (SepalLength = 5.4, SepalWidth = 3.7, PetalLength = 1.5, PetalWidth = 0.2,
 Species = "setosa"), (SepalLength = 4.8, SepalWidth = 3.4, PetalLength = 1
.6, PetalWidth = 0.2, Species = "setosa"), (SepalLength = 5.7, SepalWidth =
 4.4, PetalLength = 1.5, PetalWidth = 0.4, Species = "setosa"), (SepalLengt
h = 5.7, SepalWidth = 3.8, PetalLength = 1.7, PetalWidth = 0.3, Species = "
setosa"), (SepalLength = 5.1, SepalWidth = 3.8, PetalLength = 1.5, PetalWid
th = 0.3, Species = "setosa"), (SepalLength = 5.4, SepalWidth = 3.4, PetalL
ength = 1.7, PetalWidth = 0.2, Species = "setosa")  …  (SepalLength = 4.7, 
SepalWidth = 3.2, PetalLength = 1.6, PetalWidth = 0.2, Species = "setosa"),
 (SepalLength = 4.8, SepalWidth = 3.1, PetalLength = 1.6, PetalWidth = 0.2,
 Species = "setosa"), (SepalLength = 5.4, SepalWidth = 3.4, PetalLength = 1
.5, PetalWidth = 0.4, Species = "setosa"), (SepalLength = 5.2, SepalWidth =
 4.1, PetalLength = 1.5, PetalWidth = 0.1, Species = "setosa"), (SepalLengt
h = 4.9, SepalWidth = 3.1, PetalLength = 1.5, PetalWidth = 0.2, Species = "
setosa"), (SepalLength = 5.1, SepalWidth = 3.4, PetalLength = 1.5, PetalWid
th = 0.2, Species = "setosa"), (SepalLength = 5.0, SepalWidth = 3.5, PetalL
ength = 1.6, PetalWidth = 0.6, Species = "setosa"), (SepalLength = 5.1, Sep
alWidth = 3.8, PetalLength = 1.9, PetalWidth = 0.4, Species = "setosa"), (S
epalLength = 5.1, SepalWidth = 3.8, PetalLength = 1.6, PetalWidth = 0.2, Sp
ecies = "setosa"), (SepalLength = 5.3, SepalWidth = 3.7, PetalLength = 1.5,
 PetalWidth = 0.2, Species = "setosa")]
 NamedTuple{(:SepalLength, :SepalWidth, :PetalLength, :PetalWidth, :Species
),Tuple{Float64,Float64,Float64,Float64,CategoricalString{UInt8}}}[(SepalLe
ngth = 7.0, SepalWidth = 3.2, PetalLength = 4.7, PetalWidth = 1.4, Species 
= "versicolor"), (SepalLength = 6.4, SepalWidth = 3.2, PetalLength = 4.5, P
etalWidth = 1.5, Species = "versicolor"), (SepalLength = 6.9, SepalWidth = 
3.1, PetalLength = 4.9, PetalWidth = 1.5, Species = "versicolor"), (SepalLe
ngth = 5.5, SepalWidth = 2.3, PetalLength = 4.0, PetalWidth = 1.3, Species 
= "versicolor"), (SepalLength = 6.5, SepalWidth = 2.8, PetalLength = 4.6, P
etalWidth = 1.5, Species = "versicolor"), (SepalLength = 5.7, SepalWidth = 
2.8, PetalLength = 4.5, PetalWidth = 1.3, Species = "versicolor"), (SepalLe
ngth = 6.3, SepalWidth = 3.3, PetalLength = 4.7, PetalWidth = 1.6, Species 
= "versicolor"), (SepalLength = 4.9, SepalWidth = 2.4, PetalLength = 3.3, P
etalWidth = 1.0, Species = "versicolor"), (SepalLength = 6.6, SepalWidth = 
2.9, PetalLength = 4.6, PetalWidth = 1.3, Species = "versicolor"), (SepalLe
ngth = 5.2, SepalWidth = 2.7, PetalLength = 3.9, PetalWidth = 1.4, Species 
= "versicolor")  …  (SepalLength = 5.5, SepalWidth = 2.6, PetalLength = 4.4
, PetalWidth = 1.2, Species = "versicolor"), (SepalLength = 6.1, SepalWidth
 = 3.0, PetalLength = 4.6, PetalWidth = 1.4, Species = "versicolor"), (Sepa
lLength = 5.8, SepalWidth = 2.6, PetalLength = 4.0, PetalWidth = 1.2, Speci
es = "versicolor"), (SepalLength = 5.0, SepalWidth = 2.3, PetalLength = 3.3
, PetalWidth = 1.0, Species = "versicolor"), (SepalLength = 5.6, SepalWidth
 = 2.7, PetalLength = 4.2, PetalWidth = 1.3, Species = "versicolor"), (Sepa
lLength = 5.7, SepalWidth = 3.0, PetalLength = 4.2, PetalWidth = 1.2, Speci
es = "versicolor"), (SepalLength = 5.7, SepalWidth = 2.9, PetalLength = 4.2
, PetalWidth = 1.3, Species = "versicolor"), (SepalLength = 6.2, SepalWidth
 = 2.9, PetalLength = 4.3, PetalWidth = 1.3, Species = "versicolor"), (Sepa
lLength = 5.1, SepalWidth = 2.5, PetalLength = 3.0, PetalWidth = 1.1, Speci
es = "versicolor"), (SepalLength = 5.7, SepalWidth = 2.8, PetalLength = 4.1
, PetalWidth = 1.3, Species = "versicolor")]
 NamedTuple{(:SepalLength, :SepalWidth, :PetalLength, :PetalWidth, :Species
),Tuple{Float64,Float64,Float64,Float64,CategoricalString{UInt8}}}[(SepalLe
ngth = 6.3, SepalWidth = 3.3, PetalLength = 6.0, PetalWidth = 2.5, Species 
= "virginica"), (SepalLength = 5.8, SepalWidth = 2.7, PetalLength = 5.1, Pe
talWidth = 1.9, Species = "virginica"), (SepalLength = 7.1, SepalWidth = 3.
0, PetalLength = 5.9, PetalWidth = 2.1, Species = "virginica"), (SepalLengt
h = 6.3, SepalWidth = 2.9, PetalLength = 5.6, PetalWidth = 1.8, Species = "
virginica"), (SepalLength = 6.5, SepalWidth = 3.0, PetalLength = 5.8, Petal
Width = 2.2, Species = "virginica"), (SepalLength = 7.6, SepalWidth = 3.0, 
PetalLength = 6.6, PetalWidth = 2.1, Species = "virginica"), (SepalLength =
 4.9, SepalWidth = 2.5, PetalLength = 4.5, PetalWidth = 1.7, Species = "vir
ginica"), (SepalLength = 7.3, SepalWidth = 2.9, PetalLength = 6.3, PetalWid
th = 1.8, Species = "virginica"), (SepalLength = 6.7, SepalWidth = 2.5, Pet
alLength = 5.8, PetalWidth = 1.8, Species = "virginica"), (SepalLength = 7.
2, SepalWidth = 3.6, PetalLength = 6.1, PetalWidth = 2.5, Species = "virgin
ica")  …  (SepalLength = 6.7, SepalWidth = 3.1, PetalLength = 5.6, PetalWid
th = 2.4, Species = "virginica"), (SepalLength = 6.9, SepalWidth = 3.1, Pet
alLength = 5.1, PetalWidth = 2.3, Species = "virginica"), (SepalLength = 5.
8, SepalWidth = 2.7, PetalLength = 5.1, PetalWidth = 1.9, Species = "virgin
ica"), (SepalLength = 6.8, SepalWidth = 3.2, PetalLength = 5.9, PetalWidth 
= 2.3, Species = "virginica"), (SepalLength = 6.7, SepalWidth = 3.3, PetalL
ength = 5.7, PetalWidth = 2.5, Species = "virginica"), (SepalLength = 6.7, 
SepalWidth = 3.0, PetalLength = 5.2, PetalWidth = 2.3, Species = "virginica
"), (SepalLength = 6.3, SepalWidth = 2.5, PetalLength = 5.0, PetalWidth = 1
.9, Species = "virginica"), (SepalLength = 6.5, SepalWidth = 3.0, PetalLeng
th = 5.2, PetalWidth = 2.0, Species = "virginica"), (SepalLength = 6.2, Sep
alWidth = 3.4, PetalLength = 5.4, PetalWidth = 2.3, Species = "virginica"),
 (SepalLength = 5.9, SepalWidth = 3.0, PetalLength = 5.1, PetalWidth = 1.8,
 Species = "virginica")]




---
`@select`

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@select</span><span class='hljl-p'>(</span><span class='hljl-oB'>-:</span><span class='hljl-n'>Species</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrame</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>-&gt;</span><span class='hljl-t'> </span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@select</span><span class='hljl-p'>(</span><span class='hljl-nf'>occursin</span><span class='hljl-p'>(</span><span class='hljl-s'>&quot;Sepal&quot;</span><span class='hljl-p'>))</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrame</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>-&gt;</span><span class='hljl-t'> </span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@select</span><span class='hljl-p'>(</span><span class='hljl-oB'>-</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-oB'>-</span><span class='hljl-ni'>2</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrame</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>-&gt;</span><span class='hljl-t'> </span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span>
</pre>



<table class="data-frame"><thead><tr><th></th><th>SepalWidth</th><th>PetalWidth</th><th>Species</th></tr><tr><th></th><th>Float64</th><th>Float64</th><th>Categorical…</th></tr></thead><tbody><p>5 rows × 3 columns</p><tr><th>1</th><td>3.5</td><td>0.2</td><td>setosa</td></tr><tr><th>2</th><td>3.0</td><td>0.2</td><td>setosa</td></tr><tr><th>3</th><td>3.2</td><td>0.2</td><td>setosa</td></tr><tr><th>4</th><td>3.1</td><td>0.2</td><td>setosa</td></tr><tr><th>5</th><td>3.6</td><td>0.2</td><td>setosa</td></tr></tbody></table>


---
`@rename`

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@rename</span><span class='hljl-p'>(</span><span class='hljl-sc'>:SepalLength</span><span class='hljl-t'> </span><span class='hljl-oB'>=&gt;</span><span class='hljl-t'> </span><span class='hljl-sc'>:NewSepalLength</span><span class='hljl-t'> </span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrame</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>-&gt;</span><span class='hljl-t'> </span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span>
</pre>



<table class="data-frame"><thead><tr><th></th><th>NewSepalLength</th><th>SepalWidth</th><th>PetalLength</th><th>PetalWidth</th><th>Species</th></tr><tr><th></th><th>Float64</th><th>Float64</th><th>Float64</th><th>Float64</th><th>Categorical…</th></tr></thead><tbody><p>5 rows × 5 columns</p><tr><th>1</th><td>5.1</td><td>3.5</td><td>1.4</td><td>0.2</td><td>setosa</td></tr><tr><th>2</th><td>4.9</td><td>3.0</td><td>1.4</td><td>0.2</td><td>setosa</td></tr><tr><th>3</th><td>4.7</td><td>3.2</td><td>1.3</td><td>0.2</td><td>setosa</td></tr><tr><th>4</th><td>4.6</td><td>3.1</td><td>1.5</td><td>0.2</td><td>setosa</td></tr><tr><th>5</th><td>5.0</td><td>3.6</td><td>1.4</td><td>0.2</td><td>setosa</td></tr></tbody></table>


---
`@mutate`

<pre class='hljl'>
<span class='hljl-n'>iris</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-nd'>@mutate</span><span class='hljl-p'>(</span><span class='hljl-n'>SepalLendthDouble</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-t'> </span><span class='hljl-oB'>*</span><span class='hljl-t'> </span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>SepalLength</span><span class='hljl-p'>,</span><span class='hljl-t'>
                </span><span class='hljl-n'>SepalLength</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-oB'>-</span><span class='hljl-t'> </span><span class='hljl-n'>_</span><span class='hljl-oB'>.</span><span class='hljl-n'>SepalLength</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>DataFrame</span><span class='hljl-t'> </span><span class='hljl-oB'>|&gt;</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>-&gt;</span><span class='hljl-t'> </span><span class='hljl-nf'>first</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>5</span><span class='hljl-p'>)</span>
</pre>



<table class="data-frame"><thead><tr><th></th><th>SepalLength</th><th>SepalWidth</th><th>PetalLength</th><th>PetalWidth</th><th>Species</th><th>SepalLendthDouble</th></tr><tr><th></th><th>Float64</th><th>Float64</th><th>Float64</th><th>Float64</th><th>Categorical…</th><th>Float64</th></tr></thead><tbody><p>5 rows × 6 columns</p><tr><th>1</th><td>-5.1</td><td>3.5</td><td>1.4</td><td>0.2</td><td>setosa</td><td>10.2</td></tr><tr><th>2</th><td>-4.9</td><td>3.0</td><td>1.4</td><td>0.2</td><td>setosa</td><td>9.8</td></tr><tr><th>3</th><td>-4.7</td><td>3.2</td><td>1.3</td><td>0.2</td><td>setosa</td><td>9.4</td></tr><tr><th>4</th><td>-4.6</td><td>3.1</td><td>1.5</td><td>0.2</td><td>setosa</td><td>9.2</td></tr><tr><th>5</th><td>-5.0</td><td>3.6</td><td>1.4</td><td>0.2</td><td>setosa</td><td>10.0</td></tr></tbody></table>

