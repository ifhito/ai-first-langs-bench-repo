# 文法ガイドの取得：Zero (zerolang)

Zero は文法ガイドを**コンパイラに同梱**しており、使用中のバイナリと
バージョン整合の取れたガイドをコマンドで取得できる。これが最も正確。

```bash
zero skills get zero-language      # 言語ガイド（構文・型・効果）
zero skills get zero-diagnostics   # 診断・エラーコードのガイド
zero skills get zero-stdlib        # 標準ライブラリのガイド
zero skills list                   # 一覧
```

取得したテキストを、プロンプトの「パターンB」の `{文法ガイドをここに貼る}` に貼る。

- 公式サイト: https://zerolang.ai/
- リポジトリ: https://github.com/vercel-labs/zerolang

## 修正ループで使うエラー出力

Zero は `.0` ソースから意味グラフを作り、`zero check --json` が
`NAM003` などの**安定したエラーコード付きの構造化エラー（JSON）**を返す。
修正ループでは、この JSON 出力をそのまま AI に渡して根拠にする。

```bash
zero check --json yourfile.0
zero explain --json TYP009          # エラーコードの説明
zero fix --plan --json yourfile.0   # 修正プラン
```
