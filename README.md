# 母集団が正規分布でなくても，標本平均は正規分布に近づく？

2026年9月25日　城北中学校・高等学校 文化祭ポスターセッション　清水 団

4つの母集団（一様分布・指数分布・混合分布・対数正規分布）で，標準化した標本平均の分布が標準正規分布に近づく様子（中心極限定理）を Julia で実験したポスター（A0縦）です。

出典：『「nが大きいとき」の正体：Juliaで確かめる高校数学の統計的な推測』（Zenn）第6章 6.4「母集団が正規分布でないとき：実験」

- [poster.pdf](poster.pdf)：ポスター
- [poster.typ](poster.typ)：Typst ソース（[peace-of-posters](https://typst.app/universe/package/peace-of-posters)）
- [julia/make_figs.jl](julia/make_figs.jl)：図を作る Julia スクリプト（出力先 `figs/`）

## ビルド

```sh
julia --project=julia julia/make_figs.jl   # 図の生成
typst compile poster.typ                   # PDF の生成
```
