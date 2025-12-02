-- 最小テスト
-- 実行: cd /home/d131/repos/2025/chillout.nvim && nvim -u demo/test.lua

-- パス設定
local script_path = debug.getinfo(1, "S").source:sub(2)
local plugin_path = vim.fn.fnamemodify(script_path, ":h:h")
vim.opt.runtimepath:prepend(plugin_path)

print("plugin_path: " .. plugin_path)

-- モジュール読み込み
local ok, chillout = pcall(require, "chillout")
if not ok then
  print("ERROR: " .. tostring(chillout))
  return
end

print("chillout loaded successfully")
print("debounce: " .. type(chillout.debounce))
print("throttle: " .. type(chillout.throttle))
print("batch: " .. type(chillout.batch))

-- 簡単なテスト
local count = 0
local debounced = chillout.debounce(function()
  count = count + 1
  print("FIRED! count=" .. count)
end, 1000)

-- キーマップでテスト
vim.keymap.set("n", "<Space>", function()
  print("Space pressed, calling debounced...")
  debounced()
end, { desc = "Test debounce" })

print("")
print("=== テスト方法 ===")
print("Spaceキーを連打してください")
print("1秒待つと FIRED! が表示されます")
print("==================")
