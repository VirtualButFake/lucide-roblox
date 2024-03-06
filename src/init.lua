local lucideRoblox = {}

local icons = require("icons")
local iconIndices: { string } = icons[1]
local idIndices: { number } = icons[2]
local iconRegistry: { [number]: { number | { number } } } = icons[3]

lucideRoblox.icons = iconIndices

function lucideRoblox.GetAsset(name: string, size: number?): icon?
	if not size then
		size = 48
	end

	local iconIndex = table.find(iconIndices, name)

	if not iconIndex then
		return
	end

	local currentDistance = math.huge
	for registrySize, iconList in iconRegistry do
		local diff = math.abs(size - registrySize)

		if diff < currentDistance then
			currentDistance = diff
		else
			local icon = iconList[iconIndex]

			return {
				name = name,
				id = idIndices[icon[1]],
				url = "rbxassetid://" .. idIndices[icon[1]],
				imageRectSize = Vector2.new(icon[2][1], icon[2][1]),
				imageRectOffset = Vector2.new(icon[3][1], icon[3][2]),
			}
		end
	end

	return
end

type icon = {
	name: string,
	id: string,
	url: string,
	imageRectSize: Vector2,
	imageRectOffset: Vector2,
}

return lucideRoblox
