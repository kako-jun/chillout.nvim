--- chillout.nvim デモ/テスト
--- 使い方: nvim -u demo/init.lua

-- プラグインのパスを追加
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local chillout = require("chillout")

-- 1. Debounce デモ (LSP診断シミュレーション)
-- 目的: 文字入力が止まるまで、重い処理の実行を遅延させる
local function run_heavy_lsp_diagnostics(text)
  print(string.format("[DEBOUNCE] 診断完了。最終入力: %s", text))
end

local debounced_diagnostics = chillout.debounce(run_heavy_lsp_diagnostics, 300)

vim.api.nvim_create_autocmd("InsertCharPre", {
  group = vim.api.nvim_create_augroup("ChilloutDemoDebounce", { clear = true }),
  callback = function()
    debounced_diagnostics(vim.api.nvim_get_current_line())
  end,
})

-- 2. Throttle デモ (Git Blame更新シミュレーション)
-- 目的: 連続したイベントを一定間隔で間引いて実行する
local function update_git_blame_sidebar()
  print("[THROTTLE] Git Blameサイドバーを更新しました。")
end

local throttled_update = chillout.throttle(update_git_blame_sidebar, 500)

vim.api.nvim_create_autocmd("CursorMoved", {
  group = vim.api.nvim_create_augroup("ChilloutDemoThrottle", { clear = true }),
  callback = function()
    throttled_update()
  end,
})

-- 3. Batch デモ (ログ集約シミュレーション)
-- 目的: 複数の呼び出しをまとめて一度に処理する
local function process_log_batch(logs)
  print(string.format("[BATCH] %d件のログをまとめて処理:", #logs))
  for i, log in ipairs(logs) do
    print(string.format("  %d: %s", i, log[1]))
  end
end

local batched_log = chillout.batch(process_log_batch, 200)

vim.api.nvim_create_autocmd("TextChanged", {
  group = vim.api.nvim_create_augroup("ChilloutDemoBatch", { clear = true }),
  callback = function()
    batched_log("テキストが変更されました: " .. os.time())
  end,
})

print("=== chillout.nvim デモ ===")
print("Debounce: 挿入モードでタイプしてみてください (300ms待機後に実行)")
print("Throttle: カーソルを動かしてみてください (500msごとに最大1回実行)")
print("Batch: ノーマルモードでテキストを変更してみてください (200ms間の変更をまとめて処理)")
print("==========================")
