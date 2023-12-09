-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local Types = require(Package.Types)
local captureDependencies = require(Package.Dependencies.captureDependencies)
local initDependency = require(Package.Dependencies.initDependency)
local useDependency = require(Package.Dependencies.useDependency)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local isSimilar = require(Package.Utility.isSimilar)
local class = {}
local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = {
	__mode = "k",
}

function class:get(asDependency)
	if asDependency ~= false then
		useDependency(self)
	end

	return self._value
end
function class:update()
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

	table.clear(self.dependencySet)

	local ok, newValue = captureDependencies(self.dependencySet, self._callback)

	if ok then
		local oldValue = self._value

		self._value = newValue

		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return not isSimilar(oldValue, newValue)
	else
		logErrorNonFatal("computedCallbackError", newValue)

		self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return false
	end
end

local function Computed(callback)
	local self = setmetatable({
		type = "State",
		kind = "Computed",
		dependencySet = {},
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_callback = callback,
		_value = nil,
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return Computed
