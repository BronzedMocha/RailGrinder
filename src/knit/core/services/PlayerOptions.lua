local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local wally = packages:WaitForChild("wally")

local Knit = require(wally:WaitForChild("Knit"))
local TableUtil = require(wally:WaitForChild("TableUtil"))
local Signal = require(wally:WaitForChild("Signal"))

local game_settings = require(ReplicatedStorage:WaitForChild("Settings"))

local PlayerLog

local PlayerOptions = Knit.CreateService {
    Name = "PlayerOptions";
    Client = {
        options = Knit.CreateProperty(nil);
    };
}

function PlayerOptions:LoadOptions(player, stored_options)
    for i,v in pairs(game_settings.player_options) do
        local option = TableUtil.Copy(v)
        option.value = option.default
        PlayerLog.player_list[player].player_options[i] = option
    end

    for i,v in pairs(stored_options) do
        PlayerLog.player_list[player].player_options[tonumber(i)].value = v
    end

    self.Client.options:SetFor(player, PlayerLog.player_list[player].player_options)
end

function PlayerOptions:SaveOptions(player)
    local stored_options = {}

    for index, option in pairs(PlayerLog.player_list[player].player_options) do
        if option.storable then
            stored_options[index] = option.value
        end
    end
    return stored_options
end

function PlayerOptions.Client:ChangeOption(player, option_id, value)
    if typeof(PlayerLog.player_list[player].player_options[option_id]) == "nil" then
        return
    end

    local option = PlayerLog.player_list[player].player_options[option_id]

    if typeof(option.Value) ~= typeof(value) then
        return
    end

    PlayerLog.player_list[player].player_options[option_id].value = value

    self.options:SetFor(player, PlayerLog.player_list[player].player_options)

    self.Server.option_changed:Fire(player, option.name, option_id)
end

function PlayerOptions:KnitStart()
    
end


function PlayerOptions:KnitInit()
    PlayerLog = Knit.GetService("PlayerLog")
    self.option_changed = Signal.new()
end


return PlayerOptions