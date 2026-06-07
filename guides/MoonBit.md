# 文法ガイドの取得：MoonBit

MoonBit は公式ドキュメントサイトと、LLM 向けの集約ドキュメントを提供している。

```bash
# LLM 向けの集約ドキュメント（あれば最優先）
curl -fsSL https://docs.moonbitlang.com/llms.txt -o moonbit-llms.txt
```

取得した内容、または公式ドキュメントのチートシート部分を、
プロンプトの「パターンB」の `{文法ガイドをここに貼る}` に貼る。

- 公式サイト: https://www.moonbitlang.com/
- ドキュメント: https://docs.moonbitlang.com/

## 補足

MoonBit は本ベンチの4新言語の中で**最も成熟**しており、完全なツールチェーンを持つ。
生成中に構文/型エラーを抑制する仕組みがあるため、そもそも破綻コードが出にくい。

## 修正ループで使うエラー出力

コンパイラ診断・LSP の出力をそのまま AI に渡して根拠にする。

```bash
moon check       # 型検査
moon build       # ビルド
moon test        # テスト実行
```
