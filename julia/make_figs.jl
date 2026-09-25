# ポスター用の図を作る（6.4 母集団が正規分布でないとき：実験）
# 実行: julia --project=julia julia/make_figs.jl   （20260925bunkasai フォルダで）
using Distributions, Random, Statistics, Plots

gr()
const OUT = joinpath(@__DIR__, "..", "figs")
mkpath(OUT)
Random.seed!(30)

const HIST = RGB(0x3b / 255, 0x6e / 255, 0xa8 / 255)   # ヒストグラムの色
const NORM = RGB(0xd6 / 255, 0x27 / 255, 0x28 / 255)   # 標準正規分布の色

populations = [
    ("uniform",  Uniform(0, 1),                                (-0.3, 1.3)),
    ("exp",      Exponential(1),                               (-0.3, 5.0)),
    ("mixture",  MixtureModel([Uniform(0, 1), Uniform(4, 5)]), (-0.5, 5.5)),
    ("lognorm",  LogNormal(0, 1),                              (-0.3, 6.0)),
]

# ---- 母集団の分布の形 ----
for (key, d, (a, b)) in populations
    xs = range(a, b, length=1201)
    ys = pdf.(d, xs)
    pl = plot(xs, ys, fill=(0, 0.35, HIST), lw=4, color=HIST, legend=false,
              xlims=(a, b), ylims=(0, maximum(ys) * 1.12), grid=false,
              yticks=false, tickfontsize=22, framestyle=:axes,
              size=(640, 270), margin=6Plots.mm)
    vline!(pl, [mean(d)], lw=3, ls=:dash, color=:black)
    savefig(pl, joinpath(OUT, "pop_$(key).pdf"))
end

# ---- 標準化した標本平均のヒストグラム ----
φ(x) = exp(-x^2 / 2) / sqrt(2π)
T = 10_000
ns = [1, 2, 5, 30]
xg = -4:0.02:4
for (key, d, _) in populations
    m, σ = mean(d), std(d)
    for n in ns
        xbar = vec(mean(rand(d, n, T); dims=1))
        z = (xbar .- m) ./ (σ / sqrt(n))
        # 密度 = 度数 ÷ 全試行数 ÷ 階級幅（範囲外の標本も分母に含める）
        edges = range(-4, 4, length=41)
        dens = [count(e0 .<= z .< e1) for (e0, e1) in zip(edges[1:end-1], edges[2:end])] ./ (T * step(edges))
        ymax = max(0.5, maximum(dens) * 1.08)
        pl = histogram(z, bins=edges, weights=fill(1 / (T * step(edges)), T),
                       normalize=:none, legend=false, color=HIST, linecolor=:white,
                       linewidth=0.5, xlims=(-4, 4), ylims=(0, ymax), grid=false,
                       xticks=[-2, 0, 2], yticks=false, tickfontsize=22,
                       framestyle=:axes, size=(560, 360), margin=5Plots.mm)
        plot!(pl, xg, φ.(xg), lw=5, color=NORM)
        savefig(pl, joinpath(OUT, "clt_$(key)_n$(n).pdf"))
        println(rpad(key, 9), " n=", lpad(n, 2), "  max密度=", round(maximum(dens); digits=3),
                "  範囲外=", count(abs.(z) .> 4))
    end
end
