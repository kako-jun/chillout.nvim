--- Throttle implementation
--- @module chillout.throttle

--- Creates a throttled function that only invokes `func` at most once per
--- every `wait` milliseconds.
--- @param func function The function to throttle
--- @param wait number The number of milliseconds to throttle
--- @param opts? { leading?: boolean, trailing?: boolean } Options
---   - leading: Execute on the leading edge (default: true)
---   - trailing: Execute on the trailing edge (default: true)
--- @return function throttled_func The throttled function (with .cancel() and .flush() methods)
local function throttle(func, wait, opts)
  vim.validate({
    func = { func, "function" },
    wait = { wait, "number" },
    opts = { opts, "table", true },
  })

  opts = opts or {}
  local leading = opts.leading ~= false -- default true
  local trailing = opts.trailing ~= false -- default true

  local timer = nil
  local last_args = nil
  local pending = false

  local function cleanup()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
  end

  local wrapped = setmetatable({}, {
    __call = function(_, ...)
      last_args = { ... }

      if timer then
        -- Timer is active, mark as pending for trailing
        if trailing then
          pending = true
        end
        return
      end

      -- Execute immediately if leading
      if leading then
        func(unpack(last_args))
      else
        pending = true
      end

      -- Start cooldown timer
      timer = vim.uv.new_timer()
      timer:start(
        wait,
        0,
        vim.schedule_wrap(function()
          cleanup()

          -- If trailing and there were calls during cooldown
          if trailing and pending then
            pending = false
            func(unpack(last_args))
          end
        end)
      )
    end,
  })

  --- Cancel any pending trailing execution.
  function wrapped.cancel()
    cleanup()
    last_args = nil
    pending = false
  end

  --- Execute pending trailing call immediately (if any).
  function wrapped.flush()
    if pending and last_args then
      cleanup()
      pending = false
      local current_args = last_args
      last_args = nil
      func(unpack(current_args))
    end
  end

  return wrapped
end

return throttle
