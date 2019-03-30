# See, https://juliastats.github.io/Distributions.jl/latest/index.html
using Distributions, Compat, Random

# Normal distribution
rand(Normal(), 10) # random variables
pdf(Normal(), 0.5) # probability density function
cdf(Normal(), 0) # cummulative density function
quantile(Normal(), 0.5) # the inverse of cdf
mean(rand(Normal(), 100000000)) # さすがにこれだけ生成しようとすると，すこし重い。
var((1,2,3,4,5,6)) # 標本分散
std((1,2,3,4,5,6)) # 標本標準偏差
# skewness() and kurtosis()

fieldnames(Normal)
# estimate distribution parameters
Sample = rand(Binomial(), 1000)
fit(Normal, Sample)

# Normal distribution's weight
node = range(-4, 4, length = 31)
pdf(Normal(), node)

# Univariate Distributions
# Common Interface
params(Normal()) # Returns tuples of the distribution parameters
scale(Normal())
scale(Cauchy())
scale(Multinomial()) # これはscaleに関するパラメタを持たないのでダメ
location(Gumbel())
shape(Gamma())
rate(Poisson())
ncategories(Multinomial(6, repeat([1/6], 6)))
ntrials(Binomial(10))
succprob(Binomial(10,0.2))
failprob(Bernoulli(0.333))
# Computation of statistics
## とりあえず列挙
# 軸となる値の最大と最小を返す
maximum(Bernoulli())
maximum(Binomial(10))
maximum(Normal())
minimum(BetaBinomial(10, 1, 4))
extrema(Binomial(100)) # 両方をtuplesで返す
# mean(), ver(), std()は先に記したので省略する。
median(Binomial(10, 0.2))
mode(Binomial(10, 0.3))
#modes(Multinomial(6, repeat([1/6], 6))) # Get all modes (if this makes sense).
#rand(BetaBinomial(10, 2, 4), 10)
entropy(Normal())
entropy(Uniform())
entropy(Beta())
mgf(Normal(), 1)
loglikelihood(Binomial(), [0,1,1,0,1,0,1])
invlogccdf(Binomial(), -1)

# Multivariate Distributions
