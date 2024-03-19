local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))

local PlayerCore
local StateController

local jumping = {}

local STATES_TO_EXIT = {
    "grinding"
}

function jumping:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local self = {}

    self.active_speed = 40
    self.inactive_speed = 16

    return setmetatable(self, {__index = jumping})
end

function jumping:on_change(to)
    --print("changing speed to '"..tostring(to).."'")
    local currentState = StateController:GetState()
    --print("is '"..currentState.."' state in STATES_TO_EXIT? "..if to == true and table.find(STATES_TO_EXIT, currentState) then "YES" else "NO")
    if to == true and table.find(STATES_TO_EXIT, currentState) then
        --print("silencing state '"..currentState.."'")
        StateController:SilenceState(currentState)
        StateController:ChangeState("jumping", true)
    end
end

return jumping