local dataModels = {}

for _, descendant in ipairs({ game, script, plugin }) do
	local root = descendant

	while root.Parent ~= nil do
		root = root.Parent
	end

	dataModels[root] = true
end

local function isAccessible(target)
	for root in pairs(dataModels) do
		if root:IsAncestorOf(target) then
			return true
		end
	end

	return false
end

return isAccessible
