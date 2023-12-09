-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function parseError(err)
	return {
		type = "Error",
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2),
	}
end

return parseError
