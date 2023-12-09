-- # selene: allow(unused_variable)
-- # selene: allow(shadowing)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function updateAll(ancestor)
	local needsUpdateSet = {}
	local processNow = {}
	local processNowSize = 0
	local processNext = {}
	local processNextSize = 0

	for dependent in pairs(ancestor.dependentSet) do
		processNowSize += 1

		processNow[processNowSize] = dependent
	end

	repeat
		local processingDone = true

		for _, member in ipairs(processNow) do
			needsUpdateSet[member] = true

			if (member).dependentSet ~= nil then
				local member = member

				for dependent in pairs(member.dependentSet) do
					processNextSize += 1

					processNext[processNextSize] = dependent
					processingDone = false
				end
			end
		end

		processNow, processNext = processNext, processNow
		processNowSize, processNextSize = processNextSize, 0

		table.clear(processNext)
	until processingDone

	processNowSize = 0

	table.clear(processNow)

	for dependent in pairs(ancestor.dependentSet) do
		processNowSize += 1

		processNow[processNowSize] = dependent
	end

	repeat
		local processingDone = true

		for _, member in ipairs(processNow) do
			needsUpdateSet[member] = nil

			local didChange = member:update()

			if didChange and (member).dependentSet ~= nil then
				local member = member

				for dependent in pairs(member.dependentSet) do
					local allDependenciesUpdated = true

					for dependentDependency in pairs(dependent.dependencySet) do
						if needsUpdateSet[dependentDependency] then
							allDependenciesUpdated = false

							break
						end
					end

					if allDependenciesUpdated then
						processNextSize += 1

						processNext[processNextSize] = dependent
						processingDone = false
					end
				end
			end
		end

		if not processingDone then
			processNow, processNext = processNext, processNow
			processNowSize, processNextSize = processNextSize, 0

			table.clear(processNext)
		end
	until processingDone
end

return updateAll
