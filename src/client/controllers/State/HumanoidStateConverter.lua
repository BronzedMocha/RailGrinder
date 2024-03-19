local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local HumanoidStateConverter = Knit.CreateController { Name = "HumanoidStateConverter" }
local PlayerCore
local StateController

local BLACKLISTED_STATES = {
    "grinding",
}

function HumanoidStateConverter:KnitStart()
    PlayerCore = Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local function OnCharacterSpawned()
        print("character spawned")

        -- disable dead state
        StateController:ChangeState("idle")

        -- bind to humanoidStates
        PlayerCore.humanoid.StateChanged:Connect(function(old: EnumItem, new: EnumItem)

            if table.find(BLACKLISTED_STATES, new) then return end

            if new == Enum.HumanoidStateType.Jumping then
                print("MAKING YEW JUMP HEHE")
                StateController:ChangeState("jumping")
            elseif new == Enum.HumanoidStateType.Running and PlayerCore.humanoid.MoveDirection.magnitude <= 0.05 and StateController.client_data.current_state ~= "grinding" then
                StateController:ChangeState("idle")
            elseif new == Enum.HumanoidStateType.Freefall then
                if StateController.client_data.current_state ~= "jumping" then
                    StateController:ChangeState("freefall")
                end
            elseif new == Enum.HumanoidStateType.Landed then
                StateController:ChangeState("landing")
            elseif new == Enum.HumanoidStateType.Dead then
                StateController:ChangeState("dead")
            end
        end)

        -- bind to humanoid properties
        PlayerCore.humanoid.Changed:Connect(function(property)
            if property == "MoveDirection" then
                if PlayerCore.humanoid.MoveDirection.magnitude <= 0.05 then
                    -- you're idle
                    StateController:ChangeState("idle")
                elseif PlayerCore.humanoid.FloorMaterial ~= Enum.Material.Air then
                    -- you're walking
                    StateController:ChangeState("walking")
                end
            end
        end)
    end

    OnCharacterSpawned()
    PlayerCore.character_spawned:Connect(OnCharacterSpawned)
end


return HumanoidStateConverter