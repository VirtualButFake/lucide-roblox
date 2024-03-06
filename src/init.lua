local lucideRoblox = {}

local icons = require("./icons")
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
				IconName = name,
				Id = idIndices[icon[1]],
				Url = "rbxassetid://" .. idIndices[icon[1]],
				ImageRectSize = Vector2.new(icon[2][1], icon[2][1]),
				ImageRectOffset = Vector2.new(icon[3][1], icon[3][2]),
			}
		end
	end

	return
end

type icon = {
	IconName: string, -- "icon-name"
	Id: number, -- 123456789
	Url: string, -- "rbxassetid://123456789"
	ImageRectSize: Vector2, -- Vector2.new(48, 48)
	ImageRectOffset: Vector2, -- Vector2.new(648, 266)
}

return lucideRoblox
