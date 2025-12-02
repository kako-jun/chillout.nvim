--- Debounce implementation
--- @module chillout.debounce

--- Creates a debounced function that delays invoking `func` until after `wait`
--- milliseconds have elapsed since the last time it was invoked.
--- @param func function The function to debounce
--- @param wait number The number of milliseconds to delay
--- @param opts? { maxWait?: number } Options
---   - maxWait: Maximum time to wait before forced execution (for search suggestions etc.)
--- @return function debounced_func The debounced function
local function debounce(func, wait, opts)
  opts = opts or {}
  local timer = nil
  local max_timer = nil
  local args = nil

  local function cleanup()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    if max_timer then
      max_timer:stop()
      max_timer:close()
      max_timer = nil
    end
  end

  local function execute()
    cleanup()
    if args then
      local current_args = args
      args = nil
      func(unpack(current_args))
    end
  end

  return function(...)
    args = { ... }

    -- Reset wait timer
    if timer then
      timer:stop()
      timer:close()
    end
    timer = vim.uv.new_timer()
    timer:start(wait, 0, vim.schedule_wrap(execute))

    -- Start maxWait timer (only once per burst)
    if opts.maxWait and not max_timer then
      max_timer = vim.uv.new_timer()
      max_timer:start(opts.maxWait, 0, vim.schedule_wrap(execute))
    end
  end
end

return debounce
