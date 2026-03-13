#!/bin/bash
#
# session-logger.sh
# SessionEnd フックから呼ばれ、バックグラウンドで会話の要約を生成して logs/ に保存する。
#
# 入力: stdin から JSON（session_id, transcript_path, cwd 等）
# 出力: ~/life/logs/YYYYMMDD-HHMMSS.md
#

set -euo pipefail

LOGS_DIR="$HOME/life/logs"
MIN_LINES=10

# stdin からフックデータを読み取る
HOOK_DATA=$(cat)

SESSION_ID=$(echo "$HOOK_DATA" | jq -r '.session_id // empty')
TRANSCRIPT_PATH=$(echo "$HOOK_DATA" | jq -r '.transcript_path // empty')
CWD=$(echo "$HOOK_DATA" | jq -r '.cwd // empty')

# 必須データがなければ終了
if [[ -z "$SESSION_ID" || -z "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# 会話ログが存在しなければ終了
if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# 短すぎるセッションはスキップ
LINE_COUNT=$(wc -l < "$TRANSCRIPT_PATH" | tr -d ' ')
if [[ "$LINE_COUNT" -lt "$MIN_LINES" ]]; then
  exit 0
fi

# バックグラウンドで要約生成（フックのタイムアウトを回避）
(
  mkdir -p "$LOGS_DIR"

  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  OUTPUT_FILE="$LOGS_DIR/${TIMESTAMP}.md"
  DATE_FORMATTED=$(date +"%Y-%m-%d %H:%M:%S")

  # 会話ログをトークン節約のために末尾 500 行に制限
  TRANSCRIPT_CONTENT=$(tail -500 "$TRANSCRIPT_PATH")

  PROMPT=$(cat <<'PROMPT_EOF'
あなたはセッションログの要約を生成するアシスタントです。
以下の会話ログ（JSONL形式）を読み、指定されたフォーマットで要約を出力してください。

## 出力フォーマット（Markdown）

必ず以下の構造で出力してください。frontmatter も含めてください。

---
session_id: {{SESSION_ID}}
date: {{DATE}}
project: {{CWD}}
---

## セッション概要
（何をしたか、どんな話をしたかを3〜5文で要約）

## 学び・気づき
（技術的な学び、新しい知識、考え方の変化。箇条書き）

## パーソナリティメモ
（ユーザーの価値観・判断基準・行動パターン・興味関心に関する気づき。
 会話から読み取れる性格的特徴や、意思決定の傾向を記録する。
 表面的な事実ではなく、「なぜそう判断したか」「何を重視しているか」に注目すること。
 特に読み取れるものがなければ「特になし」と書く）

## 会話ログ
- セッションID: `{{SESSION_ID}}`
- `claude --resume {{SESSION_ID}}` で詳細を確認可能

## ルール
- 日本語で出力すること
- frontmatter の {{SESSION_ID}}, {{DATE}}, {{CWD}} はそのまま出力すること（後でスクリプトが置換する）
- セクションの順序を変えないこと
- パーソナリティメモは事実の羅列ではなく、ユーザーの内面に関する洞察を書くこと
PROMPT_EOF
)

  # claude -p で要約を生成
  SUMMARY=$(echo "$TRANSCRIPT_CONTENT" | claude -p \
    --output-format text \
    --no-session-persistence \
    --model sonnet \
    "$PROMPT" 2>/dev/null) || true

  # 要約が空なら終了
  if [[ -z "$SUMMARY" ]]; then
    exit 0
  fi

  # プレースホルダーを実際の値で置換
  SUMMARY=$(echo "$SUMMARY" | sed \
    -e "s|{{SESSION_ID}}|$SESSION_ID|g" \
    -e "s|{{DATE}}|$DATE_FORMATTED|g" \
    -e "s|{{CWD}}|$CWD|g")

  echo "$SUMMARY" > "$OUTPUT_FILE"

) &

exit 0
