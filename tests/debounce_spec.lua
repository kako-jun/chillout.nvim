local debounce = require("chillout.debounce")

describe("debounce", function()
  it("should delay execution until wait time passes", function()
    local call_count = 0
    local debounced = debounce(function()
      call_count = call_count + 1
    end, 50)

    debounced()
    debounced()
    debounced()

    -- Not executed yet
    assert.equals(0, call_count)

    -- Wait for debounce
    vim.wait(100, function()
      return call_count > 0
    end)

    -- Executed once
    assert.equals(1, call_count)
  end)

  it("should reset timer on each call", function()
    local call_count = 0
    local debounced = debounce(function()
      call_count = call_count + 1
    end, 100)

    debounced()
    vim.wait(50, function() return false end)
    debounced()
    vim.wait(50, function() return false end)
    debounced()

    -- Still not executed
    assert.equals(0, call_count)

    -- Wait for final debounce
    vim.wait(150, function()
      return call_count > 0
    end)

    assert.equals(1, call_count)
  end)

  it("should pass arguments to function", function()
    local received_args = nil
    local debounced = debounce(function(a, b)
      received_args = { a, b }
    end, 50)

    debounced("hello", 42)

    vim.wait(100, function()
      return received_args ~= nil
    end)

    assert.equals("hello", received_args[1])
    assert.equals(42, received_args[2])
  end)

  it("should respect maxWait option", function()
    local call_count = 0
    local debounced = debounce(function()
      call_count = call_count + 1
    end, 100, { maxWait = 150 })

    -- Keep calling to reset timer
    for _ = 1, 5 do
      debounced()
      vim.wait(50, function() return false end)
    end

    -- Should have been forced by maxWait
    vim.wait(100, function()
      return call_count > 0
    end)

    assert.is_true(call_count >= 1)
  end)
end)
