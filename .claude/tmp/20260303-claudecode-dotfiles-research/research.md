# リサーチ: dotfiles × Claude Code 設定

## 調査範囲

- Claude Code の設定体系（CLAUDE.md・hooks・skills・settings.json・rules）の役割と使い分け
- グローバル設定 vs プロジェクト設定: 何をどこに書くべきか
- GitHub の優れた dotfiles・設定リポジトリの実例
- 現在の自分の設定（`~/dotfiles/.claude/`）との比較

---

## 1. Claude Code の設定ファイル体系（全体像）

### 設定の優先度（高い順）

| 優先度 | 場所 | 用途 |
|--------|------|------|
| 1（最高） | Managed Policy（`/Library/Application Support/ClaudeCode/`） | 組織全体の強制ポリシー（IT 管理） |
| 2 | CLI フラグ | セッション単位の上書き |
| 3 | Local（`.claude/settings.local.json`） | 個人用プロジェクト設定（git 管理外） |
| 4 | Project（`.claude/settings.json`） | チーム共有プロジェクト設定（git 管理） |
| 5（最低） | User（`~/.claude/settings.json`） | 全プロジェクト共通の個人デフォルト |

**重要:** deny ルールは allow より先に評価される。ルールは配列のマージで重複適用される（上書きではない）。

### CLAUDE.md の設置場所と役割

| スコープ | パス | 用途 | 共有 |
|---------|------|------|------|
| Managed Policy | `/Library/Application Support/ClaudeCode/CLAUDE.md` | 組織全体の強制ルール | 全ユーザー |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | チーム共有のプロジェクトルール | git 経由 |
| User（グローバル） | `~/.claude/CLAUDE.md` | 全プロジェクト共通の個人設定 | 自分のみ |
| Local（個人プロジェクト） | `./CLAUDE.local.md` | 個人のプロジェクト固有設定 | git 管理外 |

**読み込みルール:**
- カレントディレクトリから親ディレクトリを遡って CLAUDE.md を全部読み込む
- サブディレクトリの CLAUDE.md はそのディレクトリのファイルを読んだときに遅延ロード
- `@path/to/file` 記法で他ファイルをインポートできる（最大 5 ホップ）
- 200 行以内が推奨（超えると遵守率が下がる）

---

## 2. CLAUDE.md の書き方ベストプラクティス

### 効果的な書き方の原則

1. **具体的に書く**: 「コードを綺麗にして」より「2スペースのインデントを使う」
2. **検証可能にする**: 「テストを実行してからコミットせよ」ではなく「`npm test` を実行してからコミット」
3. **矛盾を排除する**: 複数ファイルで矛盾するルールがあると Claude が勝手に選ぶ
4. **構造化する**: markdown ヘッダーと箇条書きで整理（Claude も読者と同じようにスキャンする）
5. **200 行以内**: 超えたら `.claude/rules/` に分割

### 分割ストラテジー: `.claude/rules/` ディレクトリ

```
.claude/
├── CLAUDE.md           # メインの指示（200行以内）
└── rules/
    ├── code-style.md   # コードスタイルのみ
    ├── testing.md      # テスト規約のみ
    └── security.md     # セキュリティ要件のみ
```

**path-specific rules（新機能）:** YAML frontmatter で特定ファイルパターンにのみ適用できる

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API 開発ルール（このパスのファイルを読んだときだけロード）
```

### グローバル CLAUDE.md vs プロジェクト CLAUDE.md

| 書くべき内容 | 場所 |
|-------------|------|
| 個人の好み（言語、コードスタイル）、よく使うツールのショートカット | `~/.claude/CLAUDE.md` |
| プロジェクトのアーキテクチャ、ビルドコマンド、コーディング規約 | `./CLAUDE.md` or `./.claude/CLAUDE.md` |
| サンドボックス URL、テストデータ、個人的な実験設定 | `./CLAUDE.local.md` |

---

## 3. Auto Memory（自動メモリ）

Claude が自分でメモを残す仕組み。セッションを跨いで知識を蓄積する。

### 保存先

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # インデックス（毎セッション最初の200行だけ読み込まれる）
├── debugging.md       # デバッグパターンの詳細ノート
└── patterns.md        # コーディングパターン
```

**特徴:**
- `MEMORY.md` の最初 200 行がセッション開始時に自動ロード
- Claude が学んだことを自動的に書き込む（ユーザーが書いた CLAUDE.md とは別物）
- `ユーザーがユーザー自身で管理したい場合は CLAUDE.md に書くよう指示すれば良い`
- `/memory` コマンドで確認・編集可能

---

## 4. Skills（スラッシュコマンド）

### 基本構造

```
~/.claude/skills/       ← グローバル（全プロジェクト共通）
└── skill-name/
    ├── SKILL.md        # メイン指示（必須）
    ├── reference.md    # 詳細リファレンス（任意）
    └── scripts/
        └── helper.sh  # 補助スクリプト（任意）

.claude/skills/         ← プロジェクト専用
└── skill-name/
    └── SKILL.md
```

### SKILL.md のフロントマター

```yaml
---
name: my-skill                    # スラッシュコマンド名（省略時はディレクトリ名）
description: このスキルの説明     # Claude が自動起動するかの判断に使う
disable-model-invocation: true    # true にするとユーザーだけが起動可能（Claude は自動起動しない）
user-invocable: false             # false にすると /menu に表示されない（Claudeだけが使える）
allowed-tools: Read, Grep         # このスキル実行中に使えるツールを制限
context: fork                     # サブエージェントとして独立実行
agent: Explore                    # context: fork 時に使うエージェントタイプ
---
```

### 呼び出し制御の使い分け

| フロントマター | ユーザー起動 | Claude 自動起動 | 用途 |
|--------------|------------|----------------|------|
| デフォルト | ○ | ○ | 一般的なスキル |
| `disable-model-invocation: true` | ○ | ✗ | `/deploy`、`/commit` など副作用のある操作 |
| `user-invocable: false` | ✗ | ○ | 背景知識（レガシーシステムの文脈など） |

### 動的コンテキスト注入

```yaml
## PR コンテキスト
- PR diff: !`gh pr diff`         ← 実行時にコマンド出力が挿入される（プリプロセス）
```

---

## 5. Hooks（ライフサイクル自動化）

### 全イベント一覧（17種類）

| イベント | タイミング | 主なユースケース |
|---------|-----------|---------------|
| `SessionStart` | セッション開始・再開・compact 後 | コンテキスト再注入、環境確認 |
| `UserPromptSubmit` | ユーザーがプロンプトを送信する直前 | プロンプト検証、コンテキスト追加 |
| `PreToolUse` | ツール実行前（ブロック可能） | 危険コマンド防止、保護ファイルへの書き込み禁止 |
| `PermissionRequest` | 許可ダイアログ表示時 | 通知、カスタム許可ロジック |
| `PostToolUse` | ツール成功後 | 自動フォーマット、ログ記録 |
| `PostToolUseFailure` | ツール失敗後 | エラーハンドリング、リトライ |
| `Notification` | Claude が入力待ち時 | 通知音、デスクトップ通知 |
| `SubagentStart` | サブエージェント起動時 | - |
| `SubagentStop` | サブエージェント終了時 | - |
| `Stop` | Claude が返答完了時 | タスク完了確認、通知 |
| `TeammateIdle` | エージェントチームのアイドル時 | - |
| `TaskCompleted` | タスク完了マーク時 | - |
| `ConfigChange` | 設定ファイル変更時 | 変更の監査ログ |
| `WorktreeCreate` | worktree 作成時 | カスタム worktree 作成ロジック |
| `WorktreeRemove` | worktree 削除時 | - |
| `PreCompact` | コンテキスト圧縮前 | 重要情報の保存 |
| `SessionEnd` | セッション終了時 | 一時ファイルの削除 |

### フックの4つの種類

| タイプ | 用途 |
|--------|------|
| `"type": "command"` | シェルコマンド実行（最も一般的） |
| `"type": "http"` | HTTP エンドポイントに POST（チームでの監査サーバーなど） |
| `"type": "prompt"` | Claude Haiku による判断（ルールで書けない柔軟な判断） |
| `"type": "agent"` | サブエージェントによる検証（ファイル読み込みやコマンド実行が必要な検証） |

### 終了コードの意味

- **exit 0**: 許可。stdout に書いた内容は Claude のコンテキストに追加される
- **exit 2**: ブロック。stderr に書いた内容が Claude へのフィードバックとして返される
- **その他**: 許可。エラーはログに記録されるが Claude には見えない

### フックのスコープ

| 設定ファイル | スコープ |
|------------|---------|
| `~/.claude/settings.json` | 全プロジェクト（git 管理外） |
| `.claude/settings.json` | プロジェクト単位（git 管理可） |
| `.claude/settings.local.json` | プロジェクト単位（個人設定） |

### 実用的なユースケース例

**1. 自動フォーマット（PostToolUse）**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"}]
    }]
  }
}
```

**2. 危険コマンドをブロック（PreToolUse）**
- exit 2 でブロック + stderr にフィードバックを書く

**3. compact 後のコンテキスト再注入（SessionStart）**
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "compact",
      "hooks": [{"type": "command", "command": "echo 'Reminder: bun を使う。コミット前に bun test を実行'"}]
    }]
  }
}
```

**4. タスク完了後の確認（Stopフックにpromptタイプ）**
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{"type": "prompt", "prompt": "すべてのタスクが完了しているか確認。未完了があれば {\"ok\": false, \"reason\": \"残りのタスク\"} を返す"}]
    }]
  }
}
```

---

## 6. settings.json の全体像

### permissions の設定

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read", "WebFetch"],
    "ask":   ["Bash(git push *)"],
    "deny":  ["Bash(rm *)", "Read(.env)"]
  }
}
```

**パターン構文:**
- `Bash(npm *)` → npm で始まるコマンド
- `Read(./.env)` → 特定ファイル
- `Read(./secrets/**)` → ディレクトリ再帰
- `WebFetch(domain:example.com)` → ドメイン制限
- `Skill(commit)` → 特定スキルの許可/拒否

### その他の設定項目

```json
{
  "model": "claude-opus-4-6",           // デフォルトモデル
  "autoMemoryEnabled": false,           // 自動メモリの有効/無効
  "enterForNewline": true,              // Enter で改行（Shift+Enter で送信）
  "alwaysThinkingEnabled": false,       // 常に extended thinking を有効化
  "claudeMdExcludes": ["**/other-team/.claude/rules/**"],  // 除外する CLAUDE.md
  "statusLine": {                       // ステータスライン
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

---

## 7. 優れた dotfiles リポジトリの実例と知見

### Trail of Bits（セキュリティ会社）のアプローチ

- **セキュリティ重視:** `.env`、SSH キー、クラウド設定、git クレデンシャルへのアクセスをデフォルトでブロック
- **hooks で危険操作を防止:** `rm -rf` のブロック、main ブランチへのプッシュを禁止
- **カスタムコマンド:** `/review-pr`, `/fix-issue`, `/merge-dependabot` を整備
- **推奨 MCP サーバー:** Context7（ドキュメント）, Exa（ウェブ検索）
- **Ghostty ターミナル推奨:** 大量テキスト処理時のラグなし

### citypaul/.dotfiles（個人）のアプローチ

- **TDD 強制:** 「Test-Driven Development は non-negotiable」をCLAUDE.mdに明記
- **スキルの自動起動:** テストを書くとき → testing スキル、型を決めるとき → TypeScript スキル
- **優先度システム:** 🔴Critical/⚠️High/💡Nice/✅Skip でリファクタリング判断を明確化

### コミュニティのベストプラクティス（awesome-claude-code より）

- **軽量エージェントオーケストレーション**: グローバルに太らせず、プロジェクトに閉じた設定を好む
- **スキルカテゴリ分類**: ドメイン専門知識 / ワークフロー自動化 / コンテキスト管理 / 安全性検証
- **セキュリティフック**: "parry" のような injection attack スキャンを入れる事例も

---

## 8. 現在の自分の設定の分析

### `~/.claude/settings.json`（グローバル設定）の現状

**良い点:**
- Stop / PermissionRequest フックで音声通知・ウィンドウフォーカスを実装済み
- rm/rmdir を deny で保護済み
- statusLine をカスタムスクリプトで実装済み
- 主要な読み取り系 Bash コマンドを細かく allow リストに追加済み

**改善余地:**
- `allow` リストが長すぎ・細かすぎる（brew --prefix, brew --version など個別に羅列している）→ ワイルドカードで整理できる
- `Bash(cd:*)`, `Bash(echo:*)` は実際に使われているか疑問（Claude が直接 cd を実行するシーンは稀）
- PostToolUse の自動フォーマットフックがない
- UserPromptSubmit や SessionStart フックがない（compact 後のコンテキスト再注入など）
- `PreToolUse` の危険コマンド防止フックがない

### `~/.claude/CLAUDE.md`（グローバル CLAUDE.md）

- 存在しない（現在は `~/dotfiles/.claude/CLAUDE.md` のみ）
- グローバルな個人設定（言語指定、コミュニケーションスタイルなど）は `~/.claude/CLAUDE.md` に書くべき

### `~/dotfiles/.claude/CLAUDE.md`（dotfiles プロジェクト専用）

**良い点:**
- 日本語対応・ユーザー名・コミュニケーション指針を明記
- Bash コマンドの規約（trash 使用、date コマンド、Brewfile 更新）を網羅
- 一時ファイルの保存場所を指定

**改善余地:**
- このファイルはプロジェクト固有（dotfiles リポジトリ）の指示だが、実質グローバル設定が混在している
- 「必ず日本語で対応」などは `~/.claude/CLAUDE.md`（グローバル）に書くべき内容
- `.claude/rules/` ディレクトリを使って役割別に分割できる
- 200 行以内だが、将来的な成長を考えると今から分割設計するのが良い

### `.claude/skills/` の現状

- `structured-workflow/SKILL.md` ✅ 充実している
- `skill-creator/SKILL.md` ✅ あり
- グローバルスキル（`~/.claude/skills/`）: superpowers スキル群が入っている

---

## 9. 重要な発見・注意点

### 設計上の重要な原則

1. **CLAUDE.md は強制ではなくコンテキスト**: Claude は読んで従おうとするが保証はない。具体的・検証可能な指示ほど遵守率が上がる
2. **settings.json が唯一の強制機構**: 許可/拒否はここでしか実現できない。CLAUDE.md に「rm を使うな」と書いても deny ルールの代わりにはならない
3. **hooks は決定論的な制御**: LLM の判断に依存せず、確実に動作させたいことはフックで実装する
4. **スキルは遅延ロード**: 全スキルの説明文だけがコンテキストに入り、内容は呼び出し時にロード（コンテキスト節約）

### グローバル vs プロジェクトの使い分けまとめ

| 何を書くか | 置くべき場所 |
|-----------|------------|
| 言語指定、コミュニケーションスタイル、個人の好み | `~/.claude/CLAUDE.md` |
| 個人で全プロジェクト共通のツール許可（brew, gh, git など） | `~/.claude/settings.json` |
| 通知・完了音など個人の UX 設定（フック） | `~/.claude/settings.json` |
| プロジェクト固有のアーキテクチャ・規約 | `./.claude/CLAUDE.md` |
| チームで共有すべき許可/拒否ルール | `./.claude/settings.json` |
| 個人的なプロジェクト設定（サンドボックス URL など） | `./.claude/settings.local.json` |

### Auto Memory と CLAUDE.md の共存

- CLAUDE.md: 自分が明示的に管理したいルール（コーディング規約、ツール使い方）
- Auto Memory: Claude が自律的に学んだ知見（ビルドコマンド、デバッグパターン）
- 「覚えておいて」→ Auto Memory / 「CLAUDE.md に追加して」→ CLAUDE.md に書かれる

### compact 後の問題

- CLAUDE.md は compact 後もディスクから再読み込みされる（消えない）
- チャット中だけで伝えた指示は compact 後に消える → CLAUDE.md に書くべき

---

## 10. 未解決の疑問

1. **rules ディレクトリのグローバル版**: `~/.claude/rules/` は存在するか？ → 公式ドキュメントに「User-level rules in `~/.claude/rules/`」の記述あり。存在する
2. **settings.local.json のグローバル版**: `~/.claude/settings.local.json` は意味があるか？ → `~/.claude/settings.json` 自体がプロジェクトから見ると "User" スコープなので、`settings.local.json` のグローバル版は不要
3. **superpowers スキルの構造**: 現在使用中の superpowers スキルはどのような仕組みで動いているか（plugin 経由）→ 別途調査の余地あり

---

## 参考リソース

- [Claude Code 公式ドキュメント](https://code.claude.com/docs)
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - コミュニティキュレーション
- [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) - セキュリティ重視の実例
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) - TDD 強制の個人 dotfiles
- [Claude Code settings reference](https://claudefa.st/blog/guide/settings-reference)
- [hooks guide](https://code.claude.com/docs/en/hooks-guide)
- [skills documentation](https://code.claude.com/docs/en/skills)
- [memory documentation](https://code.claude.com/docs/en/memory)
