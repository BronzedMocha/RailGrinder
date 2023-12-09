-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local sharedState = require(Package.Dependencies.sharedState)
local initialisedStack = sharedState.initialisedStack

local function useDependency(dependency)
	local dependencySet = sharedState.dependencySet

	if dependencySet ~= nil then
		local initialisedStackSize = sharedState.initialisedStackSize

		if initialisedStackSize > 0 then
			local initialisedSet = initialisedStack[initialisedStackSize]

			if initialisedSet[dependency] ~= nil then
				return
			end
		end

		dependencySet[dependency] = true
	end
end

return useDependency
