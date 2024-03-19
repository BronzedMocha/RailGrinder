local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared_folder = ReplicatedStorage:WaitForChild("Shared")

local tests = shared_folder:WaitForChild("tests")
local packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(packages:WaitForChild("Knit"))
local Promise = require(packages:WaitForChild("Promise"))

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
	-- marking knit controllers as loaded
    packages.Knit:SetAttribute("LoadedServices", true)
	print("Knit started")
end):catch(warn)

-- initializing testez for server
local TestEZ = require(packages:WaitForChild("TestEZ"))
TestEZ.TestBootstrap:run(tests.server:GetChildren())