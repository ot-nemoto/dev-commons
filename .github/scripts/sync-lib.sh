#!/usr/bin/env bash
# sync-standards / check-drift 共通ライブラリ。
# 使い方: 呼び出し側で CFG（sync-config.json のパス）を設定してから source する。

# プロファイルを解決して配布ファイル一覧を返す（extends は配列プロファイルへの1段参照のみ）
resolve_files() {
  jq -r --arg p "$1" '
    .profiles[$p] as $x
    | if ($x|type)=="array" then $x[]
      else (.profiles[$x.extends][], $x.add[]) end
  ' "$CFG"
}

# 全プロファイルの配布ファイルがソースルート配下に実在するか検証する
# 引数: $1 = ソースルート（例: "$PWD/sync"）
validate_sources() {
  local src_root="$1" rc=0
  for p in $(jq -r '.targets[]' "$CFG" | sort -u); do
    for f in $(resolve_files "$p"); do
      if [ ! -f "$src_root/$f" ]; then
        echo "::error::source not found: sync/$f (profile=$p)"
        rc=1
      fi
    done
  done
  return $rc
}
