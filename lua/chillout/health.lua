--- Health check for chillout.nvim
--- @module chillout.health

local M = {}

function M.check()
  vim.health.start("chillout.nvim")

  -- Check Neovim version
  if vim.fn.has("nvim-0.10") == 1 then
    vim.health.ok("Neovim >= 0.10")
  else
    vim.health.error("Neovim >= 0.10 is required", { "Update Neovim to 0.10 or later" })
  end

  -- Check vim.uv availability
  if vim.uv and vim.uv.new_timer then
    vim.health.ok("vim.uv.new_timer is available")
  else
    vim.health.error("vim.uv.new_timer is not available", { "Neovim >= 0.10 provides vim.uv" })
  end

  -- Check module loads correctly
  local ok, chillout = pcall(require, "chillout")
  if ok then
    vim.health.ok("require('chillout') loaded successfully")
  else
    vim.health.error("Failed to load chillout module", { tostring(chillout) })
    return
  end

  -- Check core functions exist
  local functions = { "debounce", "throttle", "batch", "setup" }
  for _, name in ipairs(functions) do
    if type(chillout[name]) == "function" then
      vim.health.ok(string.format("chillout.%s() is available", name))
    else
      vim.health.warn(string.format("chillout.%s() is missing", name))
    end
  end
end

return M
