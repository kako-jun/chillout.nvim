# chillout.nvim

[![Tests](https://github.com/kako-jun/chillout.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/kako-jun/chillout.nvim/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Neovim Lua 向けの debounce, throttle, batch ライブラリ。

![demo](https://github.com/kako-jun/chillout.nvim/raw/main/assets/demo.gif)

## 必要環境

- Neovim >= 0.10

## インストール

### lazy.nvim

```lua
{
  "kako-jun/chillout.nvim",
}
```

### packer.nvim

```lua
use "kako-jun/chillout.nvim"
```

## 使い方

```lua
local chillout = require("chillout")

-- Debounce: 呼び出しが止まるまで待ってから実行
local debounced = chillout.debounce(function(text)
  print("入力完了: " .. text)
end, 300)

-- Throttle: 一定間隔で最大1回のみ実行
local throttled = chillout.throttle(function()
  print("更新中...")
end, 500)

-- Batch: 呼び出しをまとめて一度に処理
local batched = chillout.batch(function(items)
  print(#items .. "件を処理")
end, 200)
```

## API

### `chillout.debounce(func, wait, opts?)`

最後の呼び出しから `wait` ミリ秒経過するまで実行を遅延する関数を作成。

**オプション:**
- `maxWait` (number): 強制実行までの最大待機時間

```lua
-- 検索サジェスト: 入力が止まったら表示、ただし最大3秒
local search = chillout.debounce(run_search, 500, { maxWait = 3000 })

-- 自動保存: 編集が止まるまで待つ
local save = chillout.debounce(save_file, 1000)
```

### `chillout.throttle(func, wait, opts?)`

`wait` ミリ秒あたり最大1回のみ実行する関数を作成。

**オプション:**
- `leading` (boolean): 最初の呼び出しで即実行 (デフォルト: true)
- `trailing` (boolean): 最後の呼び出しを実行 (デフォルト: true)

```lua
-- スクロール追従: 即座に更新、その後は間引く
local scroll = chillout.throttle(update_minimap, 100, { leading = true })

-- リサイズ: 完了後のみ実行
local resize = chillout.throttle(recalc_layout, 200, { leading = false, trailing = true })
```

### `chillout.batch(func, wait, opts?)`

`wait` ミリ秒間の呼び出しをまとめて、引数の配列として一度に処理する関数を作成。

**オプション:**
- `maxSize` (number): 強制実行までの最大バッチサイズ

```lua
-- ログ送信: 5秒ごと、または100件で送信
local log = chillout.batch(send_logs, 5000, { maxSize = 100 })

-- イベント集約: 200ms間のイベントをまとめる
local events = chillout.batch(process_events, 200)
```

## ユースケース

| ユースケース | 関数 | オプション |
|-------------|------|-----------|
| 検索サジェスト | debounce | `{ maxWait = 3000 }` |
| 自動保存 | debounce | (なし) |
| スクロール追従UI | throttle | `{ leading = true }` |
| リサイズ完了後処理 | throttle | `{ leading = false }` |
| ログ送信 | batch | `{ maxSize = 100 }` |
| イベント集約 | batch | (なし) |

## 実践例

### 検索サジェスト (debounce + maxWait)

```lua
-- 入力が止まったらサジェスト表示、ただし待ちすぎない
local suggest = chillout.debounce(show_suggestions, 300, { maxWait = 2000 })
```

### 自動保存 (debounce)

```lua
-- 編集が止まったら保存
local auto_save = chillout.debounce(function()
  vim.cmd("silent! write")
end, 1000)
```

### スクロール追従UI (throttle + leading)

```lua
-- スクロール時にミニマップを即更新、その後は間引く
local update_minimap = chillout.throttle(render_minimap, 100, { leading = true })
```

### ウィンドウリサイズ (throttle + trailing only)

```lua
-- リサイズ完了後のみレイアウト再計算
local on_resize = chillout.throttle(recalc_layout, 200, { leading = false, trailing = true })
```

### ログ送信 (batch + maxSize)

```lua
-- 100件ごと、または5秒ごとにログ送信
local send_log = chillout.batch(send_to_server, 5000, { maxSize = 100 })
```

### イベント集約 (batch)

```lua
-- ファイル変更イベントをまとめて処理
local on_change = chillout.batch(process_changes, 200)
```

## なぜ chillout.nvim?

- **既存ソリューションがない** - Neovim には debounce/throttle/batch 専用ライブラリがなかった
- **Neovim ネイティブ** - `vim.uv` (libuv) を使用、外部依存なし
- **機能完備** - `maxWait`, `leading/trailing`, `maxSize` などのオプションを提供
- **軽量** - 合計約150行のコード

## コントリビュート

Issue や PR を歓迎します。

## ライセンス

[MIT](LICENSE)
