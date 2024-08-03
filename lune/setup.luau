local process = require("@lune/process")

local execCommand = require("utils/execCommand")
local logger = require("utils/logger")

local function executeLuneScript(scriptPath: string, args: { string }?): string?
	local result = execCommand("lune", { "run", `lune/{scriptPath}`, table.unpack(args or {}) })

	if not result.ok then
		logger.Error("Failed to execute Lune script: " .. result.stderr)
		return nil
	end

	return result.stdout
end

local apiKey = process.args[1]
local uploadType, uploadId = process.args[2], process.args[3]

if not apiKey or not uploadType or not uploadId then
	logger.Error("Missing arguments, expected: upload <api key> <upload type (group or user)> <group or user id>")
	return
end

if uploadType ~= "group" and uploadType ~= "user" then
	logger.Error("Invalid upload type (expected: group or user)")
	return
end

if tonumber(uploadId) == nil then
	logger.Error("Invalid user/group id (expected: integer)")
	return
end

executeLuneScript("updateIcons")
executeLuneScript("processIcons")
executeLuneScript("tarmacSync")
executeLuneScript("upload", { apiKey, uploadType, uploadId })
executeLuneScript("codegen")
executeLuneScript("generate-md-index")
