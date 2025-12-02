# chillout.nvim 開発者向けドキュメント

NeovimのLua環境において、イベント駆動型で発生する非同期処理の実行タイミングと頻度を制御するプラグイン。

## コンセプト

「落ち着け (chill out)」- 頻繁なイベントによるパフォーマンス低下を防ぎ、ユーザー体験を向上させる。

**重要**: このプラグインは入力やカーソル移動自体を遅延させるものではない。コールバック関数の実行回数を抑制する。

## コア機能 (3つ)

| 機能 | API | 概要 |
|------|-----|------|
| Debounce | `M.debounce(func, wait, opts?)` | 最後の呼び出しから `wait` ms 経過まで実行を遅延。連続呼び出しでリセット。 |
| Throttle | `M.throttle(func, wait, opts?)` | 一度実行後、`wait` ms 経過まで次の実行を抑制。 |
| Batch | `M.batch(func, wait, opts?)` | `wait` ms 間の呼び出しをまとめて1回で処理。 |

## オプション

### Debounce

```lua
chillout.debounce(func, wait, {
  maxWait = number,  -- 最大待機時間。入力が続いても強制実行
})
```

### Throttle

```lua
chillout.throttle(func, wait, {
  leading = boolean,   -- 最初の呼び出しで即実行 (default: true)
  trailing = boolean,  -- 最後の呼び出しを実行 (default: true)
})
```

### Batch

```lua
chillout.batch(func, wait, {
  maxSize = number,  -- 最大バッチサイズ。N件で即実行
})
```

## ユースケース

| ユースケース | 関数 | 設定例 |
|-------------|------|--------|
| 検索サジェスト | debounce | `{ maxWait = 3000 }` - 入力中でも3秒で表示 |
| 自動保存 | debounce | オプションなし - 編集が止まるまで待つ |
| スクロール追従UI | throttle | `{ leading = true }` - 最初に即更新 |
| リサイズ完了後処理 | throttle | `{ leading = false, trailing = true }` - 完了後のみ |
| ログ送信 | batch | `{ maxSize = 100 }` - 100件で即送信 |
| イベント集約 | batch | オプションなし - 時間ベースで集約 |

## プロジェクト構造

```
chillout.nvim/
├── lua/
│   └── chillout/
│       └── init.lua    -- コア実装 (debounce, throttle, batch)
├── demo/
│   └── init.lua        -- デモ/テスト用
├── CLAUDE.md           -- 本ファイル
└── README.md           -- ユーザー向けドキュメント
```

## 動作仕様

### Debounce

```
呼び出し T=0      → タイマーセット (実行なし)
呼び出し T=200    → タイマーリセット (実行なし)
(wait=300)
タイマー満了 T=500 → 実行 (1回)
```

maxWait を設定した場合:
```
呼び出し T=0      → タイマーセット + maxWaitタイマーセット
呼び出し T=200    → タイマーリセット (maxWaitはリセットしない)
呼び出し T=400    → タイマーリセット
...
(maxWait=1000)
T=1000            → maxWait満了、強制実行
```

### Throttle

leading=true, trailing=true (デフォルト):
```
呼び出し T=0      → 即時実行 + タイマーセット (実行1回)
呼び出し T=200    → pending=true (実行なし)
(wait=500)
タイマー満了 T=500 → pending消化 (実行2回目)
```

leading=false, trailing=true:
```
呼び出し T=0      → pending=true, タイマーセット (実行なし)
呼び出し T=200    → pending=true (実行なし)
(wait=500)
タイマー満了 T=500 → pending消化 (実行1回)
```

### Batch

```
呼び出し T=0   args=["a"] → batch=[["a"]], タイマーセット
呼び出し T=50  args=["b"] → batch=[["a"],["b"]]
呼び出し T=100 args=["c"] → batch=[["a"],["b"],["c"]]
(wait=200)
タイマー満了 T=200        → func([["a"],["b"],["c"]]) 実行
```

maxSize を設定した場合:
```
(maxSize=2)
呼び出し T=0   args=["a"] → batch=[["a"]], タイマーセット
呼び出し T=50  args=["b"] → batch=[["a"],["b"]], maxSize到達 → 即実行
呼び出し T=100 args=["c"] → batch=[["c"]], タイマーセット
```

## 実装メモ

- タイマーは `vim.uv.new_timer()` を使用 (libuv)
- コールバックは `vim.schedule_wrap()` でラップ (Vim APIはメインスレッドから呼ぶ必要があるため)
- タイマーは使用後に `stop()` と `close()` を呼ぶ

## テスト実行

```bash
cd chillout.nvim
nvim -u demo/init.lua
```

## 設計方針

- APIは3つだけ。シンプルに保つ
- 各関数に実用的なオプションを1-2個だけ提供
- デフォルト値は最も一般的なユースケースに合わせる
