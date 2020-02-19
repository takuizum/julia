---
title: 入門julia
author: Takumi SHIBUYA
date: 23th Jan 2020
---


# 演算子(Numerical Operator)

行列に対する演算はデフォルトで実装されているので，特にライブラリを読み込む必要はない。


<pre class='hljl'>
<span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-oB'>+</span><span class='hljl-t'> </span><span class='hljl-ni'>1</span><span class='hljl-t'>
</span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-ni'>1</span><span class='hljl-t'>
</span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>+=</span><span class='hljl-t'> </span><span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-cs'># Updating version</span><span class='hljl-t'>
</span><span class='hljl-ni'>10</span><span class='hljl-t'> </span><span class='hljl-oB'>/</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-cs'># divide</span><span class='hljl-t'>
</span><span class='hljl-ni'>10</span><span class='hljl-t'> </span><span class='hljl-oB'>÷</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-cs'># integer divide</span><span class='hljl-t'>
</span><span class='hljl-ni'>10</span><span class='hljl-t'> </span><span class='hljl-oB'>%</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-cs'># remainder</span><span class='hljl-t'>
</span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-ni'>4</span><span class='hljl-p'>]</span><span class='hljl-t'> </span><span class='hljl-oB'>\</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>]</span><span class='hljl-t'> </span><span class='hljl-cs'># inverse (matrix) divide</span><span class='hljl-t'>
</span><span class='hljl-ni'>2</span><span class='hljl-t'> </span><span class='hljl-oB'>^</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-cs'># power</span><span class='hljl-t'>
</span><span class='hljl-s'>&quot;abc &quot;</span><span class='hljl-t'> </span><span class='hljl-oB'>^</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span>
</pre>




"abc abc abc "





掛け算はRとはちょっとちがう。


<pre class='hljl'>
<span class='hljl-cs'># times</span><span class='hljl-t'>
</span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-ni'>3</span><span class='hljl-t'> </span><span class='hljl-ni'>4</span><span class='hljl-p'>]</span><span class='hljl-t'> </span><span class='hljl-oB'>*</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>]</span>
</pre>




2-element Array{Int64,1}:
  5
 11




<pre class='hljl'>
<span class='hljl-ni'>2</span><span class='hljl-t'> </span><span class='hljl-oB'>*</span><span class='hljl-t'> </span><span class='hljl-ni'>10</span>
</pre>




20




<pre class='hljl'>
<span class='hljl-s'>&quot;abcd&quot;</span><span class='hljl-t'> </span><span class='hljl-oB'>*</span><span class='hljl-t'> </span><span class='hljl-s'>&quot;efgh&quot;</span>
</pre>




"abcdefgh"





### ベクトル演算



<pre class='hljl'>
<span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>range</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>10000</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-n'>step</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-nf'>sum</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>);</span><span class='hljl-t'> </span><span class='hljl-cs'># compile</span><span class='hljl-t'>
</span><span class='hljl-nd'>@time</span><span class='hljl-t'> </span><span class='hljl-nf'>sum</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span>
</pre>




0.000002 seconds (5 allocations: 176 bytes)
25000000




<pre class='hljl'>
<span class='hljl-k'>function</span><span class='hljl-t'> </span><span class='hljl-nf'>mysum</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span><span class='hljl-t'>
    </span><span class='hljl-n'>y</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>zero</span><span class='hljl-p'>(</span><span class='hljl-nf'>eltype</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>))</span><span class='hljl-t'> </span><span class='hljl-cs'># ここが計算速度のミソ</span><span class='hljl-t'>
    </span><span class='hljl-k'>for</span><span class='hljl-t'> </span><span class='hljl-n'>v</span><span class='hljl-t'> </span><span class='hljl-kp'>in</span><span class='hljl-t'> </span><span class='hljl-n'>x</span><span class='hljl-t'>
        </span><span class='hljl-n'>y</span><span class='hljl-t'> </span><span class='hljl-oB'>+=</span><span class='hljl-t'> </span><span class='hljl-n'>v</span><span class='hljl-t'>
    </span><span class='hljl-k'>end</span><span class='hljl-t'>
    </span><span class='hljl-k'>return</span><span class='hljl-t'> </span><span class='hljl-n'>y</span><span class='hljl-t'>
</span><span class='hljl-k'>end</span><span class='hljl-t'>
</span><span class='hljl-nf'>mysum</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-nd'>@time</span><span class='hljl-t'> </span><span class='hljl-nf'>mysum</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-cs'># ベクトル演算しても，loopで計算してもほぼ実行速度が変わらない！</span>
</pre>




0.000004 seconds (5 allocations: 176 bytes)
25000000





ベクトルに対して繰り返し操作する場合はdot syntaxを利用すると効率的。


<pre class='hljl'>
<span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-oB'>:</span><span class='hljl-ni'>2</span><span class='hljl-oB'>:</span><span class='hljl-ni'>10000</span><span class='hljl-p'>;]</span><span class='hljl-t'> </span><span class='hljl-cs'># Array</span><span class='hljl-t'>
</span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>.+</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span>
</pre>




5000-element Array{Int64,1}:
     3
     5
     7
     9
    11
    13
    15
    17
    19
    21
     ⋮
  9985
  9987
  9989
  9991
  9993
  9995
  9997
  9999
 10001




<pre class='hljl'>
<span class='hljl-ni'>2</span><span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-cs'># times はベクトルに対しても定義されているので，dotなしで使える。</span>
</pre>




5000-element Array{Int64,1}:
     2
     6
    10
    14
    18
    22
    26
    30
    34
    38
     ⋮
 19966
 19970
 19974
 19978
 19982
 19986
 19990
 19994
 19998




# 型(Types)

- 静的型付け 関数が実行される前に（コンパイル時に），変数の型は宣言されている必要がある
- 動的型付け　関数が実行されるまで，変数の型がわからず，仮に関数の挙動に合わない型が投げられた場合，強制的に変換されるか，エラーになる，


<pre class='hljl'>
<span class='hljl-k'>function</span><span class='hljl-t'> </span><span class='hljl-nf'>foo</span><span class='hljl-p'>()</span><span class='hljl-t'>
    </span><span class='hljl-n'>x</span><span class='hljl-oB'>::</span><span class='hljl-n'>Int64</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-cs'># こんな感じで定義する。</span><span class='hljl-t'>
    </span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-k'>end</span>
</pre>




foo (generic function with 1 method)





## 抽象型

すべての抽象型は上位の型（super type)を持つことができる。


<pre class='hljl'>
<span class='hljl-k'>abstract type</span><span class='hljl-t'> </span><span class='hljl-n'>Number</span><span class='hljl-t'> </span><span class='hljl-k'>end</span><span class='hljl-t'>
</span><span class='hljl-k'>abstract type</span><span class='hljl-t'> </span><span class='hljl-n'>Real</span><span class='hljl-t'> </span><span class='hljl-oB'>&lt;:</span><span class='hljl-t'> </span><span class='hljl-n'>Number</span><span class='hljl-t'> </span><span class='hljl-k'>end</span><span class='hljl-t'>
</span><span class='hljl-k'>abstract type</span><span class='hljl-t'> </span><span class='hljl-n'>AbstractFloat</span><span class='hljl-t'> </span><span class='hljl-oB'>&lt;:</span><span class='hljl-t'> </span><span class='hljl-n'>Real</span><span class='hljl-t'> </span><span class='hljl-k'>end</span>
</pre>





## 原始型

データのビットで構成される具象(concrete)型


<pre class='hljl'>
<span class='hljl-k'>primitive type</span><span class='hljl-t'> </span><span class='hljl-n'>Float64</span><span class='hljl-t'> </span><span class='hljl-oB'>&lt;:</span><span class='hljl-t'> </span><span class='hljl-n'>AbstractFloat</span><span class='hljl-t'> </span><span class='hljl-ni'>64</span><span class='hljl-t'> </span><span class='hljl-k'>end</span>
</pre>





### 論理型(Boolen)


<pre class='hljl'>
<span class='hljl-kc'>true</span><span class='hljl-p'>;</span><span class='hljl-t'>
</span><span class='hljl-kc'>false</span><span class='hljl-p'>;</span><span class='hljl-t'>
</span><span class='hljl-oB'>!</span><span class='hljl-kc'>true</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-cs'># not</span><span class='hljl-t'>

</span><span class='hljl-kc'>true</span><span class='hljl-t'> </span><span class='hljl-oB'>&amp;&amp;</span><span class='hljl-t'> </span><span class='hljl-kc'>false</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-cs'># and</span><span class='hljl-t'>
</span><span class='hljl-kc'>true</span><span class='hljl-t'> </span><span class='hljl-oB'>||</span><span class='hljl-t'> </span><span class='hljl-kc'>false</span><span class='hljl-p'>;</span><span class='hljl-t'> </span><span class='hljl-cs'># or</span>
</pre>





### 数値型(Numebers

8ビットから64ビットまで任意に指定できる。なにも指定しなければ，64ビットになる。

整数型の`Int`と浮動小数点型の`Float`がある。


<pre class='hljl'>
<span class='hljl-ni'>1</span><span class='hljl-t'> </span><span class='hljl-oB'>==</span><span class='hljl-t'> </span><span class='hljl-nfB'>1.0</span>
</pre>




true




<pre class='hljl'>
<span class='hljl-nf'>typeof</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>)</span>
</pre>




Int64




<pre class='hljl'>
<span class='hljl-nf'>typeof</span><span class='hljl-p'>(</span><span class='hljl-nfB'>1.0</span><span class='hljl-p'>)</span>
</pre>




Float64





## 複合型

複数の要素を持つ型。別名，構造体(struct)とかオブジェクト(object)などと呼ばれる。

### 構造体(Construct)

juliaでオブジェクト≈インスタンスを作成するための関数が`struct`である。


<pre class='hljl'>
<span class='hljl-cs'># Constructor</span><span class='hljl-t'>
</span><span class='hljl-k'>struct</span><span class='hljl-t'> </span><span class='hljl-n'>hoge</span><span class='hljl-t'>
    </span><span class='hljl-n'>huga</span><span class='hljl-t'>
    </span><span class='hljl-n'>piyo</span><span class='hljl-t'>
</span><span class='hljl-k'>end</span>
</pre>





定義するときは関数のように


<pre class='hljl'>
<span class='hljl-n'>hoge1</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>hoge</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-ni'>2</span><span class='hljl-p'>])</span>
</pre>




Main.WeaveSandBox6.hoge(1, [1, 2])





呼び出す際は

<pre class='hljl'>
<span class='hljl-n'>hoge1</span><span class='hljl-oB'>.</span><span class='hljl-n'>huga</span>
</pre>




1





### Parametric Constructor

<pre class='hljl'>
<span class='hljl-k'>struct</span><span class='hljl-t'> </span><span class='hljl-nf'>phoge</span><span class='hljl-p'>{</span><span class='hljl-n'>T</span><span class='hljl-oB'>&lt;:</span><span class='hljl-n'>Real</span><span class='hljl-p'>}</span><span class='hljl-t'>
    </span><span class='hljl-n'>piyp</span><span class='hljl-oB'>::</span><span class='hljl-n'>T</span><span class='hljl-t'>
    </span><span class='hljl-n'>huga</span><span class='hljl-oB'>::</span><span class='hljl-n'>T</span><span class='hljl-t'>
</span><span class='hljl-k'>end</span><span class='hljl-p'>;</span>
</pre>




<pre class='hljl'>
<span class='hljl-n'>phoge1</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>phoge</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>1</span><span class='hljl-p'>)</span>
</pre>


<pre class="julia-error">
ERROR: MethodError: no method matching Main.WeaveSandBox6.phoge&#40;::Int64, ::Int64&#41;
</pre>



<pre class='hljl'>
<span class='hljl-n'>phoge2</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>phoge</span><span class='hljl-p'>(</span><span class='hljl-nfB'>1.</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-nfB'>1.</span><span class='hljl-p'>)</span>
</pre>


<pre class="julia-error">
ERROR: MethodError: no method matching Main.WeaveSandBox6.phoge&#40;::Float64, ::Float64&#41;
</pre>



<pre class='hljl'>
<span class='hljl-n'>phoge3</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>phoge</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-nfB'>3.0</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-cs'># Error (2つの値の型が異なるため。)</span>
</pre>


<pre class="julia-error">
ERROR: MethodError: no method matching Main.WeaveSandBox6.phoge&#40;::Int64, ::Float64&#41;
</pre>



### Mutable Constructor

<pre class='hljl'>
<span class='hljl-k'>mutable struct</span><span class='hljl-t'> </span><span class='hljl-n'>mhoge</span><span class='hljl-t'>
    </span><span class='hljl-n'>piyo</span><span class='hljl-t'>
    </span><span class='hljl-n'>huga</span><span class='hljl-t'>
</span><span class='hljl-k'>end</span><span class='hljl-t'>
</span><span class='hljl-n'>hoge2</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>mhoge</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-n'>hoge2</span>
</pre>




Main.WeaveSandBox6.mhoge(1, 2)




<pre class='hljl'>
<span class='hljl-n'>hoge2</span><span class='hljl-oB'>.</span><span class='hljl-n'>piyo</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-ni'>2</span><span class='hljl-t'>
</span><span class='hljl-n'>hoge2</span>
</pre>




Main.WeaveSandBox6.mhoge(2, 2)





### 多重ディスパッチ

- メソッド(Methods) : 受け取ったオブジェクトによって定義される関数の挙動。
- 総称関数(generic function) : 複数のメソッドが定義できる関数。受け取る引数によって，関数の挙動が変わる。
- ディスパッチ(dispatch) : 関数が実行されたときに，どのメソッドが処理されるかどうかを選択すること。

関数の複数の引数を参照してディスパッチすることを多重ディスパッチと呼ぶ。
juliaではすべての関数で多重ディスパッチが実行され，RではS4クラスによってサポートされる。

例えば，Rの`coef`や`anova`は様々なパッケージによってメソッドが定義されており，引数に渡すオブジェクトの型(class)ごとに異なる挙動をする。

juliaではすべての関数が総称関数であり，関数は与えられた引数から適切なメソッドを参照する。
juliaでメソッドを定義するためには，通常の関数を書くときに，引数の型を明示的に宣言すればよい。


<pre class='hljl'>
<span class='hljl-nf'>f</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-oB'>::</span><span class='hljl-n'>Float64</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-s'>&quot;This is Float64!&quot;</span><span class='hljl-p'>)</span><span class='hljl-t'>
</span><span class='hljl-nf'>f</span><span class='hljl-p'>(</span><span class='hljl-n'>x</span><span class='hljl-oB'>::</span><span class='hljl-n'>Int64</span><span class='hljl-p'>)</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-s'>&quot;This is Int64!&quot;</span><span class='hljl-p'>)</span>
</pre>




f (generic function with 2 methods)




<pre class='hljl'>
<span class='hljl-nf'>f</span><span class='hljl-p'>(</span><span class='hljl-ni'>1</span><span class='hljl-p'>)</span>
</pre>




This is Int64!




<pre class='hljl'>
<span class='hljl-nf'>f</span><span class='hljl-p'>(</span><span class='hljl-nfB'>1.0</span><span class='hljl-p'>)</span>
</pre>


<pre class="julia-error">
ERROR: MethodError: no method matching f&#40;::Float64&#41;
Closest candidates are:
  f&#40;&#33;Matched::Int64&#41; at none:1
  f&#40;&#33;Matched::Main.WeaveSandBox6.Float64&#41; at none:1
</pre>





# Julia Performance Tipes

https://docs.julialang.org/en/v1/manual/performance-tips/

1. グローバル変数は避ける。

2. `@time`や`Profirer`でマメにメモリ消費などを確認する。

3. 抽象型よりも具象型を使うようにする。

4. 複数の処理は，小さな関数のまとまりとして書く。

5. "type-stable"なコードを書く。　　

6. 多重ディスパッチの乱用に注意。

https://groups.google.com/forum/#!msg/julia-users/jUMu9A3QKQQ/qjgVWr7vAwAJ

7. 配列のアクセスはカラムメジャー（Rと同じ，numpyはロウメジャー）

8. 配列を作りすぎない（事前に配列を初期化しておき，そこにアクセスする）

9. ベクトル演算にはdot syntaxを使う。

10. `@view` マクロで配列のスライスを使う。

