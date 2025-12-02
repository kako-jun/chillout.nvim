--- chillout.nvim - Debounce, throttle, and batch for Neovim Lua
--- @module chillout

local M = {}

M.debounce = require("chillout.debounce")
M.throttle = require("chillout.throttle")
M.batch = require("chillout.batch")

return M
