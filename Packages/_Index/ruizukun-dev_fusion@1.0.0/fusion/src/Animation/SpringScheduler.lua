-- # selene: allow(unused_variable)

local RunService = game:GetService("RunService")
local Package = script.Parent.Parent
local Types = require(Package.Types)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.Dependencies.updateAll)
local SpringScheduler = {}
local EPSILON = 0.0001
local activeSprings = {}
local lastUpdateTime = os.clock()

function SpringScheduler.add(spring)
	spring._lastSchedule = lastUpdateTime
	spring._startDisplacements = {}
	spring._startVelocities = {}

	for index, goal in ipairs(spring._springGoals) do
		spring._startDisplacements[index] = spring._springPositions[index] - goal
		spring._startVelocities[index] = spring._springVelocities[index]
	end

	activeSprings[spring] = true
end
function SpringScheduler.remove(spring)
	activeSprings[spring] = nil
end

local function updateAllSprings()
	local springsToSleep = {}

	lastUpdateTime = os.clock()

	for spring in pairs(activeSprings) do
		local posPos, posVel, velPos, velVel = springCoefficients(
			lastUpdateTime - spring._lastSchedule,
			spring._currentDamping,
			spring._currentSpeed
		)
		local positions = spring._springPositions
		local velocities = spring._springVelocities
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local isMoving = false

		for index, goal in ipairs(spring._springGoals) do
			local oldDisplacement = startDisplacements[index]
			local oldVelocity = startVelocities[index]
			local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
			local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

			if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
				isMoving = true
			end

			positions[index] = newDisplacement + goal
			velocities[index] = newVelocity
		end

		if not isMoving then
			springsToSleep[spring] = true
		end
	end
	for spring in pairs(activeSprings) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)

		updateAll(spring)
	end
	for spring in pairs(springsToSleep) do
		activeSprings[spring] = nil
	end
end

RunService:BindToRenderStep("__FusionSpringScheduler", Enum.RenderPriority.First.Value, updateAllSprings)

return SpringScheduler
