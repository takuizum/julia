##
# DataFrames で tidy なデータ整形とモデリング
using DataFrames, DataFramesMeta, RDatasets, StatsPlots, GLM
data = RDatasets.dataset("mlmRev", "star")
@show first(data, 10)

# 動作がおそすぎて実行確認できていない。
# using BrowseTables, Tables
# open_html_table(data)
@show describe(data)
@df data StatsPlots.scatter(:Read, :Math)

# よりggplot2ライクなプロットならこちら
using Gadfly, Compose, Cairo, Fontconfig
data.Read
data_rm_missing = @linq data |>
   where(isa.(:Read, Int32), isa.(:Math, Int32))

plt = Gadfly.plot(data_rm_missing, x = :Read, y = :Math, color = :SES, Geom.point)
draw(Compose.PNG("figure\\testplot.png"), plt)
display(plt)


by(data, :SES, μ = :Read => sum)

data = groupby(data, :SES)
# GroupedDataFrameにはそのままglmを適用できない。
glm(@formula(Math ~ Read), data, Normal())
# Comprehensionで対応できる。mapは無理そう？
map(x -> GLM.glm(@formula(Math ~ Read), x, Normal()), data)
fitted_df = [ GLM.glm(@formula(Math ~ Read), data[i], Normal()) for i in 1:length(data) ]

fitted_df[1] |> plot
