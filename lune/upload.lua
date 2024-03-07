local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local task = require("@lune/task")
local serde = require("@lune/serde")

local logger = require("utils/logger")
local execCommand = require("utils/execCommand")

-- uploads all images in .tarmac-debug, and modifies all ids in tarmac manifest to reflect the new urls
if not fs.isDir(".tarmac-debug") then
	logger.Error("No .tarmac-debug directory found: did you run lune/tarmacSync beforehand?")
	return
end

local apiKey = process.args[1]
local uploadType, uploadId = process.args[2], process.args[3]

if not apiKey or not uploadType or not uploadId then
	logger.Error("Missing arguments, expected: upload <api key> <upload type (group or user)> <group or user id>")
	return
end

if #apiKey ~= 48 then
	logger.Error("Invalid API key (expected: 48 characters)")
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

local function getOperationData(operationId: string)
	local function repeatCall()
		return net.request({
			url = `https://apis.roblox.com/assets/v1/operations/{operationId}`,
			headers = {
				["x-api-key"] = apiKey,
			},
			method = "GET",
		})
	end

	local resp = repeatCall()
	local attempts = 0

	while resp.statusCode ~= 200 or not net.jsonDecode(resp.body).done do
		task.wait(5)
		attempts += 1

		if attempts > 15 then -- 15 attempts, for rate limits (which are generally 60 seconds, so we account for a bit more)
			return nil
		end

		resp = repeatCall()
	end

	return net.jsonDecode(resp.body)
end

local function uploadImage(name: string, path: string): string?
	local response = execCommand("rbxcloud", {
		"assets",
		"create",
		"--description",
		" ",
		"--display-name",
		name,
		"--creator-id",
		uploadId,
		"--creator-type",
		uploadType,
		"--api-key",
		apiKey,
		"--filepath",
		path,
		"--asset-type",
		"decal-png",
	}, {
		stdio = "default",
	})

	logger.Info(`Attempting to upload image at {path}: {name}`)

	if response.ok then
		local id = response.stdout:match("operations/([%w%-]+)")

		local operationData = getOperationData(id)

		if operationData == nil then
			logger.Error(`Could not get asset data of {path}, skipping asset.`)
			return
		end

		local moderationResult = operationData.response.moderationResult

		if
			moderationResult
			and moderationResult.moderationState ~= "Approved"
			and moderationResult.moderationState ~= "Reviewing"
		then
			logger.Error(`Asset {path} was not approved.`)
			return
		end

		logger.Success(`Uploaded image successfully: {path}`)

		local decalId = operationData.response.assetId
		local xmlContent = net.request({
			url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. decalId,
			method = "GET",
		})

		if not xmlContent.ok then
			logger.Error("Failed to get image id")
			return
		end

		return xmlContent.body:match("<url>(.-)</url>"):sub(33)
	end

	return ""
end

local manifest = serde.decode("toml", fs.readFile("tarmac-manifest.toml"))
local neededImages = {}

for _, icon in manifest.inputs do
	neededImages[icon.id] = true
end

for image, _ in neededImages do
	if not fs.isFile(`.tarmac-debug/{image}`) then
		continue
	end

	local id = uploadImage(`sheet-{image}`, `.tarmac-debug/{image}`)

	if id then
		for _, icon in manifest.inputs do
			if icon.id == image then
				icon.id = id
			end
		end

		print(image, id)
		local replacedContent = fs.readFile("tarmac-manifest.toml"):gsub(`id = {image}\n`, `id = {id}\n`)
		fs.writeFile("tarmac-manifest.toml", replacedContent)
	end
end
