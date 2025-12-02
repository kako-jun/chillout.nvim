--- Batch implementation
--- @module chillout.batch

--- Creates a batched function that collects all calls within `wait` milliseconds
--- and invokes `func` once with an array of all collected arguments.
--- @param func function The function to batch (receives array of argument arrays)
--- @param wait? number The number of milliseconds to wait before executing (0 or nil = no timer, only maxSize)
--- @param opts? { maxSize?: number } Options
---   - maxSize: Maximum batch size before forced execution (for log sending etc.)
--- @return function batched_func The batched function
local function batch(func, wait, opts)
  opts = opts or {}
  local timer = nil
  local items = {}

  local function flush()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    if #items > 0 then
      local current_batch = items
      items = {}
      func(current_batch)
    end
  end

  return function(...)
    table.insert(items, { ... })

    -- Flush immediately if maxSize reached
    if opts.maxSize and #items >= opts.maxSize then
      flush()
      return
    end

    -- Start/reset timer (only if wait is specified and > 0)
    if wait and wait > 0 and not timer then
      timer = vim.uv.new_timer()
      timer:start(wait, 0, vim.schedule_wrap(flush))
    end
  end
end

return batch
