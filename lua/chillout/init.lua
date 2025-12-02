--- chillout.nvim - Debounce, throttle, and batch for Neovim Lua
--- @module chillout

local M = {}

--- Creates a debounced function that delays invoking `func` until after `wait`
--- milliseconds have elapsed since the last time it was invoked.
--- @param func function The function to debounce
--- @param wait number The number of milliseconds to delay
--- @return function debounced_func The debounced function
function M.debounce(func, wait)
  local timer = nil

  return function(...)
    local args = { ... }

    if timer then
      timer:stop()
      timer:close()
    end

    timer = vim.uv.new_timer()
    timer:start(wait, 0, vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      timer = nil
      func(unpack(args))
    end))
  end
end

--- Creates a throttled function that only invokes `func` at most once per
--- every `wait` milliseconds. Uses trailing edge execution.
--- @param func function The function to throttle
--- @param wait number The number of milliseconds to throttle
--- @return function throttled_func The throttled function
function M.throttle(func, wait)
  local timer = nil
  local last_args = nil
  local pending = false

  return function(...)
    last_args = { ... }

    if timer then
      -- Timer is active, mark as pending
      pending = true
      return
    end

    -- Execute immediately
    func(unpack(last_args))

    -- Start cooldown timer
    timer = vim.uv.new_timer()
    timer:start(wait, 0, vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      timer = nil

      -- If there were calls during cooldown, execute with last args
      if pending then
        pending = false
        func(unpack(last_args))
      end
    end))
  end
end

--- Creates a batched function that collects all calls within `wait` milliseconds
--- and invokes `func` once with an array of all collected arguments.
--- @param func function The function to batch (receives array of argument arrays)
--- @param wait number The number of milliseconds to wait before executing
--- @return function batched_func The batched function
function M.batch(func, wait)
  local timer = nil
  local batch = {}

  return function(...)
    table.insert(batch, { ... })

    if timer then
      return
    end

    timer = vim.uv.new_timer()
    timer:start(wait, 0, vim.schedule_wrap(function()
      timer:stop()
      timer:close()
      timer = nil

      local current_batch = batch
      batch = {}
      func(current_batch)
    end))
  end
end

return M
