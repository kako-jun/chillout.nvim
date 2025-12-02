# chillout.nvim 開発者向けドキュメント

NeovimのLua環境において、イベント駆動型で発生する非同期処理の実行タイミングと頻度を制御するプラグイン。

## コンセプト

「落ち着け (chill out)」- 頻繁なイベントによるパフォーマンス低下を防ぎ、ユーザー体験を向上させる。

## コア機能 (3つ)

| 機能 | API | 概要 |
|------|-----|------|
| Debounce | `M.debounce(func, wait)` | 最後の呼び出しから `wait` ms 経過まで実行を遅延。連続呼び出しでリセット。 |
| Throttle | `M.throttle(func, wait)` | 一度実行後、`wait` ms 経過まで次の実行を抑制。末尾実行方式。 |
| Batch | `M.batch(func, wait)` | `wait` ms 間の呼び出しをまとめて1回で処理。 |

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

適切なユースケース: LSP診断、入力時のサジェスト（ユーザー操作完了後に処理したい場合）

### Throttle (Trailing Edge)

```
呼び出し T=0      → 即時実行 + タイマーセット (実行1回)
呼び出し T=200    → pending=true (実行なし)
(wait=500)
タイマー満了 T=500 → pending消化 (実行2回目)
```

適切なユースケース: ウィンドウリサイズ、スクロール時の画面更新（頻繁なイベントを間引きたい場合）

### Batch

```
呼び出し T=0   args=["a"] → batch=[["a"]], タイマーセット
呼び出し T=50  args=["b"] → batch=[["a"],["b"]]
呼び出し T=100 args=["c"] → batch=[["a"],["b"],["c"]]
(wait=200)
タイマー満了 T=200        → func([["a"],["b"],["c"]]) 実行
```

適切なユースケース: ログ集約、複数イベントの一括処理

## 実装メモ

- タイマーは `vim.uv.new_timer()` を使用 (libuv)
- コールバックは `vim.schedule_wrap()` でラップ (Vim APIはメインスレッドから呼ぶ必要があるため)
- タイマーは使用後に `stop()` と `close()` を呼ぶ

## テスト実行

```bash
nvim -u demo/init.lua
```

## 設計方針

- APIは3つだけ。シンプルに保つ
- 将来の拡張 (leading edge オプション等) は必要になってから追加
