local Players = game:GetService("Players")
const RunService = game:GetService("RunService")

--[=[
    Runs callbacks for every player, present and future.

    `onPlayerAdded` is called for each player already in the game, then for each
    player that joins.

    `onPlayerRemoving` is called with the player and their `Enum.PlayerExitReason`
    when they leave. On the server, it is also called for each remaining player
    with the `Enum.CloseReason` when the game closes, and shutdown waits for those
    calls to finish.

    Returns a function that stops all future callbacks.
]=]
return function(
    onPlayerAdded: ((player: Player) -> ())?,
    onPlayerRemoving: ((player: Player, reason: Enum.PlayerExitReason | Enum.CloseReason) -> ())?
): () -> ()
    local addedConnection: RBXScriptConnection?
    local disconnected = false
    if onPlayerAdded then
        for _, player in Players:GetPlayers() do
            task.spawn(onPlayerAdded, player)
        end
        addedConnection = Players.PlayerAdded:Connect(onPlayerAdded)
    end
    local removingConnection: RBXScriptConnection?
    if onPlayerRemoving then
        if RunService:IsServer() then
            game:BindToClose(function(closeReason: Enum.CloseReason): ...any
                if disconnected then
                    return
                end

                local threads = {}
                for _, player in Players:GetPlayers() do
                    table.insert(threads, task.spawn(pcall, onPlayerRemoving, player, closeReason))
                end

                for _, thread in threads do
                    while coroutine.status(thread) ~= "dead" do
                        task.wait()
                    end
                end
            end)
        end
        removingConnection = Players.PlayerRemoving:Connect(onPlayerRemoving)
    end

    return function()
        if disconnected then
            return
        end
        disconnected = true
        if addedConnection then
            addedConnection:Disconnect()
        end
        if removingConnection then
            removingConnection:Disconnect()
        end
    end
end
