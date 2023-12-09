-- # selene: allow(unused_variable)

local Package = script.Parent.Parent
local Types = require(Package.Types)
local messages = require(Package.Logging.messages)

local function logError(messageID, errObj, ...)
	local formatString

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString

	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format(
			"[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace,
			...
		)
	end

	error(errorString:gsub("\n", "\n    "), 0)
end

return logError
