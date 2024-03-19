local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local InputStateBind = Knit.CreateController { Name = "InputStateBind" }
InputStateBind.bindings = {}

local StateController

InputStateBind.bindings["accelerate"] = function(state, input)
    if state == Enum.UserInputState.Begin then
        StateController:UpdateMacro("accelerating", true)
    elseif state == Enum.UserInputState.End then
        StateController:UpdateMacro("accelerating", false)
    end
end

InputStateBind.bindings["crouch"] = function(state, input)
    if state == Enum.UserInputState.Begin then
        StateController:UpdateMacro("crouching", true)
    elseif state == Enum.UserInputState.End then
        StateController:UpdateMacro("crouching", false)
    end
end

InputStateBind.bindings["jump"] = function(state, input)
    if state == Enum.UserInputState.Begin then
        StateController:UpdateMacro("jumping", true)
    elseif state == Enum.UserInputState.End then
        StateController:UpdateMacro("jumping", false)
    end
end

function InputStateBind:InputRegistered(name, state, input)
    if not InputStateBind.bindings[name] then
        --warn("["..script.Name..":InputRegistered] Cannot locate binding for '"..name.."'")
        return
    end
    InputStateBind.bindings[name](state, input)
end


function InputStateBind:KnitStart()
    
end


function InputStateBind:KnitInit()
    StateController = Knit.GetController("StateController")
end


return InputStateBind