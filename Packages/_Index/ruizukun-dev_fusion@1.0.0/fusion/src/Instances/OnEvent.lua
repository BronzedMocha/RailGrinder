-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function getProperty_unsafe(instance, property)
	return (instance)[property]
end
local function OnEvent(eventName)
	local eventKey = {}

	eventKey.type = "SpecialKey"
	eventKey.kind = "OnEvent"
	eventKey.stage = "observer"

	function eventKey:apply(callback, applyToRef, cleanupTasks)
		local instance = applyToRef.instance
		local ok, event = pcall(getProperty_unsafe, instance, eventName)

		if not ok or typeof(event) ~= "RBXScriptSignal" then
			logError("cannotConnectEvent", nil, instance.ClassName, eventName)
		elseif typeof(callback) ~= "function" then
			logError("invalidEventHandler", nil, eventName)
		else
			table.insert(cleanupTasks, event:Connect(callback))
		end
	end

	return eventKey
end

return OnEvent
