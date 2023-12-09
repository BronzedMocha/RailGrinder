local function isSimilar(a, b)
	if typeof(a) == "table" then
		return false
	else
		return a == b
	end
end

return isSimilar
