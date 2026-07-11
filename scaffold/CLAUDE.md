# CLAUDE.md

開発の共通規約は `.claude/common-rules.md`（dev-commons から同期）に集約している。本ファイルはそれをインポートし、**このリポジトリ固有の情報のみ**を記載する。

@.claude/common-rules.md

---

## 作業開始時のチェックリスト

1. `docs/product.md` を読みプロダクトの目的・対象ユーザーを理解する
2. `docs/architecture.md` で実装方針・設計判断・バージョン gotcha を確認する
3. `docs/ui.md` で画面仕様・UI 規約を確認する
4. `docs/development.md` で開発・デプロイ手順を確認する
5. <条件付き docs があれば追記（例: Kintone フィールドに触れる場合は `docs/kintone-fields.md` を確認する）>
6. タスクの状態・実装順は GitHub Issues / Milestone で確認する

## 本リポジトリのドキュメント採否

- **必須ドキュメント**: `product` / `architecture` / `ui` / `development`
- **条件付き必須ドキュメント**: <採用しているものを列挙。なければ「該当なし」とし、理由を一言記す（例: サーバーレス・クライアント完結の SPA のため `api.md` / `schema.md` / `auth.md` / `infra.md` 等は不要）>

## テスト対象（このリポジトリ固有）

- ユニットテスト対象: <例: `src/lib/` / `src/app/utils/` / `src/app/hooks/`>
- API ルート: <有無。ある場合は `app/api/` を対象に含める>

## このリポジトリ固有のルール（任意）

<共通ルール（`.claude/common-rules.md`）にない独自ルールや、共通ルールの例外があればここに記載する。共通ルールと矛盾する記述は import より後ろにあるこの位置が優先される。不要なら本セクションは削除してよい。>
