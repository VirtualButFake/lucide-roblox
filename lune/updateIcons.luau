local net = require("@lune/net")
local serde = require("@lune/serde")
local fs = require("@lune/fs")
local task = require("@lune/task")

local logger = require("utils/logger")

local gitTree = net.request({
	url = "https://api.github.com/repos/lucide-icons/lucide/git/trees/main?recursive=1",
	method = "GET",
})

if gitTree.ok then
	local body = serde.decode("json", gitTree.body)

	-- find icons folder
	local icons = {}

	for _, item in ipairs(body.tree) do
		if item.path:sub(1, 6) == "icons/" then
			local iconName = item.path:sub(7)
			local fileExtension = iconName:match("^.+%.(.+)$")

			if fileExtension == "svg" and not fs.isFile(`icons/svg/{iconName}`) then
				table.insert(icons, iconName)
			end
		end
	end

	if #icons > 0 then
		logger.Info(`Downloading {#icons} icons from GitHub..`)
		local progress = 0

		for _, icon in icons do
			task.spawn(function()
				local iconContent = net.request({
					url = `https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/{icon}`,
					method = "GET",
				})

				if iconContent.ok then
					fs.writeFile(`icons/svg/{icon}`, iconContent.body)
					progress += 1
					logger.Info(`Downloaded icon: {icon} ({progress}/{#icons})`)

                    if progress == #icons then
                        logger.Success("All icons have been downloaded!")
                    end
				else
					logger.Error(`Could not fetch icon: {icon}`)
				end
			end)

			task.wait(0.01)
		end
	else
		logger.Success("Icon set is already up to date!")
	end
else
	logger.Error("Could not fetch Lucide icons from GitHub")
end
