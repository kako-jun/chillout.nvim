--- chillout.nvim デモ/テスト
--- 使い方: cd chillout.nvim && nvim -u demo/init.lua

-- プラグインのパスを追加 (このファイルの親ディレクトリ)
local script_path = debug.getinfo(1, "S").source:sub(2)
local plugin_path = vim.fn.fnamemodify(script_path, ":h:h")
vim.opt.runtimepath:prepend(plugin_path)

local ok, chillout = pcall(require, "chillout")
if not ok then
  print("ERROR: chillout モジュールが見つかりません")
  print("plugin_path: " .. plugin_path)
  return
end

-- カウンター
local debounce_calls = 0
local debounce_execs = 0
local throttle_calls = 0
local throttle_execs = 0
local batch_calls = 0
local batch_execs = 0

-- 1. Debounce デモ
local debounced = chillout.debounce(function()
  debounce_execs = debounce_execs + 1
  print(string.format("[DEBOUNCE] 表示! (呼び出し %d回 → 表示 %d回)", debounce_calls, debounce_execs))
end, 2000, { maxWait = 6000 })

vim.keymap.set("n", "d", function()
  debounce_calls = debounce_calls + 1
  print(string.format("[DEBOUNCE] d押下 #%d (2秒待機中...)", debounce_calls))
  debounced()
end, { desc = "Debounce demo" })

-- 2. Throttle デモ
local throttled = chillout.throttle(function()
  throttle_execs = throttle_execs + 1
  print(string.format("[THROTTLE] 表示! (呼び出し %d回 → 表示 %d回)", throttle_calls, throttle_execs))
end, 3000, { leading = true, trailing = true })

vim.keymap.set("n", "t", function()
  throttle_calls = throttle_calls + 1
  print(string.format("[THROTTLE] t押下 #%d", throttle_calls))
  throttled()
end, { desc = "Throttle demo" })

-- 3. Batch デモ
local batched = chillout.batch(function(items)
  batch_execs = batch_execs + 1
  print(string.format("[BATCH] 表示! %d件をまとめて処理 (呼び出し %d回 → 表示 %d回)", #items, batch_calls, batch_execs))
end, 999999, { maxSize = 5 })

vim.keymap.set("n", "b", function()
  batch_calls = batch_calls + 1
  print(string.format("[BATCH] b押下 #%d (蓄積中...)", batch_calls))
  batched(batch_calls)
end, { desc = "Batch demo" })

-- リセット
vim.keymap.set("n", "r", function()
  debounce_calls = 0
  debounce_execs = 0
  throttle_calls = 0
  throttle_execs = 0
  batch_calls = 0
  batch_execs = 0
  print("[RESET] カウンターをリセットしました")
end, { desc = "Reset counters" })

print("")
print("╔══════════════════════════════════════════════════════════════╗")
print("║                      chillout.nvim デモ                      ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("")
print("# このプラグインは何をするか?")
print("")
print("  キー入力自体を遅延させるのではなく、")
print("  コールバック関数（ここではステータス表示）の呼び出し回数を抑制します。")
print("")
print("────────────────────────────────────────────────────────────────")
print("")
print("# キー操作")
print("")
print("  - d ....... Debounce")
print("              連打後、止めて2秒待つとステータス表示")
print("")
print("  - t ....... Throttle")
print("              連打しても3秒に1回のみステータス表示")
print("")
print("  - b ....... Batch")
print("              5回押すとまとめてステータス表示")
print("")
print("  - r ....... カウンターリセット")
print("")
print("────────────────────────────────────────────────────────────────")
print("")
print("# 効果の見方")
print("")
print("  呼び出し回数 vs 表示回数 を比較してください。")
print("")
print("  例: d を 10回連打 → ステータス表示は 1回だけ")
print("")
print("  :messages で全ログを確認できます。")
print("")
print("────────────────────────────────────────────────────────────────")
