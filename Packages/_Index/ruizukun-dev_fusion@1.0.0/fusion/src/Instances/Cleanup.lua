-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Cleanup = {}

Cleanup.type = "SpecialKey"
Cleanup.kind = "Cleanup"
Cleanup.stage = "observer"

function Cleanup:apply(userTask, applyToRef, cleanupTasks)
	table.insert(cleanupTasks, userTask)
end

return Cleanup
