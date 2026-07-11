# CLAUDE.md — dev-commons（開発基盤の正典リポジトリ）

このリポジトリは、複数の web アプリリポジトリで共有する**開発規約と CI 雛形の正典**。共通ルールとテンプレートの単一ソースとして管理し、各リポジトリへ配布する。

## リポジトリの構成

| パス | 役割 |
|------|------|
| `templates/common-rules.md` | 各リポジトリ共通の開発規約。**共通ルールの唯一の正**。各リポジトリの `.claude/common-rules.md` へ同期配布する |
| `templates/CLAUDE.repo.md` | 新規リポジトリ用の薄型 `CLAUDE.md` スケルトン（固有部のみ ＋ `@.claude/common-rules.md`） |
| `templates/workflows/*.yml` / `templates/dependabot.yml` | CI ワークフロー・Dependabot の雛形 |
| `.github/workflows/sync-standards.yml` | 上記を各リポジトリへ PR で配布する同期ワークフロー（構築予定） |

## 運用モデル

- **共通ルールを変えるときは `templates/common-rules.md` を編集する**。各アプリリポジトリの `CLAUDE.md`（固有部）や配布先の `.claude/common-rules.md` を直接編集しない。
- 変更は同期ワークフローが各リポジトリへ **PR として配布**し、各リポジトリでレビュー・マージする（直接 push はしない）。
- 各アプリリポジトリの `CLAUDE.md` は薄型で、リポジトリ固有の情報（参照 docs・ドキュメント採否・テスト対象パス）のみを持ち、先頭で `@.claude/common-rules.md` を import する。

## このリポジトリで作業するときのルール

Issue 運用・Git フロー・バージョニング・PR レビュー対応は、下記の共通ルールに従う。

@templates/common-rules.md

> 注: `common-rules.md` のうち「ドキュメント構成ルール」「テストルール」「UI実装の動作確認ルール」は配布先のアプリリポジトリ向けの規約であり、アプリではない dev-commons 自体には適用しない。dev-commons では Git 操作・PR レビュー対応・作業スコープのルールを適用する。
> また Issue タイトルの `[T番号]` 採番はアプリリポジトリの慣習であり、dev-commons は既存どおり素のタイトルでよい。
