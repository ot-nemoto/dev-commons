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
│     └─ workflows/
│        ├─ ci.yml / auto-pr-to-master.yml / bump-version.yml / release.yml   # base（全リポジトリ）
│        ├─ deploy-github-pages.yml         # pages-app プロファイル
│        └─ deploy-cloudflare-workers.yml   # workers-app プロファイル
├─ scaffold/                       # 【一度だけ】新規リポジトリ作成時にコピーする雛形（同期対象外）
│  ├─ CLAUDE.md                    # 薄型スケルトン（固有部プレースホルダ）
│  └─ .github/
│     └─ dependabot.yml            # 初期設定の雛形（以後は各リポジトリが正: 固有の ignore 等を持ってよい）
└─ .github/
   ├─ sync-config.json             # 配布設定（プロファイル定義・配布先マップ）
   ├─ dependabot.yml               # dev-commons 自身の workflows を監視（actions 新版の通知役）
   └─ workflows/
      ├─ sync-standards.yml        # sync/ を各リポジトリへ PR で配布（手動実行）
      └─ check-drift.yml           # 配布先が正典と一致するか検証（週1 + 手動）
```

**`sync/` と `scaffold/` を分ける理由**: `sync/` は「各リポジトリへ配布して上書き」しても安全なものだけを置く。各リポジトリが独自に育てるファイル（`CLAUDE.md`、リポジトリ固有の ignore を持つ `dependabot.yml`）は `scaffold/`（同期対象外）に置くことで、同期で誤って上書きする事故を構造的に防ぐ。

## 配布の仕組み（sync-standards）

- 配布ファイルと対象は `.github/sync-config.json` を正とする:
  - **profiles**: `base`（common-rules + ci / auto-pr / bump / release）に、デプロイ方式別の `pages-app` / `workers-app` が deploy ワークフローを追加する
  - **targets**: リポジトリ名 → プロファイル名のマップ。リポジトリの追加・デプロイ方式変更はここを1行直すだけ
- **手動実行のみ**（`workflow_dispatch`）。`only` で1リポジトリに限定できる
- 各対象を clone → プロファイルのファイル一式を上書き → **差分がなければスキップ（冪等）** → あれば `chore/sync-standards` ブランチで develop 向けに **PR 起票**（直接 push しない）
- 各リポジトリの `CLAUDE.md`・`dependabot.yml` には**触れない**
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

- リポジトリ固有のルール（独自ルール・共通ルールの例外）は、各リポジトリの `CLAUDE.md` に書く（同期対象外なので上書きされない）
- `CLAUDE.md` は「先頭で `@.claude/common-rules.md` を import → その後に固有セクション」の順。共通ルールと矛盾する記述は import より後ろに置けば優先される
- `dependabot.yml` はリポジトリ固有の設定（特定依存の ignore 等）を持ってよい（同期対象外）
- `sync/` 由来の配布ファイル（`.claude/common-rules.md`・各ワークフロー）は各リポジトリで直接編集しない

## 新規リポジトリの作り方

1. `scaffold/` の中身（`CLAUDE.md`・`.github/dependabot.yml`）をコピーし、`CLAUDE.md` の固有部（ドキュメント採否・テスト対象・独自ルール）を埋める
2. `.github/sync-config.json` の `targets` にリポジトリ名とプロファイル（`pages-app` / `workers-app`）を追加する
3. `sync-standards` を `only=<リポジトリ名>` で実行し、共通ルールとワークフロー一式を受け取る
