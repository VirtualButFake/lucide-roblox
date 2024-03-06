local lucideRoblox = {}

local icons = require("icons")
local iconIndex: { string } = icons[1]
local idIndex: { number } = icons[2]
local iconRegistry: { [number]: { number | { number } } } = icons[3]

lucideRoblox.icons = iconIndex

function lucideRoblox.GetAsset(name: string, size: number?): icon?
	if not size then
		size = 48
	end

	local iconIndex = table.find(iconIndex, name)

	if not iconIndex then
		return
	end

	local currentDistance = math.huge
	for registrySize, icons in iconRegistry do
		local diff = math.abs(size - registrySize)

		if diff < currentDistance then
			currentDistance = diff
		else
			local icon = icons[iconIndex]

			return {
				name = name,
				id = idIndex[icon[1]],
				url = "rbxassetid://" .. idIndex[icon[1]],
				imageRectSize = Vector2.new(icon[2][1], icon[2][1]),
				imageRectOffset = Vector2.new(icon[3][1], icons[3][1]),
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
