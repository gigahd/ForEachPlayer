# ForEachPlayer
Run callbacks for every player, present and future.

## Installation
Add it to your `wally.toml`:

```toml
[dependencies]
ForEachPlayer = "giga/foreachplayer@0.1.0"
```

## Usage
```luau
local ForEachPlayer = require(path.to.ForEachPlayer)

local disconnect = ForEachPlayer(function(player)
    print(`{player.Name} is in the game`)
end, function(player, reason)
    print(`{player.Name} left: {reason}`)
end)

-- Stop all future callbacks
disconnect()
```

Both callbacks are optional. `onPlayerAdded` also runs for players already in the game.

On the server, `onPlayerRemoving` also runs for each remaining player when the game closes, with an `Enum.CloseReason` instead of an `Enum.PlayerExitReason`. Shutdown waits for those calls to finish.
