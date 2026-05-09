#!/usr/bin/env bash
# Daily life dashboard generator (local execution).
# Invoked by launchd at 06:30 JST, or manually with --force.
#
# Behavior:
# - Pulls latest from origin
# - If today's post already exists and --force is not given, exits silently
# - Runs Claude Code headless to generate today's dashboard per CLAUDE.md
# - CLAUDE.md handles commit & push to main

set -euo pipefail

REPO_DIR="/Users/y-fukushima/git/daily-life-dashboard"
LOG_DIR="$REPO_DIR/logs"
TODAY=$(TZ=Asia/Tokyo date +%F)
LOG_FILE="$LOG_DIR/$TODAY.log"
POST_FILE="$REPO_DIR/_posts/$TODAY-daily.md"

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
  esac
done

mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S %Z')] $*" | tee -a "$LOG_FILE"; }

log "=== generate-daily.sh start (force=$FORCE) ==="

# Make sure PATH includes node/npm-global where claude lives
export PATH="/Users/y-fukushima/.npm-global/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

cd "$REPO_DIR"

# Sync latest first
log "git pull..."
git pull --rebase origin main >>"$LOG_FILE" 2>&1 || { log "git pull failed"; exit 1; }

# Idempotency guard
if [ -f "$POST_FILE" ] && [ "$FORCE" -eq 0 ]; then
  log "today's post already exists ($POST_FILE), skipping. Use --force to regenerate."
  exit 0
fi

# Run claude headless
log "invoking claude (model: sonnet)..."
PROMPT="このリポのCLAUDE.mdの指示に従い、今日（$TODAY、JST）の生活ダッシュボードを生成し _posts/$TODAY-daily.md として作成、main にコミット・プッシュしてください。

重要:
- TZ=Asia/Tokyo の今日の日付（$TODAY）を使うこと
- data/config.yml の location_switch_date と今日の日付を比較し、今日 < 切替日なら hachimanyama、以降なら fujimino を current location とする
- 各セクション（天気/特売/外食/献立/ゴミ/イベント）は取得失敗しても他をスキップせず最後まで実行する
- ローカル環境なのでネットワーク制限なし。WebFetchを積極的に使い、チラシ詳細・自治体ゴミカレンダー・特売価格まで取得する
- 機密情報・APIキーは扱わない
- 完了したら main にcommit & push（コミットメッセージ: 'daily: $TODAY dashboard'）"

claude \
  --dangerously-skip-permissions \
  --model "sonnet" \
  -p "$PROMPT" \
  >>"$LOG_FILE" 2>&1 || { log "claude execution failed (see log)"; exit 1; }

log "claude finished. Verifying post file..."
if [ ! -f "$POST_FILE" ]; then
  log "WARN: expected $POST_FILE was not created"
  exit 1
fi

log "=== generate-daily.sh done ==="
