--- Throttle implementation
--- @module chillout.throttle

--- Creates a throttled function that only invokes `func` at most once per
--- every `wait` milliseconds.
--- @param func function The function to throttle
--- @param wait number The number of milliseconds to throttle
--- @param opts? { leading?: boolean, trailing?: boolean } Options
---   - leading: Execute on the leading edge (default: true)
---   - trailing: Execute on the trailing edge (default: true)
--- @return function throttled_func The throttled function
local function throttle(func, wait, opts)
  opts = opts or {}
  local leading = opts.leading ~= false -- default true
  local trailing = opts.trailing ~= false -- default true

  local timer = nil
  local last_args = nil
  local pending = false

  return function(...)
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
        timer:stop()
        timer:close()
        timer = nil

        -- If trailing and there were calls during cooldown
        if trailing and pending then
          pending = false
          func(unpack(last_args))
        end
      end)
    )
  end
end

return throttle
