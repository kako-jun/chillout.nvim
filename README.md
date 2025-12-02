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

### `chillout.debounce(func, wait)`

Creates a debounced function that delays invoking `func` until after `wait` milliseconds have elapsed since the last call.

### `chillout.throttle(func, wait)`

Creates a throttled function that invokes `func` at most once per `wait` milliseconds. Uses trailing edge execution.

### `chillout.batch(func, wait)`

Creates a batched function that collects all calls within `wait` milliseconds and invokes `func` once with an array of all collected arguments.

## License

MIT
