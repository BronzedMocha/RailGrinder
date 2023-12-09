-- # selene: allow(unused_variable)

local RunService = game:GetService("RunService")
local Package = script.Parent.Parent
local Types = require(Package.Types)
local lerpType = require(Package.Animation.lerpType)
local getTweenRatio = require(Package.Animation.getTweenRatio)
local updateAll = require(Package.Dependencies.updateAll)
local TweenScheduler = {}
local WEAK_KEYS_METATABLE = {
	__mode = "k",
}
local allTweens = {}

setmetatable(allTweens, WEAK_KEYS_METATABLE)

function TweenScheduler.add(tween)
	allTweens[tween] = true
end
function TweenScheduler.remove(tween)
	allTweens[tween] = nil
end

local function updateAllTweens()
	local now = os.clock()

	for tween in pairs(allTweens) do
		local currentTime = now - tween._currentTweenStartTime

		if currentTime > tween._currentTweenDuration then
			if tween._currentTweenInfo.Reverses then
				tween._currentValue = tween._prevValue
			else
				tween._currentValue = tween._nextValue
			end

			tween._currentlyAnimating = false

			updateAll(tween)
			TweenScheduler.remove(tween)
		else
			local ratio = getTweenRatio(tween._currentTweenInfo, currentTime)
			local currentValue = lerpType(tween._prevValue, tween._nextValue, ratio)

			tween._currentValue = currentValue
			tween._currentlyAnimating = true

			updateAll(tween)
		end
	end
end

RunService:BindToRenderStep("__FusionTweenScheduler", Enum.RenderPriority.First.Value, updateAllTweens)

return TweenScheduler
