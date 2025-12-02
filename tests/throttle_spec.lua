local throttle = require("chillout.throttle")

describe("throttle", function()
  it("should execute immediately on first call (leading)", function()
    local call_count = 0
    local throttled = throttle(function()
      call_count = call_count + 1
    end, 100)

    throttled()

    -- Executed immediately
    assert.equals(1, call_count)
  end)

  it("should throttle subsequent calls", function()
    local call_count = 0
    local throttled = throttle(function()
      call_count = call_count + 1
    end, 100)

    throttled()
    throttled()
    throttled()

    -- Only first call executed
    assert.equals(1, call_count)

    -- Wait for cooldown and trailing
    vim.wait(150, function()
      return call_count > 1
    end)

    -- Trailing call executed
    assert.equals(2, call_count)
  end)

  it("should respect leading=false option", function()
    local call_count = 0
    local throttled = throttle(function()
      call_count = call_count + 1
    end, 100, { leading = false })

    throttled()

    -- Not executed immediately
    assert.equals(0, call_count)

    -- Wait for trailing
    vim.wait(150, function()
      return call_count > 0
    end)

    assert.equals(1, call_count)
  end)

  it("should respect trailing=false option", function()
    local call_count = 0
    local throttled = throttle(function()
      call_count = call_count + 1
    end, 100, { trailing = false })

    throttled()
    throttled()
    throttled()

    -- Only leading executed
    assert.equals(1, call_count)

    -- Wait to ensure no trailing
    vim.wait(150, function()
      return false
    end)

    -- Still only 1
    assert.equals(1, call_count)
  end)

  it("should pass arguments to function", function()
    local received_args = nil
    local throttled = throttle(function(a, b)
      received_args = { a, b }
    end, 100)

    throttled("hello", 42)

    assert.equals("hello", received_args[1])
    assert.equals(42, received_args[2])
  end)
end)
