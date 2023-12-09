-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local onDestroy = require(Package.Instances.onDestroy)
local cleanup = require(Package.Utility.cleanup)
local xtypeof = require(Package.Utility.xtypeof)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local Observer = require(Package.State.Observer)

local function setProperty_unsafe(instance, property, value)
	(instance)[property] = value
end
local function testPropertyAssignable(instance, property)
	(instance)[property] = (instance)[property]
end
local function setProperty(instance, property, value)
	if not pcall(setProperty_unsafe, instance, property, value) then
		if not pcall(testPropertyAssignable, instance, property) then
			if instance == nil then
				logError("setPropertyNilRef", nil, property, tostring(value))
			else
				logError("cannotAssignProperty", nil, instance.ClassName, property)
			end
		else
			local givenType = typeof(value)
			local expectedType = typeof((instance)[property])

			logError("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
		end
	end
end
local function bindProperty(instanceRef, property, value, cleanupTasks)
	if xtypeof(value) == "State" then
		local willUpdate = false

		local function updateLater()
			if not willUpdate then
				willUpdate = true

				task.defer(function()
					willUpdate = false

					setProperty(instanceRef.instance, property, value:get(false))
				end)
			end
		end

		setProperty(instanceRef.instance, property, value:get(false))
		table.insert(cleanupTasks, Observer(value):onChange(updateLater))
	else
		setProperty(instanceRef.instance, property, value)
	end
end
local function applyInstanceProps(props, applyToRef)
	if applyToRef.instance == nil then
		return logWarn("applyPropsNilRef")
	end

	local specialKeys = {
		self = {},
		descendants = {},
		ancestor = {},
		observer = {},
	}
	local cleanupTasks = {}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(applyToRef, key, value, cleanupTasks)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key).stage
			local keys = specialKeys[stage]

			if keys == nil then
				logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			logError("unrecognisedPropertyKey", nil, xtypeof(key))
		end
	end
	for key, value in pairs(specialKeys.self) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(value, applyToRef, cleanupTasks)
	end

	if props.Parent ~= nil then
		bindProperty(applyToRef, "Parent", props.Parent, cleanupTasks)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(value, applyToRef, cleanupTasks)
	end

	onDestroy(applyToRef, cleanup, cleanupTasks)
end

return applyInstanceProps
