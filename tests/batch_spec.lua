local batch = require("chillout.batch")

describe("batch", function()
  it("should collect calls and execute once", function()
    local received_batch = nil
    local batched = batch(function(items)
      received_batch = items
    end, 50)

    batched("a")
    batched("b")
    batched("c")

    -- Not executed yet
    assert.is_nil(received_batch)

    -- Wait for batch
    vim.wait(100, function()
      return received_batch ~= nil
    end)

    -- All items collected
    assert.equals(3, #received_batch)
    assert.equals("a", received_batch[1][1])
    assert.equals("b", received_batch[2][1])
    assert.equals("c", received_batch[3][1])
  end)

  it("should respect maxSize option", function()
    local call_count = 0
    local batched = batch(function()
      call_count = call_count + 1
    end, 10000, { maxSize = 3 })

    batched("a")
    batched("b")

    -- Not executed yet
    assert.equals(0, call_count)

    batched("c")

    -- Executed immediately on maxSize
    assert.equals(1, call_count)
  end)

  it("should handle multiple batches", function()
    local batches = {}
    local batched = batch(function(items)
      table.insert(batches, items)
    end, 50, { maxSize = 2 })

    batched("a")
    batched("b") -- triggers first batch

    assert.equals(1, #batches)
    assert.equals(2, #batches[1])

    batched("c")
    batched("d")  -- triggers second batch

    assert.equals(2, #batches)
    assert.equals(2, #batches[2])
  end)

  it("should pass multiple arguments", function()
    local received_batch = nil
    local batched = batch(function(items)
      received_batch = items
    end, 50)

    batched("key1", "value1")
    batched("key2", "value2")

    vim.wait(100, function()
      return received_batch ~= nil
    end)

    assert.equals("key1", received_batch[1][1])
    assert.equals("value1", received_batch[1][2])
    assert.equals("key2", received_batch[2][1])
    assert.equals("value2", received_batch[2][2])
  end)
end)
