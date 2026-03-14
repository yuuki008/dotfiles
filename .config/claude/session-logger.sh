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
# stdin/stdout/stderr を閉じ、disown でプロセスを完全にデタッチする
(
  mkdir -p "$LOGS_DIR"

  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  OUTPUT_FILE="$LOGS_DIR/${TIMESTAMP}.md"
  DATE_FORMATTED=$(date +"%Y-%m-%d %H:%M:%S")

  # 会話ログからユーザーとアシスタントのメッセージのみ抽出し、サイズを制限
  # JSONL の各行にはツール出力等が含まれ巨大になるため、role ベースでフィルタリング
  TRANSCRIPT_CONTENT=$(jq -c 'select(.type == "human" or .type == "assistant") | {type, message: (.message // .content // "" | tostring | .[0:2000])}' "$TRANSCRIPT_PATH" 2>/dev/null | tail -200 | head -c 100000)

  # 機密情報のパターンを事前にマスクする（Claude に送る前にフィルタリング）
  TRANSCRIPT_CONTENT=$(echo "$TRANSCRIPT_CONTENT" | sed -E \
    -e 's/(Bearer |token[= :"'"'"']+|Authorization[= :"'"'"']+)[A-Za-z0-9_\.\-]{8,}/\1[REDACTED]/gi' \
    -e 's/([A-Za-z0-9+\/]{40,}={0,2})/[REDACTED_BASE64]/g' \
    -e 's/(ghp_|gho_|ghu_|ghs_|github_pat_)[A-Za-z0-9_]{10,}/[REDACTED_GITHUB_TOKEN]/g' \
    -e 's/(sk-|pk_live_|pk_test_|sk_live_|sk_test_)[A-Za-z0-9_\-]{10,}/[REDACTED_API_KEY]/g' \
    -e 's/(AKIA|ASIA)[A-Z0-9]{14,}/[REDACTED_AWS_KEY]/g' \
    -e 's/xox[bpsar]-[A-Za-z0-9\-]{10,}/[REDACTED_SLACK_TOKEN]/g' \
    -e 's/(password|passwd|secret|private.key)[= :"'"'"']+[^ "'"'"']{4,}/\1=[REDACTED]/gi' \
    -e 's/[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}/[REDACTED_CARD]/g' \
    -e 's/[0-9]{3}-[0-9]{4}-[0-9]{4}/[REDACTED_PHONE]/g' \
    -e 's/-----BEGIN [A-Z ]*PRIVATE KEY-----[^-]*-----END [A-Z ]*PRIVATE KEY-----/[REDACTED_PRIVATE_KEY]/g' \
  )

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

## 機密情報の取り扱い（最重要）
以下の情報は要約に**絶対に含めないこと**。会話中に登場しても、要約では一切記載せず無視すること。
- APIキー、トークン、パスワード、シークレット、認証情報（例: Bearer, sk-, ghp_, xox- 等）
- 秘密鍵・証明書の内容
- 個人を特定できる情報（メールアドレス、電話番号、住所、クレジットカード番号、マイナンバー等）
- 環境変数に含まれる機密値（DATABASE_URL, SECRET_KEY 等の具体的な値）
- [REDACTED] とマスクされた文字列はそのまま「機密情報があった」とだけ認識し、復元を試みないこと
- 会話の中で「秘密」「内緒」「他の人には言わないで」等と指定された情報
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

) </dev/null >/dev/null 2>&1 &
disown

exit 0
