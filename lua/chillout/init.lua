--- chillout.nvim - Debounce, throttle, and batch for Neovim Lua
--- @module chillout

local M = {}

M.debounce = require("chillout.debounce")
M.throttle = require("chillout.throttle")
M.batch = require("chillout.batch")

--- Optional setup function for plugin manager compatibility (e.g. lazy.nvim config=true).
--- @param opts? table Reserved for future options
function M.setup(opts)
  -- Currently no configuration needed.
  -- This function exists so lazy.nvim config=true works without error.
end

return M
