--- chillout.nvim Demo
--- Usage: cd chillout.nvim && nvim -u demo/init.lua

-- Add plugin path (parent directory of this file)
local script_path = debug.getinfo(1, "S").source:sub(2)
local plugin_path = vim.fn.fnamemodify(script_path, ":h:h")
vim.opt.runtimepath:prepend(plugin_path)

local ok, chillout = pcall(require, "chillout")
if not ok then
  print("ERROR: chillout module not found")
  print("plugin_path: " .. plugin_path)
  return
end

-- Counters
local debounce_calls = 0
local debounce_execs = 0
local throttle_calls = 0
local throttle_execs = 0
local batch_calls = 0
local batch_execs = 0

-- 1. Debounce demo
local debounced = chillout.debounce(function()
  debounce_execs = debounce_execs + 1
  print(string.format("[DEBOUNCE] Fired! (calls %d -> fires %d)", debounce_calls, debounce_execs))
end, 2000, { maxWait = 6000 })

vim.keymap.set("n", "d", function()
  debounce_calls = debounce_calls + 1
  print(string.format("[DEBOUNCE] d pressed #%d (waiting 2s...)", debounce_calls))
  debounced()
end, { desc = "Debounce demo" })

-- 2. Throttle demo
local throttled = chillout.throttle(function()
  throttle_execs = throttle_execs + 1
  print(string.format("[THROTTLE] Fired! (calls %d -> fires %d)", throttle_calls, throttle_execs))
end, 3000, { leading = true, trailing = true })

vim.keymap.set("n", "t", function()
  throttle_calls = throttle_calls + 1
  print(string.format("[THROTTLE] t pressed #%d", throttle_calls))
  throttled()
end, { desc = "Throttle demo" })

-- 3. Batch demo
local batched = chillout.batch(function(items)
  batch_execs = batch_execs + 1
  print(string.format("[BATCH] Fired! %d items batched (calls %d -> fires %d)", #items, batch_calls, batch_execs))
end, 999999, { maxSize = 5 })

vim.keymap.set("n", "b", function()
  batch_calls = batch_calls + 1
  print(string.format("[BATCH] b pressed #%d (collecting...)", batch_calls))
  batched(batch_calls)
end, { desc = "Batch demo" })

-- Reset
vim.keymap.set("n", "r", function()
  debounce_calls = 0
  debounce_execs = 0
  throttle_calls = 0
  throttle_execs = 0
  batch_calls = 0
  batch_execs = 0
  print("[RESET] Counters reset")
end, { desc = "Reset counters" })

print("")
print(
  "╔══════════════════════════════════════════════════════════════╗"
)
print("║                      chillout.nvim Demo                      ║")
print(
  "╚══════════════════════════════════════════════════════════════╝"
)
print("")
print("# What does this plugin do?")
print("")
print("  It does NOT delay your keystrokes.")
print("  It limits how often the callback function fires.")
print("")
print(
  "────────────────────────────────────────────────────────────────"
)
print("")
print("# Key bindings")
print("")
print("  - d ....... Debounce")
print("              Press repeatedly, wait 2s after stopping to fire")
print("")
print("  - t ....... Throttle")
print("              Press repeatedly, fires at most once per 3s")
print("")
print("  - b ....... Batch")
print("              Press 5 times to fire with all items at once")
print("")
print("  - r ....... Reset counters")
print("")
print(
  "────────────────────────────────────────────────────────────────"
)
print("")
print("# How to see the effect")
print("")
print("  Compare: calls vs fires")
print("")
print("  Example: press d 10 times -> fires only 1 time")
print("")
print("  Use :messages to see the full log.")
print("")
print(
  "────────────────────────────────────────────────────────────────"
)
