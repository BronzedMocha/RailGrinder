local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = shared_folder:WaitForChild("types")

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore
local StateController

local idle = {}

function idle:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local self = {}

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = idle})
end

function idle:update(dt)

    -- Transition Checks

    if PlayerCore.humanoid.FloorMaterial == Enum.Material.Air then
        StateController:ChangeState("freefall")
    end
    
    if PlayerCore.humanoid.MoveDirection.magnitude >= 0.01 then
        StateController:ChangeState("walking")
    end

    
end

function idle:on_start(transfer_data)
    
end

function idle:on_end()
    
end

function idle:destroy()
    
end

return idle