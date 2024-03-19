local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore

local accelerating = {}


function accelerating:init()
    PlayerCore = Knit.GetController("PlayerCore")
    local self = {}

    self.active_speed = 40
    self.inactive_speed = 16

    return setmetatable(self, {__index = accelerating})
end

function accelerating:on_change(to)
    --print("changing speed to '"..tostring(to).."'")
    PlayerCore.humanoid.WalkSpeed = if to == true then self.active_speed else self.inactive_speed
end

return accelerating