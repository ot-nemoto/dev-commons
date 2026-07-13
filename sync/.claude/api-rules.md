# API 提供リポジトリの規約（api-rules）

> **⚠️ このリポジトリが外部 API を提供しない場合、以下のルールは適用対象外（無視してよい）。** 提供の有無は `.claude/project.md` のドキュメント採否・実コード（`app/api/` 等）で判断する。
>
> **⚠️ このファイルは dev-commons が正典として管理し、sync-standards ワークフローが全リポジトリへ PR で配布する（全リポに配布し、API 提供時のみ適用する）。各リポジトリで直接編集しない（次回同期で上書きされる）。**
> 変更するときは dev-commons の `sync/.claude/api-rules.md` を編集する。
>
> このファイルは **外部 API を提供するリポジトリに効く共通規約**。ルートの `CLAUDE.md` が常に import し、上記ガードにより API を提供しないリポジトリでは適用対象外となる。
> ここには「API をどう**見せ・ドキュメント化するか**」の規約（＝ outcome の形）だけを書く。実装方式（スキーマから spec を生成する手段など）は各リポジトリの product code の領分であり、ここには書かない。

---

## API リファレンスの提供（OpenAPI + リファレンス UI）

- **OpenAPI 3.1 を配信する**。実行時にエンドポイントで配信することを推奨し、`version` は `package.json`、`servers` はアクセス元 origin を反映する（固定値をドキュメントに焼き込まない＝ source of truth 原則）。
- **API リファレンス UI を提供する**（Stoplight Elements 等）。配信中の OpenAPI を参照して描画する。
  - CDN で読み込む場合は**メジャーバージョンを固定**する（`latest` は破壊的変更・供給網リスクのため禁止）。
  - リファレンス UI は**認証の背後**に置く（公開 API でない限り未認証で仕様を晒さない）。
- **OpenAPI（配信 spec）を仕様の唯一の正とする**。手書きの spec を別に持たない。スキーマ定義はコード（例: 各リポジトリのスキーマ層）を正とし、そこから spec を導出する。

## API ドキュメントは配信 spec に一本化する

API のドキュメントは**配信 spec ＋ リファレンス UI（Stoplight 等）に集約**する。別途 `docs/api.md` を設けない（内容が spec と二重化しドリフト源になるため）。人間向けのナラティブも spec に含める:

| 内容 | 置き場所（配信 spec 内） |
|------|-------------------------|
| 概要・意図 | `info.description`（Markdown） |
| 認証（方式・キー発行手順・保護対象） | `securitySchemes` ＋ `info.description` |
| 共通仕様・エラーレスポンスの形（例: `{ error }`） | 共有 `components/responses` ＋ `info.description` |
| エンドポイント一覧・request/response 定義 | `paths`（＝ リファレンス UI が描画。これが仕様の正） |
| クイックスタート（`curl` 等） | `info.description`（リファレンス UI の code sample 自動生成も活用） |

- README には配信 spec / リファレンス UI（`/openapi.json`・`/api-reference` 等）への**導線を1つ**置く。
- `info.description` に流し込む散文をリポジトリ内の Markdown に置いて spec ビルダーから読み込む形にしてもよい（実装詳細。ただし**独立した `docs/api.md` としては持たない**）。

## テスト

- API ルート、および OpenAPI spec を組み立てる箇所は**ユニットテストの作成をもって完了とする**（共通ルール「テストルール」の延長）。

---

## 正準リファレンス実装

新規に API 提供を始めるリポジトリは、実装済みの **link-hub** を正準リファレンスとして参照し、そこから複製して着手する。

- リポジトリ: https://github.com/ot-nemoto/link-hub
- 参照ポイント: OpenAPI 配信ルート・API リファレンス UI ルート・spec ビルダー（`info.description` へのナラティブ集約含む）
