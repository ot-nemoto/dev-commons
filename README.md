# dev-commons

複数の web アプリリポジトリで共有する「**開発規約と CI 雛形の正典**」リポジトリ。

## 目的

- 共通の開発規約（`CLAUDE.md` ルール）と CI ワークフロー雛形を**単一ソース**で管理する
- 各リポジトリへ配布し、リポジトリ間のドリフト（規約・CI の食い違い）を防ぐ

## リポジトリ構成

```
dev-commons/
├─ README.md                       # このファイル（概要・目的・構成・運用）
├─ templates/                      # 配布物。中身は配布先リポジトリの構造そのまま
│  ├─ CLAUDE.md                    # 薄型スケルトン（新規リポジトリ用・同期対象外）
│  ├─ .claude/
│  │  └─ common-rules.md           # → <repo>/.claude/common-rules.md（共通ルールの唯一の正）
│  └─ .github/
│     ├─ dependabot.yml            # → <repo>/.github/dependabot.yml
│     └─ workflows/
│        ├─ ci.yml / auto-pr-to-master.yml / bump-version.yml / release.yml
│        ├─ deploy-github-pages.yml         # GitHub Pages 系リポジトリ用
│        └─ deploy-cloudflare-workers.yml   # Cloudflare Workers 系リポジトリ用
└─ .github/
   └─ workflows/
      └─ sync-standards.yml        # 配布の自動化（構築予定）
```

`templates/` 配下は**配布先リポジトリの構造をそのままミラー**している。`templates/<パス>` が各リポジトリの `<パス>` に対応する。

## 運用モデル

- **共通ルールを変えるときは `templates/.claude/common-rules.md` を編集する**（唯一の正）。各リポジトリの配布先ファイルを直接編集しない。
- `sync-standards` ワークフローが各リポジトリへ **PR で配布** → 各リポジトリでレビュー・マージする（直接 push はしない）。
- 各リポジトリの `CLAUDE.md`（固有部）は同期対象外。共通ルールは各リポジトリの `.claude/common-rules.md` に配布され、`CLAUDE.md` 先頭の `@.claude/common-rules.md` で取り込まれる。

## 配布物の種別

| 種別 | 対象 | 扱い |
|------|------|------|
| 継続同期（上書き） | `.claude/common-rules.md`、`.github/workflows/*`、`.github/dependabot.yml` | dev-commons が正。各リポジトリへ上書き配布 |
| スキャフォールド（一度だけ） | `templates/CLAUDE.md` | 新規リポジトリ作成時にコピー。以後は各リポジトリが正・同期対象外 |

## 新規リポジトリの作り方

1. `templates/` の中身をコピーする
2. `CLAUDE.md` の固有部（ドキュメント採否・テスト対象）を埋める
3. deploy ワークフローは GitHub Pages / Cloudflare Workers のいずれかを選ぶ
