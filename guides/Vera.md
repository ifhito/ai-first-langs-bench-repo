# 文法ガイドの取得：Vera

Vera は機械可読の**完全な文法ガイド `SKILL.md` を公式配布**している。これをそのまま使う。

```bash
# 公式 SKILL.md を取得（最も正確・最新）
curl -fsSL https://veralang.dev/SKILL.md -o vera-SKILL.md
```

取得した `SKILL.md` の内容を、プロンプトの「パターンB」の
`{文法ガイドをここに貼る}` に貼る（長い場合は、構文・契約・効果・
よくある間違いのセクションを優先して貼る）。

- 公式サイト: https://veralang.dev/
- リポジトリ: https://github.com/aallan/vera
- 機械可読ガイド: https://veralang.dev/SKILL.md ・ https://veralang.dev/llms.txt

## Vera 最大の注意点（ガイドにも明記されている）

- **変数名を使わない。** `@T.n`（De Bruijn インデックス）で束縛を参照する
  （`@Int.0` は最も新しい Int 束縛、`@Int.1` はその前）
- **全関数に `requires` / `ensures` / `effects` の契約ブロックが必須**
- 副作用は型付き効果として宣言する（`effects(<IO>)` など。既定は `pure`）

## 修正ループで使うエラー出力

Vera のエラーは「**何が・なぜ・どう直すか**を書いた自然文＋仕様参照」。
`--json` で機械可読にもできる。修正ループではこれを根拠にする。

```bash
vera check yourfile.vera          # 型検査
vera check --json yourfile.vera   # JSON 診断
vera verify yourfile.vera         # 契約を Z3 で検証
```
