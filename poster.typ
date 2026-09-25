// 文化祭ポスターセッション用ポスター（A0縦）
// 出典: Juliaで学ぶ統計的推測 第6章 6.4「母集団が正規分布でないとき：実験」
// 図は julia/make_figs.jl で figs/ に生成する
#import "@preview/peace-of-posters:0.5.6" as pop
#import "@preview/tiaoma:0.3.0"

// ---------- 色・フォント ----------
#let navy = rgb("#1f3a5f")
#let accent = rgb("#d62728")   // 標準正規分布の赤線と同じ色
#let hist-blue = rgb("#3b6ea8")
#let pale = rgb("#eef3f9")
#let sans = ("Hiragino Sans", "BIZ UDPGothic")

#set page("a0", margin: 2cm, fill: white)
#pop.set-poster-layout(pop.layout-a0)
#pop.set-theme((
  "body-box-args": (inset: 0.8em, width: 100%, stroke: (paint: navy, thickness: 3pt)),
  "body-text-args": (:),
  "heading-box-args": (inset: 0.6em, width: 100%, fill: navy, stroke: navy),
  "heading-text-args": (fill: white, weight: "bold"),
  "title-box-args": (inset: 1.1em, width: 100%, fill: gradient.linear(navy, rgb("#3b6ea8")), stroke: none),
  "title-text-args": (fill: white, weight: "bold"),
))
#set text(font: sans, size: 30pt, lang: "ja")
#set par(justify: true, leading: 0.75em)
#show math.equation: set text(font: "New Computer Modern Math")
#show strong: set text(fill: accent)
#set list(indent: 0.4em, marker: text(fill: navy)[●])
#set enum(indent: 0.4em)
#show raw: set text(font: ("Menlo", "Hiragino Sans"), size: 23pt)
#show raw.where(block: true): block.with(fill: pale, inset: 0.6em, radius: 8pt, width: 100%)

#let box-spacing = 1.0em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#pop.update-poster-layout(spacing: box-spacing)

#let redline = box(line(length: 1.6em, stroke: 5pt + accent), baseline: -0.3em)
#let bluebox = box(rect(width: 0.9em, height: 0.7em, fill: hist-blue), baseline: 0.05em)
#let callout(body) = block(fill: rgb("#fdecec"), inset: 0.7em, radius: 10pt, width: 100%,
  stroke: (left: 10pt + accent), body)

// ---------- タイトル ----------
#pop.title-box(
  [母集団が正規分布でなくても，標本平均は正規分布に近づく？],
  subtitle: text(size: 42pt, weight: "regular")[
    ── 4つの母集団で中心極限定理を Julia で実験する ──],
  authors: text(size: 38pt, weight: "regular")[城北中学校・高等学校　数学科・校長　清水　団　#h(1.5em) 2026年9月25日],
  logo: align(center + horizon, stack(spacing: 8pt,
    box(fill: white, inset: 12pt, radius: 12pt,
      tiaoma.qrcode("https://github.com/shimizudan/clt-poster-2026/blob/main/poster.pdf", width: 6cm)),
    text(size: 22pt, fill: white)[このポスターの PDF])),
  text-relative-width: 84%,
  title-size: 64pt,
)

// ---------- 上段：問い・母集団・方法 ----------
#columns(2)[
  #pop.column-box(heading: "1. 問い", stretch-to-next: true)[
    母平均 $m$，母標準偏差 $sigma$ の母集団から大きさ $n$ の無作為標本をとると，標本平均 $overline(X)$ について
    $ E(overline(X)) = m, quad V(overline(X)) = sigma^2 / n $
    が成り立ちます。教科書には次のように書かれています。

    #callout[
      *$n$ が大きいとき*，$overline(X)$ は近似的に正規分布 $N(m, sigma^2\/n)$ に従う。（中心極限定理）
    ]

    母集団が正規分布なら，$n$ に関係なく $overline(X)$ は正確に正規分布に従います。
    では，*母集団が正規分布でないとき，「$n$ が大きい」とはどのくらい*でしょうか。
  ]

  #colbreak()

  #pop.column-box(heading: "2. 実験の方法")[
    形の違う4つの母集団（3. の図の左列）それぞれについて，$n = 1, 2, 5, 30$ で次を行います。
    + 母集団から大きさ $n$ の標本をとり，標本平均 $overline(X)$ を求める。
    + 標準化する：$display(Z_n = (overline(X) - m) / (sigma \/ sqrt(n)))$
    + これを *$10000$ 回* くり返し，$Z_n$ のヒストグラム（密度）を描く。
    + 標準正規分布 $N(0,1)$ の密度関数 $phi(x)$ を重ねて比べる。

    Julia の `Distributions` パッケージを使うと，主な部分は数行で書けます。
    ```julia
    d = Exponential(1)              # 母集団
    m, σ = mean(d), std(d)          # 母平均・母標準偏差
    X = rand(d, n, 10_000)          # n×10000 個の乱数
    xbar = vec(mean(X; dims=1))     # 標本平均を 10000 個
    z = (xbar .- m) ./ (σ / sqrt(n))  # 標準化
    ```
    #set text(size: 25pt)
    ヒストグラムは「度数 ÷ 全試行数 ÷ 階級幅」で密度にしています。
  ]
]

// ---------- 中段：結果 ----------
#let pops = (
  ("uniform", [一様分布], [$U(0,1)$，$gamma = 0$]),
  ("exp", [指数分布], [$"Exp"(1)$，$gamma = 2$]),
  ("mixture", [混合分布], [$U(0,1)$ と $U(4,5)$ を半々，$gamma = 0$]),
  ("lognorm", [対数正規分布], [$"LogNormal"(0,1)$，$gamma approx 6.2$]),
)
#let ns = (1, 2, 5, 30)

#pop.column-box(heading: "3. 結果：標準化した標本平均 " + $Z_n$ + " の分布")[
  #set text(size: 28pt)
  #align(center)[
    #bluebox $Z_n$ のヒストグラム（10000回）#h(2em)
    #redline 標準正規分布 $N(0,1)$ #h(2em)
    #box(line(length: 1.4em, stroke: (paint: black, thickness: 4pt, dash: "dashed")), baseline: -0.3em) 母平均 $m$
  ]
  #v(0.2em)
  #grid(
    columns: (1.3fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 0.3em,
    row-gutter: 0.35em,
    align: center + horizon,
    grid.cell(fill: pale, inset: 0.4em)[*母集団の形*],
    ..ns.map(n => grid.cell(fill: pale, inset: 0.4em)[*$n = #n$*]),
    ..pops.map(((key, name, sub)) => (
      stack(spacing: 0.1em,
        text(size: 26pt)[#text(weight: "bold", fill: navy)[#name]　#sub],
        image("figs/pop_" + key + ".pdf", width: 100%)),
      ..ns.map(n => image("figs/clt_" + key + "_n" + str(n) + ".pdf", width: 100%)),
    )).flatten(),
  )
  #text(size: 25pt)[
    歪度 $gamma$：分布の偏りの大きさを表す数（左右対称なら $0$）。各パネルの横軸は $-4 <= Z_n <= 4$。縦軸の目盛りはパネルごとに異なります（どの図も面積はほぼ $1$）。
  ]
]

// ---------- 下段：わかったこと・考察 ----------
#columns(2)[
  #pop.column-box(heading: "4. わかったこと", stretch-to-next: true)[
    - *どの母集団でも，$n$ が大きくなると，ヒストグラムは赤線に近づく*（中心極限定理）。
    - *一様分布*は歪度 $0$ で山も1つなので，$n = 5$ でもう赤線とよく重なる。
    - *偏った母集団は収束が遅い。*指数分布は $n = 30$ でもまだ右に少し偏る。対数正規分布は $n = 30$ でもはっきり偏っている。
    - *歪度 $0$ でも，収束が速いとは限らない。*混合分布は左右対称だが，$n = 2$ で3つの山，$n = 5$ で6つの山になる（「$U(4,5)$ から来た値が何個あるか」で山が分かれる）。$n = 30$ でようやく滑らかな釣鐘形になる。
  ]

  #colbreak()

  #pop.column-box(heading: "5. 考察：「n ≧ 30」の目安は？")[
    標本平均 $overline(X)$ の歪度は，母集団の歪度 $gamma$ を使って $gamma \/ sqrt(n)$ と表せます。$n = 30$ のとき：
    #v(0.1em)
    #align(center, table(
      columns: 4,
      inset: (x: 0.6em, y: 0.4em),
      align: center + horizon,
      stroke: (x, y) => (bottom: if y == 0 { 3pt + navy } else { 1pt + luma(180) }),
      fill: (x, y) => if y == 0 { pale },
      [], [*一様・混合*], [*指数*], [*対数正規*],
      [$gamma \/ sqrt(30)$], [$0$], [$0.37$], [$1.13$],
    ))
    対数正規分布で指数分布の $n = 30$ と同じ程度（$0.37$）にするには，$n approx (6.2 \/ 0.37)^2 approx 290$ も必要です。

    #callout[
      *「$n$ が大きいとき」の大きさは，母集団の分布の形によって大きく変わる。*
      「$n >= 30$」は，極端に偏った分布や離れた山をもつ分布でない母集団なら，という条件つきの目安です。
    ]
  ]
]

#pop.bottom-box(text-relative-width: 100%)[
  #set text(size: 26pt)
  出典：「Juliaで学ぶ統計的推測」第6章 6.4 母集団が正規分布でないとき：実験（Zenn）
  #h(1fr) 使用ソフト：Julia（Distributions.jl，Plots.jl），Typst（peace-of-posters）
]
