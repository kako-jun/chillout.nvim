# chillout.nvim

[![Tests](https://github.com/kako-jun/chillout.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/kako-jun/chillout.nvim/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[日本語](README.ja.md)

Debounce, throttle, and batch for Neovim Lua.

![demo](https://github.com/kako-jun/chillout.nvim/raw/main/assets/demo.gif)

## Requirements

- Neovim >= 0.10

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

## Real World Examples

### Search suggestions (debounce + maxWait)

```lua
-- Show suggestions after typing stops, but don't wait forever
local suggest = chillout.debounce(show_suggestions, 300, { maxWait = 2000 })
```

### Auto-save (debounce)

```lua
-- Save after editing stops
local auto_save = chillout.debounce(function()
  vim.cmd("silent! write")
end, 1000)
```

### Scroll tracking UI (throttle + leading)

```lua
-- Update minimap immediately on scroll, then throttle
local update_minimap = chillout.throttle(render_minimap, 100, { leading = true })
```

### Window resize handler (throttle + trailing only)

```lua
-- Recalculate layout only after resize completes
local on_resize = chillout.throttle(recalc_layout, 200, { leading = false, trailing = true })
```

### Log sending (batch + maxSize)

```lua
-- Send logs in batches of 100 or every 5 seconds
local send_log = chillout.batch(send_to_server, 5000, { maxSize = 100 })
```

### Event aggregation (batch)

```lua
-- Collect file change events and process together
local on_change = chillout.batch(process_changes, 200)
```

## Why chillout.nvim?

- **No existing solution** - Neovim lacks a dedicated debounce/throttle/batch library
- **Neovim native** - Uses `vim.uv` (libuv), no external dependencies
- **Feature complete** - Includes options like `maxWait`, `leading/trailing`, `maxSize`
- **Lightweight** - ~150 lines of code total

## License

[MIT](LICENSE)
