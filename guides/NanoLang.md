# 文法ガイドの取得：NanoLang

NanoLang は **README 自体が「機械が曖昧さなく読めること」を意図して
言語自身を一人称で説明する**設計になっている。README とユーザーガイドが一次情報。

```bash
# リポジトリを取得して README とユーザーガイドを参照
git clone https://github.com/jordanhubbard/nanolang.git
cd nanolang
# docs/ 配下と userguide/ を参照
make userguide-html   # ユーザーガイドを HTML 化（任意）
```

README とユーザーガイドの該当部分を、プロンプトの「パターンB」の
`{文法ガイドをここに貼る}` に貼る。

- リポジトリ: https://github.com/jordanhubbard/nanolang

## NanoLang の注意点

- **全関数にテスト（`shadow` ブロック）が必須**
- 曖昧さのない構文。C にトランスパイルして実行する
- LSP（`bin/nanolang-lsp`）と DAP も同梱

## 修正ループで使うエラー出力

ビルド/テストの出力をそのまま AI に渡して根拠にする。

```bash
make build        # ビルド（3段ブートストラップ）
make test-quick   # 言語テストのみ
```
