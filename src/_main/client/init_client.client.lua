local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage:WaitForChild("Packages")
local wally = packages:WaitForChild("wally")
local Knit = require(wally:WaitForChild("Knit"))

Knit.AddControllersDeep(script.Parent.controllers)

Knit.Start():andThen(function()
	print("Knit started")
end):catch(function(err)
    -- Handle error
    warn(tostring(err))
end)