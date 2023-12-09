local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage:WaitForChild("Packages")
local wally = packages:WaitForChild("wally")
local Knit = require(wally:WaitForChild("Knit"))
local Promise = require(wally:WaitForChild("Promise"))

function Knit.OnComponentsLoaded()
	if Knit.ComponentsLoaded then
		return Promise.Resolve()
	end
	return Promise.new(function(resolve, _reject, onCancel)
		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if Knit.ComponentsLoaded then
				heartbeat:Disconnect()
				resolve()
			end
		end)
		onCancel(function()
			if heartbeat then
				heartbeat:Disconnect()
			end
		end)
	end)
end

Knit.AddServicesDeep(script.Parent.services)

Knit.Start():andThen(function()
	print("Knit started")
end):catch(warn)