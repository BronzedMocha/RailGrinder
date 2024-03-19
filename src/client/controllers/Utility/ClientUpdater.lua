local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local DebugVisualize = require(shared_folder.modules.DebugVisualize)

local ClientUpdater = Knit.CreateController { Name = "ClientUpdater" }

local InputListener
local IrisProfiler

function ClientUpdater:KnitStart()
    self.events = {}
    self.events.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
        -- Input
        InputListener:TrackPlayerMovement(deltaTime)

        -- State

        -- Benchmarker
        IrisProfiler:BindMovementVectorToMenu()

        -- Debug
        DebugVisualize.step()

    end)
end


function ClientUpdater:KnitInit()
    InputListener = Knit.GetController("InputListener")
    IrisProfiler = Knit.GetController("IrisProfiler")
end


return ClientUpdater