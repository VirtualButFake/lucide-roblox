-- The sizes to export
local sizes = { 12, 16, 24, 48, 64 }
local inputFolder = "icons/svg/"
local outputFolder = "icons/processed/"

local fs = require("@lune/fs")
local task = require("@lune/task")
local process = require("@lune/process")

local logger = require("utils/logger")
local execCommand = require("utils/execCommand")

local maxBatchSize = 20 -- set to math.huge for max speed

if maxBatchSize <= 3 then
	logger.Warn(
		`Max batch size is set to {maxBatchSize}; increase it in order to increase processing speed at the cost of more CPU usage!`
	)
	task.wait(1)
end

local batchCount = 0
local currentFiles = {}

local function convertFile(input, output, size)
	if batchCount >= maxBatchSize then
		while batchCount >= maxBatchSize do
			task.wait(0.1)

			for i = #currentFiles, 1, -1 do
				if fs.isFile(currentFiles[i]) then
					table.remove(currentFiles, i)
					batchCount -= 1
				end
			end
		end
	end

	batchCount += 1
	table.insert(currentFiles, output)

	execCommand(process.os == "windows" and "./lune/scripts/convert.bat" or "./lune/scripts/convert.sh", { size, input, output }, {
		stdio = "none",
	})
end

if not execCommand("inkscape", { "--version" }, {
	stdio = "none",
}, function()
	return
end).ok then
	logger.Error("Inkscape is not installed: install Inkscape and add it to your PATH to use this script!")
	return
end

if not execCommand("magick", { "--version" }, {
	stdio = "none",
}, function()
	return
end).ok then
	logger.Error("ImageMagick is not installed: install ImageMagick to use this script!")
	return
end

if not fs.isDir(outputFolder) then
	fs.writeDir(outputFolder)
end

for _, size in sizes do
	local totalAmount = #fs.readDir(inputFolder)
	local currentAmount = 0
	local start = os.clock()

	if not fs.isDir(`{outputFolder}{size}px`) then
		fs.writeDir(`{outputFolder}{size}px`)
	end

	for _, icon in fs.readDir(inputFolder) do
		local iconName = icon:match("([^/]+)$"):match("(.+)%..+")
		local outputPath = `{outputFolder}{size}px/{iconName}.png`

		if fs.isFile(outputPath) then
			currentAmount += 1
			continue
		end

		convertFile(icon, outputPath, size)

		currentAmount += 1
		logger.Success(`Processed icon {icon} at size {size}px ({currentAmount}/{totalAmount})`)
	end

	logger.Success(`Finished processing all icons at size {size}px in {os.clock() - start}s!`)
end
