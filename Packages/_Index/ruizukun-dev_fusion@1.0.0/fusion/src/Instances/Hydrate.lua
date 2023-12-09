-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(target)
	return function(props)
		applyInstanceProps(props, semiWeakRef(target))

		return target
	end
end

return Hydrate
