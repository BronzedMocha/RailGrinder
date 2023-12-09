-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local Types = require(Package.Types)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)
local updateAll = require(Package.Dependencies.updateAll)
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
function class:set(newValue, force)
	local similar = isSimilar(self._value, newValue)

	self._value = newValue

	if not similar or force then
		updateAll(self)
	end
end

local function Value(initialValue)
	local self = setmetatable({
		type = "State",
		kind = "Value",
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_value = initialValue,
	}, CLASS_METATABLE)

	initDependency(self)

	return self
end

return Value
