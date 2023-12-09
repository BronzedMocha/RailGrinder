local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")

local wally = packages:WaitForChild("wally")
local Knit = require(wally:WaitForChild("Knit"))

local game_settings = require(ReplicatedStorage:WaitForChild("Settings"))

local Datastore

local PlayerLog = Knit.CreateService {
    Name = "PlayerLog";
    Client = {
        server_loaded = Knit.CreateProperty(false)
    };
}


function PlayerLog:setup_player(player)

    local function LoadCharacter()
        player:LoadCharacter()
    end

    local function onPlayerDied()
        -- on death
        task.wait(Players.RespawnTime)
        LoadCharacter()
    end

    local function onCharacterAdded(character)
        self.player_list[player].character = character
        self.player_list[player].root = character:WaitForChild("HumanoidRootPart")
        self.player_list[player].humanoid = character:WaitForChild("Humanoid")

        self.player_list[player].humanoid.Died:Connect(onPlayerDied)
    end

    self.player_list[player] = {}

    -- fire methods from other services

    -- connect character added event
    player.CharacterAdded:Connect(onCharacterAdded)

    -- spawn player
    LoadCharacter()

    -- set remote property
    self.Client.server_loaded:SetFor(player, true)
end

function PlayerLog:remove_player(player)
    self.player_list[player] = nil
end

-- knit

function PlayerLog:KnitStart()
    self.player_list = {}

    for _, player in pairs(Players:GetPlayers()) do
        self:setup_player(player)
    end

    Players.PlayerAdded:Connect(function(player)
        self:setup_player(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:remove_player(player)
    end)
end


function PlayerLog:KnitInit()
    
end


return PlayerLog