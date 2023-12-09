-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local captureDependencies = require(Package.Dependencies.captureDependencies)
local initDependency = require(Package.Dependencies.initDependency)
local useDependency = require(Package.Dependencies.useDependency)
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local cleanup = require(Package.Utility.cleanup)
local class = {}
local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = {
	__mode = "k",
}

local function forKeysCleanup(keyOut, meta)
	cleanup(keyOut)

	if meta then
		cleanup(meta)
	end
end

function class:get(asDependency)
	if asDependency ~= false then
		useDependency(self)
	end

	return self._outputTable
end
function class:update()
	local inputIsState = self._inputIsState
	local oldInputKeys = self._oldInputTable
	local newInputKeys = self._inputTable
	local keyOIMap = self._keyOIMap
	local outputKeys = self._outputTable
	local meta = self._meta

	if inputIsState then
		newInputKeys = newInputKeys:get(false)
	end

	local didChange = false

	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

	table.clear(self.dependencySet)

	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	for newInKey, _value in pairs(newInputKeys) do
		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		local shouldRecalculate = oldInputKeys[newInKey] == nil

		if not shouldRecalculate then
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true

					break
				end
			end
		end
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

			table.clear(keyData.dependencySet)

			local processOK, newOutKey, newMetaValue = captureDependencies(
				keyData.dependencySet,
				self._processor,
				newInKey
			)

			if processOK then
				local oldInKey = keyOIMap[newOutKey]

				if oldInKey ~= newInKey and newInputKeys[oldInKey] ~= nil then
					logError("forKeysKeyCollision", nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
				end

				oldInputKeys[newInKey] = _value
				meta[newOutKey] = newMetaValue
				keyOIMap[newOutKey] = newInKey
				outputKeys[newOutKey] = _value
				didChange = true
			else
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forKeysProcessorError", newOutKey)
			end
		end
	end
	for outputKey, inputKey in pairs(keyOIMap) do
		if newInputKeys[inputKey] == nil then
			local oldMetaValue = meta[outputKey]
			local destructOK, err = xpcall(self._destructor, parseError, outputKey, oldMetaValue)

			if not destructOK then
				logErrorNonFatal("forKeysDestructorError", err)
			end

			oldInputKeys[inputKey] = nil
			meta[outputKey] = nil
			keyOIMap[outputKey] = nil
			outputKeys[outputKey] = nil
			self._keyData[inputKey] = nil
			didChange = true
		end
	end

	return didChange
end

local function ForKeys(inputTable, processor, destructor)
	if destructor == nil then
		destructor = forKeysCleanup
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"
	local self = setmetatable({
		type = "State",
		kind = "ForKeys",
		dependencySet = {},
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,
		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {},
		_keyOIMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForKeys
