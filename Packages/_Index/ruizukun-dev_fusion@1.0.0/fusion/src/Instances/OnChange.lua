-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function OnChange(propertyName)
	local changeKey = {}

	changeKey.type = "SpecialKey"
	changeKey.kind = "OnChange"
	changeKey.stage = "observer"

	function changeKey:apply(callback, applyToRef, cleanupTasks)
		local instance = applyToRef.instance
		local ok, event = pcall(instance.GetPropertyChangedSignal, instance, propertyName)

		if not ok then
			logError("cannotConnectChange", nil, instance.ClassName, propertyName)
		elseif typeof(callback) ~= "function" then
			logError("invalidChangeHandler", nil, propertyName)
		else
			table.insert(
				cleanupTasks,
				event:Connect(function()
					if applyToRef.instance ~= nil then
						callback((applyToRef.instance)[propertyName])
					end
				end)
			)
		end
	end

	return changeKey
end

return OnChange
