# dev-commons

複数の web アプリリポジトリで共有する「**開発規約と CI 雛形の正典**」リポジトリ。

## 目的

- 共通の開発規約（`CLAUDE.md` ルール）と CI ワークフロー雛形を**単一ソース**で管理する
- 各リポジトリへ配布し、リポジトリ間のドリフト（規約・CI の食い違い）を防ぐ

## リポジトリ構成

配布物を**ライフサイクルで2つに分ける**。どちらも配布先リポジトリのパス構造をミラーしている（`<dir>/<パス>` が各リポジトリの `<パス>` に対応）。

```
dev-commons/
├─ README.md                       # このファイル（概要・目的・構成・運用）
├─ sync/                           # 【継続同期】この配下を各リポジトリへ上書き配布する
│  ├─ .claude/
│  │  └─ common-rules.md           # → <repo>/.claude/common-rules.md（共通ルールの唯一の正）
│  └─ .github/
│     ├─ dependabot.yml            # → <repo>/.github/dependabot.yml
│     └─ workflows/
│        ├─ ci.yml / auto-pr-to-master.yml / bump-version.yml / release.yml
│        ├─ deploy-github-pages.yml         # GitHub Pages 系リポジトリ用
│        └─ deploy-cloudflare-workers.yml   # Cloudflare Workers 系リポジトリ用
├─ scaffold/                       # 【一度だけ】新規リポジトリ作成時にコピーする雛形（同期対象外）
│  └─ CLAUDE.md                    # 薄型スケルトン（固有部プレースホルダ）
└─ .github/
   └─ workflows/
      └─ sync-standards.yml        # sync/ を各リポジトリへ PR で配布する（構築予定）
```

**`sync/` と `scaffold/` を分ける理由**: `sync/` は「丸ごと各リポジトリへ配布して上書き」しても安全なものだけを置く。各リポジトリが独自に育てる `CLAUDE.md` は `scaffold/`（同期対象外）に置くことで、同期で誤って上書きする事故を構造的に防ぐ。

## 運用モデル

- **共通ルールを変えるときは `sync/.claude/common-rules.md` を編集する**（唯一の正）。各リポジトリの配布先ファイルを直接編集しない。
- `sync-standards` ワークフローが `sync/` 配下を各リポジトリへ **PR で配布** → 各リポジトリでレビュー・マージする（直接 push はしない）。
- 各リポジトリの `CLAUDE.md`（固有部）は**同期されない**。共通ルールは各リポジトリの `.claude/common-rules.md` に配布され、`CLAUDE.md` 先頭の `@.claude/common-rules.md` で取り込まれる。

## 各リポジトリでの独自ルール

- リポジトリ固有のルール（独自ルール・共通ルールの例外）は、各リポジトリの `CLAUDE.md` に書く（同期対象外なので上書きされない）。
- `CLAUDE.md` は「先頭で `@.claude/common-rules.md` を import → その後に固有セクション」の順。共通ルールと矛盾する記述は import より後ろに置けば優先される。
- `.claude/common-rules.md` は dev-commons が配布・上書きするため、各リポジトリで直接編集しない。

## 新規リポジトリの作り方

1. `scaffold/CLAUDE.md` をリポジトリルートの `CLAUDE.md` としてコピーし、固有部（ドキュメント採否・テスト対象・独自ルール）を埋める
2. `sync/` の中身が同期で配布される（`.claude/common-rules.md`・CI ワークフロー・dependabot）
3. deploy ワークフローは GitHub Pages / Cloudflare Workers のいずれかを選ぶ
