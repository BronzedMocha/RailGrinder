local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))
local DebugVisualize = require(shared_folder.modules.DebugVisualize)

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore
local StateController

local function checkForRail(character: BasePart): RaycastResult?
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    local target_cf = character.HumanoidRootPart.CFrame

    local raycast_result = workspace:Blockcast(target_cf, character.HumanoidRootPart.Size, -(character.HumanoidRootPart.CFrame.UpVector * character.Humanoid.HipHeight), params)
    --DebugVisualize.block((target_cf - CFrame.new(character.HumanoidRootPart.CFrame.UpVector * character.Humanoid.HipHeight)), character.HumanoidRootPart.Size)

    if raycast_result and raycast_result.Instance and raycast_result.Instance:GetAttribute("RailId") then
        print("raycast found!")
        return raycast_result
    end
end

local freefall = {}

function freefall:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")
    local self = {}
    self.character_core = core

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = freefall})
end

function freefall:update(dt)
    -- raycast to check for rail
    self.landing_result = checkForRail(PlayerCore.character)

    print("CHECKING FOR RAIL")

    -- if rail is found, enter into grinding state with transfer data
    if self.landing_result then
        print("found rail, shifting to grinding state")
        StateController:ChangeState("grinding")
    end
end

function freefall:on_start(transfer_data)
    print("started freefall!")
end

function freefall:on_end()
    return self.landing_result
end

function freefall:destroy()

end

return freefall