local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = shared_folder:WaitForChild("types")

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore
local StateController

local walking = {}

function walking:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local self = {}

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = walking})
end

function walking:update(dt)
    if PlayerCore.humanoid.FloorMaterial == Enum.Material.Air then
        StateController:ChangeState("freefall")
    end

    if PlayerCore.humanoid.MoveDirection.magnitude < 0.01 then
        StateController:ChangeState("idle")
    end
end

function walking:on_start(transfer_data)

end

function walking:on_end()

end

function walking:destroy()

end

return walking