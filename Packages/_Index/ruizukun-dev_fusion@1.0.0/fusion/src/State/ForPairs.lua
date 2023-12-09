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

local function forPairsCleanup(keyOut, valueOut, meta)
	cleanup(keyOut)
	cleanup(valueOut)

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
	local oldInputPairs = self._oldInputTable
	local newInputPairs = self._inputTable
	local keyIOMap = self._keyIOMap
	local meta = self._meta

	if inputIsState then
		newInputPairs = newInputPairs:get(false)
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

	self._oldOutputTable, self._outputTable = self._outputTable, self._oldOutputTable

	local oldOutputPairs = self._oldOutputTable
	local newOutputPairs = self._outputTable

	table.clear(newOutputPairs)

	for newInKey, newInValue in pairs(newInputPairs) do
		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		local shouldRecalculate = oldInputPairs[newInKey] ~= newInValue

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

			local processOK, newOutKey, newOutValue, newMetaValue = captureDependencies(
				keyData.dependencySet,
				self._processor,
				newInKey,
				newInValue
			)

			if processOK then
				local oldOutValue = oldOutputPairs[newOutKey]

				if oldOutValue ~= newOutValue then
					didChange = true

					if oldOutValue ~= nil then
						local oldMetaValue = meta[newOutKey]
						local destructOK, err = xpcall(
							self._destructor,
							parseError,
							newOutKey,
							oldOutValue,
							oldMetaValue
						)

						if not destructOK then
							logErrorNonFatal("forPairsDestructorError", err)
						end
					end
				end
				if newOutputPairs[newOutKey] ~= nil then
					local previousNewKey, previousNewValue

					for inKey, outKey in pairs(keyIOMap) do
						if outKey == newOutKey then
							previousNewValue = newInputPairs[inKey]

							if previousNewValue ~= nil then
								previousNewKey = inKey

								break
							end
						end
					end

					if previousNewKey ~= nil then
						logError(
							"forPairsKeyCollision",
							nil,
							tostring(newOutKey),
							tostring(previousNewKey),
							tostring(previousNewValue),
							tostring(newInKey),
							tostring(newInValue)
						)
					end
				end

				oldInputPairs[newInKey] = newInValue
				keyIOMap[newInKey] = newOutKey
				meta[newOutKey] = newMetaValue
				oldOutputPairs[newOutKey] = newOutValue
				newOutputPairs[newOutKey] = newOutValue
			else
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forPairsProcessorError", newOutKey)
			end
		else
			local newOutKey = keyIOMap[newInKey]

			if newOutputPairs[newOutKey] ~= nil then
				local previousNewKey, previousNewValue

				for inKey, outKey in pairs(keyIOMap) do
					if newOutKey == outKey then
						previousNewValue = newInputPairs[inKey]

						if previousNewValue ~= nil then
							previousNewKey = inKey

							break
						end
					end
				end

				if previousNewKey ~= nil then
					logError(
						"forPairsKeyCollision",
						nil,
						tostring(newOutKey),
						tostring(previousNewKey),
						tostring(previousNewValue),
						tostring(newInKey),
						tostring(newInValue)
					)
				end
			end

			newOutputPairs[newOutKey] = oldOutputPairs[newOutKey]
		end
	end
	for key in pairs(oldOutputPairs) do
		if newOutputPairs[key] == nil then
			local oldOutValue = oldOutputPairs[key]
			local oldMetaValue = meta[key]

			if oldOutValue ~= nil then
				local destructOK, err = xpcall(self._destructor, parseError, key, oldOutValue, oldMetaValue)

				if not destructOK then
					logErrorNonFatal("forPairsDestructorError", err)
				end
			end

			meta[key] = nil
			self._keyData[key] = nil
			didChange = true
		end
	end
	for key in pairs(oldInputPairs) do
		if newInputPairs[key] == nil then
			oldInputPairs[key] = nil
			keyIOMap[key] = nil
		end
	end

	return didChange
end

local function ForPairs(inputTable, processor, destructor)
	if destructor == nil then
		destructor = forPairsCleanup
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"
	local self = setmetatable({
		type = "State",
		kind = "ForPairs",
		dependencySet = {},
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,
		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {},
		_oldOutputTable = {},
		_keyIOMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForPairs
