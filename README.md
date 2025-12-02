# chillout.nvim

Debounce, throttle, and batch for Neovim Lua.

## Installation

### lazy.nvim

```lua
{
  "kako-jun/chillout.nvim",
}
```

### packer.nvim

```lua
use "kako-jun/chillout.nvim"
```

## Usage

```lua
local chillout = require("chillout")

-- Debounce: Wait until calls stop, then execute
local debounced = chillout.debounce(function(text)
  print("Input finished: " .. text)
end, 300)

-- Throttle: Execute at most once per interval
local throttled = chillout.throttle(function()
  print("Updating...")
end, 500)

-- Batch: Collect calls and process together
local batched = chillout.batch(function(items)
  print("Processing " .. #items .. " items")
end, 200)
```

## API

### `chillout.debounce(func, wait, opts?)`

Creates a debounced function that delays invoking `func` until after `wait` milliseconds have elapsed since the last call.

**Options:**
- `maxWait` (number): Maximum time to wait before forced execution

```lua
-- Search suggestions: show after typing stops, but max 3 seconds
local search = chillout.debounce(run_search, 500, { maxWait = 3000 })

-- Auto-save: wait until editing stops
local save = chillout.debounce(save_file, 1000)
```

### `chillout.throttle(func, wait, opts?)`

Creates a throttled function that invokes `func` at most once per `wait` milliseconds.

**Options:**
- `leading` (boolean): Execute on leading edge (default: true)
- `trailing` (boolean): Execute on trailing edge (default: true)

```lua
-- Scroll tracking: update immediately, then throttle
local scroll = chillout.throttle(update_minimap, 100, { leading = true })

-- Resize: only after resize completes
local resize = chillout.throttle(recalc_layout, 200, { leading = false, trailing = true })
```

### `chillout.batch(func, wait, opts?)`

Creates a batched function that collects all calls within `wait` milliseconds and invokes `func` once with an array of all collected arguments.

**Options:**
- `maxSize` (number): Maximum batch size before forced execution

```lua
-- Log sending: send every 5 seconds or when 100 logs accumulated
local log = chillout.batch(send_logs, 5000, { maxSize = 100 })

-- Event aggregation: collect for 200ms
local events = chillout.batch(process_events, 200)
```

## Use Cases

| Use Case | Function | Options |
|----------|----------|---------|
| Search suggestions | debounce | `{ maxWait = 3000 }` |
| Auto-save | debounce | (none) |
| Scroll tracking UI | throttle | `{ leading = true }` |
| Resize complete | throttle | `{ leading = false }` |
| Log sending | batch | `{ maxSize = 100 }` |
| Event aggregation | batch | (none) |

## License

MIT
