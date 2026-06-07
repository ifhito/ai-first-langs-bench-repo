# 第三者再採点 — 問題2 銀行口座

[`../RUBRIC.md`](../RUBRIC.md) を各条件の**最終 attempt のソース**に適用した再採点。
自作ハーネスの「PASS N/14」表示ではなく、**拒否シグナル (a) を呼び出し側が判別できるか**を
ソースで確認している。再実行ログは各 `results/<lang>/<cond>/rerun.log`。

## 採点軸

- **error_channel**：拒否シグナルの形 — `exception` / `sum-type` / `sentinel(weak)` / `none`。
- **異常系 7〜12**：ハーネスが (a) 拒否を実際に検査しているか。
- **不変条件 13・14**：残高不変 (b) のみで判定。

## 一覧

| 条件 | error_channel | 異常系で拒否を検査? | final | status |
| --- | --- | --- | --- | --- |
| JavaScript/A | `exception`（`throw new Error`） | ✅ `expect_error` が `raised` を見る | **14/14** | DONE |
| Python/A | `exception`（`raise BankAccountError`、型も判定） | ✅ `raised` かつ型一致 | **14/14** | DONE |
| Zero/A | `sentinel(weak)`（`-1`、残高は常に>=0で非衝突） | ✅ `r < 0 && ...` | **14/14** | DONE |
| Zero/B | `sentinel(weak)`（`-1`） | ✅ `rejected(res) && ...` | **14/14** | DONE |
| MoonBit/A | `exception`（`raise BankError`） | ✅ ハーネスが raise を捕捉 | **14/14** | DONE |
| MoonBit/B | `exception`（`raise AccountError`） | ✅ 同上 | **14/14** | DONE |
| NanoLang/A | `sum-type`（`OpResult.Err` + `is_err`） | ✅ `is_err`==1 かつ残高不変を `mul2pass` で AND | **14/14** | DONE |
| NanoLang/B | `sum-type`（`Result.Err`） | ✅ `is_error` で判定 | **14/14** | DONE |
| Vera/A | `sum-type`（`Outcome.Err` + `is_err`） | ✅ `check_err` が `is_err` を見る | **14/14** | DONE |
| Vera/B | `sum-type`（`Result<Nat,String>` の `Err`） | ✅ `check_err` で判定 | **14/14** | DONE |

**結果：10条件すべてが 14/14 DONE。** いずれも例外・直和型・番兵値で拒否シグナル (a) を備え、
ハーネスが異常系 #7〜#12 で拒否を実際に検査している。

> NanoLang/A の直和型 `union OpResult { Ok{balance:int} ｜ Err{code:int} }` は、
> **公式ガイドを読まず、処理系のエラー `Expected '{' after variant name (got LPAREN)` から発見**した
> もので、Pattern A 制約を維持している（`results/NanoLang/A/attempt_1.nano`）。
> 本採点者がソース確認＋コンテナで2回再実行（`TOTAL_PASSED 14` 決定的・exit=0）して検証済み。

---

## 番兵値（Zero A/B）の扱い

Zero は `-1` を失敗の番兵として返す。残高は常に >= 0 なので -1 は**正常値と衝突しない**out-of-band
シグナルであり、ハーネスも `r < 0` / `rejected(res)` で**実際に判定している**。よって (a) を満たし通過。
ただし型システムが取り違えを防ぐわけではない（呼び出し側が `applyResult`/`rejected` を
使い忘れれば -1 がそのまま残高になりうる）ため、`exception`/`sum-type` より弱い `sentinel(weak)` と注記する。
