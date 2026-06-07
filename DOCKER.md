# Docker 実行環境（再現用）

このベンチマークを **誰でも同一環境で再実行** できるよう、全6言語の処理系を
1つのイメージに固めてあります。

## 含まれる処理系（バージョン固定）

| 言語 | 導入方法 | 固定バージョン |
| --- | --- | --- |
| JavaScript | ベースイメージ `node:22-bookworm-slim` | Node 22 |
| Python | Debian bookworm 同梱 | Python 3.11 |
| Zero (zerolang) | GitHub Release のビルド済みバイナリを **SHA256 検証**して配置 | `v0.2.1` |
| Vera | `git clone` → `pip install -e .`（Python製・venv 内） | `v0.0.160` |
| MoonBit | 公式インストーラ `curl \| bash` | ビルド時点の最新 |
| NanoLang | `git clone` → `make build`（C・3段ブートストラップ） | `main` |

バージョンは `--build-arg` で上書きできます（例 `--build-arg ZERO_VERSION=v0.2.1`）。

## 使い方

```bash
# 1. イメージをビルド（ホストのCPUアーキを自動判定: arm64 / amd64）
docker build -t ai-lang-bench .
#   または
docker compose build

# 2. 全処理系が入った対話シェルに入る（バージョン一覧が表示される）
docker run --rm -it ai-lang-bench
#   または
docker compose run --rm bench

# 3. 生成済みパーサに対して22ケースの採点を再実行する
docker run --rm ai-lang-bench scripts/run_bench_tests.sh
#   problem を指定する場合:
docker run --rm ai-lang-bench scripts/run_bench_tests.sh problem1-json-parser
```

`docker compose` 経由ではリポジトリを bind mount しているので、生成された
`results/` はホスト側に残ります。

## 再現できる範囲・できない範囲

- **再現できる**：生成済みパーサ（`results/<lang>/`）を 22 テストケースに通す
  **採点ステップ**。`scripts/run_bench_tests.sh` が各言語のテストランナーを実行します。
- **再現できない**：コードの **生成ステップ**。これは AI エージェント（Claude）が
  `AGENT_INSTRUCTIONS.md` に従って行うもので、コンテナ内だけでは完結しません。
  コンテナは「生成物を同一の処理系で検証する」ための土台を提供します。

## スクリプト

- `scripts/print_versions.sh` — 6言語すべてのバージョンを表示（既定の CMD）
- `scripts/run_bench_tests.sh [problem-dir]` — `results/<lang>/` 配下の
  `run_tests.js` / `run_tests.py` / Zero プロジェクトを検出して採点を再実行

## Caveats（正直な注意書き）

- **ビルドは外部の未検証コードを実行します**：MoonBit は `curl | bash`、Vera は
  clone 後 `pip install -e .`、NanoLang は clone 後 `make build`。信頼できる
  ネットワーク環境で、内容を確認の上ビルドしてください（CI 等で固定したい場合は
  各 `*_REF` / `*_VERSION` をコミットハッシュに固定することを推奨）。
- **NanoLang のビルドは最も重く壊れやすい**（C の3段ブートストラップ）。ビルド成果物の
  バイナリ名が環境で変わりうるため、Dockerfile は `bin/nanolang` 等の候補を探して
  symlink します。自動検出に失敗した場合は `/opt/nanolang` を確認してください。
- **MoonBit のみバージョン非固定**：公式インストーラがビルド時点の最新を取得します。
  厳密な再現が必要なら、取得後に `moon version` を記録してください。
- **Vera の `vera verify`（契約のZ3検証）は追加依存が要る場合があります**。本ベンチの
  採点で使う `vera check` 系は `pip install -e .` の範囲で動く想定です。
- **ホスト側ローカル環境との差**：今回の初回計測は macOS 上で Node 23.10 / Python
  3.11.13 で行いました。本イメージは Node 22 / Python 3.11 に固定しています。問題1の
  JSON パーサは純粋なロジックで、これらのマイナー差は結果に影響しません。
- **検証状況**：このリポジトリのファイル作成時点では、サンドボックスのセキュリティ判定
  により `docker build` を自動実行できていません（外部コード実行のため）。初回ビルドは
  利用者の環境で実行し、`scripts/print_versions.sh` が6言語すべてを表示することを
  確認してください。
