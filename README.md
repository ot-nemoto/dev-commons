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
│  ├─ CLAUDE.md                    # → <repo>/CLAUDE.md（全リポ同一の import マニフェスト）
│  ├─ .claude/
│  │  ├─ common-rules.md           # → <repo>/.claude/common-rules.md（共通ルールの唯一の正／base）
│  │  └─ api-rules.md              # → <repo>/.claude/api-rules.md（API 提供リポの規約／vercel-app のみ）
│  └─ .github/
│     └─ workflows/
│        ├─ ci.yml / auto-pr-to-master.yml / bump-version.yml / release.yml   # base（全リポジトリ）
│        ├─ deploy-github-pages.yml         # pages-app プロファイル
│        └─ deploy-cloudflare-workers.yml   # workers-app プロファイル
├─ scaffold/                       # 【一度だけ】新規リポジトリ作成時にコピーする雛形（同期対象外）
│  ├─ .claude/
│  │  └─ project.md                # リポジトリ固有情報の雛形（以後は各リポジトリが所有・自由に編集）
│  └─ .github/
│     └─ dependabot.yml            # 初期設定の雛形（以後は各リポジトリが正: 固有の ignore 等を持ってよい）
└─ .github/
   ├─ sync-config.json             # 配布設定（プロファイル定義・配布先マップ）
   ├─ dependabot.yml               # dev-commons 自身の workflows を監視（actions 新版の通知役）
   └─ workflows/
      ├─ sync-standards.yml        # sync/ を各リポジトリへ PR で配布（手動実行）
      └─ check-drift.yml           # 配布先が正典と一致するか検証（週1 + 手動）
```

**`sync/` と `scaffold/` を分ける理由**: `sync/` は「各リポジトリへ配布して上書き」しても安全なものだけを置く。各リポジトリが独自に育てるファイル（リポジトリ固有情報の `.claude/project.md`、固有の ignore を持つ `dependabot.yml`）は `scaffold/`（同期対象外）に置くことで、同期で誤って上書きする事故を構造的に防ぐ。

### ルールの3層構造

各リポジトリの `CLAUDE.md` は import だけのマニフェストで、スコープの異なる3層を取り込む。import 順が後ろのものが優先される（＝リポジトリ固有が最優先）。

| 層 | ファイル | スコープ | 所有 | 配布 |
|---|---|---|---|---|
| ① 全体ルール | `.claude/common-rules.md` | 全リポジトリ | dev-commons | sync / `base` |
| ② プロファイルルール | `.claude/api-rules.md` | API 提供リポのみ | dev-commons | sync / `vercel-app` |
| ③ リポジトリ固有 | `.claude/project.md` | そのリポのみ | 各リポジトリ | scaffold（同期しない） |

`CLAUDE.md`（全リポ同一・sync 配布）の中身:

```
@.claude/common-rules.md
@.claude/project.md
```

②を使う API 提供リポは、自分の `.claude/project.md` の先頭に `@.claude/api-rules.md` を1行足して取り込む（`common-rules < api-rules < project.md 固有` の優先順になる）。

## 配布の仕組み（sync-standards）

- 配布ファイルと対象は `.github/sync-config.json` を正とする:
  - **profiles**: `base`（`CLAUDE.md` + common-rules + ci / auto-pr / bump / release）に、各プロファイルが差分を加える。`pages-app` / `workers-app` は deploy ワークフローを追加、`vercel-app` は API 提供リポ向けに `.claude/api-rules.md` を追加する（デプロイは Vercel の Git 連携のため deploy ワークフローは持たない）
  - **targets**: リポジトリ名 → プロファイル名のマップ。リポジトリの追加・デプロイ方式変更はここを1行直すだけ
- **手動実行のみ**（`workflow_dispatch`）。`only` で1リポジトリに限定できる
- 各対象を clone → プロファイルのファイル一式を上書き → **差分がなければスキップ（冪等）** → あれば `chore/sync-standards` ブランチで develop 向けに **PR 起票**（直接 push しない）
- 各リポジトリ所有のファイル（`.claude/project.md`・`dependabot.yml`）には**触れない**（`CLAUDE.md` は base の配布対象なので上書きされる。リポジトリ固有情報は `project.md` 側に置く）
- 認証は `secrets.SYNC_PAT`（対象リポジトリへの **Contents / Pull requests / Workflows** の write が必要。workflows 配布のため Workflows 権限が必須）

## ドリフト検証（check-drift）

- 週1（月曜 6:00 JST）+ 手動実行。各配布先 develop の同期対象ファイルの blob SHA を正典（`sync/` 配下）と比較する
- **全一致なら何もせず成功**（Issue は起票されない）
- 不一致を検知したときのみ run を失敗させ、Issue を起票する（open のドリフト Issue があれば新規を作らずコメントで追記）
- 対応: dev-commons 側が正しければ `sync-standards` を実行。配布先側の変更が正しければ `sync/` へ逆輸入してから同期する

## actions バージョンの管理方針

- ワークフローで使う actions（`actions/checkout` 等）のバージョンは **dev-commons の雛形で一元管理**する。アプリ側リポジトリの dependabot に `github-actions` エコシステムは**入れない**（入れるとリポジトリ側で自走 bump され、同期と競合する）
- dev-commons 自身の dependabot（`.github/dependabot.yml`）が自リポジトリの workflows への bump PR を出す。これが「新版が出た」通知役。**新版が来たら `sync/` 配下の雛形にも同じバージョンを手で反映し、sync-standards で配布する**（dependabot は `sync/` 配下をスキャンしない）

## 各リポジトリでの独自ルール

- リポジトリ固有のルール（独自ルール・共通ルールの例外）は、各リポジトリの `.claude/project.md` に書く（同期対象外なので上書きされない）
- 優先順は `common-rules < api-rules < project.md 固有`。共通ルールと矛盾する記述は import 順で後ろにある `project.md` が優先される
- API 提供リポは `.claude/project.md` の先頭に `@.claude/api-rules.md` を足して②のプロファイルルールを取り込む
- `dependabot.yml` はリポジトリ固有の設定（特定依存の ignore 等）を持ってよい（同期対象外）
- `sync/` 由来の配布ファイル（`CLAUDE.md`・`.claude/common-rules.md`・`.claude/api-rules.md`・各ワークフロー）は各リポジトリで直接編集しない

## 新規リポジトリの作り方

1. `scaffold/` の中身（`.claude/project.md`・`.github/dependabot.yml`）をコピーし、`project.md` の固有部（ドキュメント採否・テスト対象・独自ルール）を埋める（API 提供リポは `project.md` 先頭に `@.claude/api-rules.md` を追記）
2. `.github/sync-config.json` の `targets` にリポジトリ名とプロファイル（`pages-app` / `workers-app` / `vercel-app`）を追加する
3. `sync-standards` を `only=<リポジトリ名>` で実行し、`CLAUDE.md`・共通ルール・ワークフロー一式（API リポは `api-rules.md` も）を受け取る

> **`.claude/` を gitignore する場合の注意**: Claude Code のスクラッチ等で `.claude/` を無視するリポジトリでは、配布・所有する `.claude/` 配下のファイルを追跡できるよう `.gitignore` を **`.claude/` 全体除外ではなく `.claude/*` + 除外解除**にする。除外解除の対象は最低でも `!.claude/common-rules.md` と `!.claude/project.md`、API 提供リポはさらに `!.claude/api-rules.md`。全体除外のままだと sync が配布ファイルを追跡できず、`sync-standards` が `::error::` で当該リポを失敗させる（欠落したまま「成功」する事故を防ぐため）。
