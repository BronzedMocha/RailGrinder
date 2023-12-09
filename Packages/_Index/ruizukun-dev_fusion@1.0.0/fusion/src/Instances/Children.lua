-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)
local Observer = require(Package.State.Observer)
local xtypeof = require(Package.Utility.xtypeof)
local EXPERIMENTAL_AUTO_NAMING = false
local Children = {}

Children.type = "SpecialKey"
Children.kind = "Children"
Children.stage = "descendants"

function Children:apply(propValue, applyToRef, cleanupTasks)
	local newParented = {}
	local oldParented = {}
	local newDisconnects = {}
	local oldDisconnects = {}
	local updateQueued = false
	local queueUpdate

	local function updateChildren()
		updateQueued = false
		oldParented, newParented = newParented, oldParented
		oldDisconnects, newDisconnects = newDisconnects, oldDisconnects

		table.clear(newParented)
		table.clear(newDisconnects)

		local function processChild(child, autoName)
			local kind = xtypeof(child)

			if kind == "Instance" then
				newParented[child] = true

				if oldParented[child] == nil then
					child.Parent = applyToRef.instance
				else
					oldParented[child] = nil
				end
				if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
					child.Name = autoName
				end
			elseif kind == "State" then
				local value = child:get(false)

				if value ~= nil then
					processChild(value, autoName)
				end

				local disconnect = oldDisconnects[child]

				if disconnect == nil then
					disconnect = Observer(child):onChange(queueUpdate)
				else
					oldDisconnects[child] = nil
				end

				newDisconnects[child] = disconnect
			elseif kind == "table" then
				for key, subChild in pairs(child) do
					local keyType = typeof(key)
					local subAutoName = nil

					if keyType == "string" then
						subAutoName = key
					elseif keyType == "number" and autoName ~= nil then
						subAutoName = autoName .. "_" .. key
					end

					processChild(subChild, subAutoName)
				end
			else
				logWarn("unrecognisedChildType", kind)
			end
		end

		if propValue ~= nil then
			processChild(propValue)
		end

		for oldInstance in pairs(oldParented) do
			oldInstance.Parent = nil
		end
		for oldState, disconnect in pairs(oldDisconnects) do
			disconnect()
		end
	end

	queueUpdate = function()
		if not updateQueued then
			updateQueued = true

			task.defer(updateChildren)
		end
	end

	table.insert(cleanupTasks, function()
		propValue = nil

		updateChildren()
	end)
	updateChildren()
end

return Children
