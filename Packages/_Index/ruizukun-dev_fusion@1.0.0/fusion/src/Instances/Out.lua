-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function Out(propertyName)
	local outKey = {}

	outKey.type = "SpecialKey"
	outKey.kind = "Out"
	outKey.stage = "observer"

	function outKey:apply(outState, applyToRef, cleanupTasks)
		local ok, event = pcall(applyToRef.instance.GetPropertyChangedSignal, applyToRef.instance, propertyName)

		if not ok then
			logError("invalidOutProperty", nil, applyToRef.instance.ClassName, propertyName)
		elseif xtypeof(outState) ~= "State" or outState.kind ~= "Value" then
			logError("invalidOutType")
		else
			outState:set((applyToRef.instance)[propertyName])
			table.insert(
				cleanupTasks,
				event:Connect(function()
					if applyToRef.instance ~= nil then
						outState:set((applyToRef.instance)[propertyName])
					end
				end)
			)
			table.insert(cleanupTasks, function()
				outState:set(nil)
			end)
		end
	end

	return outKey
end

return Out
