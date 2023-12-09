local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local wally = packages:WaitForChild("wally")
local Knit = require(wally:WaitForChild("Knit"))
local Signal = require(wally:WaitForChild("Signal"))

local PlayerCore = Knit.CreateController { Name = "PlayerCore" }

function PlayerCore:KnitInit()
    
    local function onCharacterAdded(character)
        if not character then
            character = self.player.Character or self.player.CharacterAdded:Wait()
        end

        self.character = character
        self.humanoid = character:WaitForChild("Humanoid")
        self.root = character:WaitForChild("HumanoidRootPart")

        self.character_spawned:Fire()

        self.humanoid.Died:Connect(function()
            -- on death
        end)
    end

    self.character_spawned = Signal.new()
    self.player = game.Players.LocalPlayer

    onCharacterAdded()
    self.player.CharacterAdded:Connect(onCharacterAdded)
end


return PlayerCore