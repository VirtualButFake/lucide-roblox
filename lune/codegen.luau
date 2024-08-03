local input = "icons/processed"
local output = "src/icons.luau"

local serde = require("@lune/serde")
local fs = require("@lune/fs")

local luaEncode = require("libs/LuaEncode")
local manifest = serde.decode("toml", fs.readFile("tarmac-manifest.toml"))

local iconData: {
	[number]: {
		[number]: { number | { number } },
	},
} = {}

local iconIndex: { string } = {}
local idIndex: { number } = {}

for name: string, data: {
	hash: string,
	slice: { { number } },
	packable: boolean,
	id: number,
} in manifest.inputs do
	local split = name:split("/")
	local iconName = split[#split]:gsub(".png", "")

	if not table.find(iconIndex, iconName) then
		table.insert(iconIndex, iconName)
	end

	if not table.find(idIndex, data.id) then
		table.insert(idIndex, data.id)
	end

	local sizing = tonumber(name:gsub(input, ""):split("/")[2]:match("%d+")) -- test string was icons/processed/16x/iconname.png

	if not iconData[sizing] then
		iconData[sizing] = {}
	end

	-- from lucide-roblox https://github.com/latte-soft/lucide-roblox/blob/7a3085de0b0ffe200940113986fa3c3db186f06e/lune/tarmac-sync.luau#L57
	local ImageRectOffset = data.slice[1]
	local ImageRectOffsetBounds = data.slice[2]

	local OffsetX, OffsetY = ImageRectOffset[1], ImageRectOffset[2]

	local SizeX = ImageRectOffsetBounds[1] - OffsetX
	local SizeY = ImageRectOffsetBounds[2] - OffsetY

	table.insert(iconData[sizing], {
		name = iconName,
		data.id,
		{ SizeX, SizeY },
		{ OffsetX, OffsetY },
	})
end

table.sort(iconIndex, function(a, b)
	return a < b
end)

table.sort(idIndex, function(a, b)
	return a < b
end)

for size, icons in pairs(iconData) do
	table.sort(icons, function(a, b)
		local aName, bName = a.name, b.name
		return aName < bName
	end)

	for _, icon in icons do
		icon.name = nil
		icon[1] = table.find(idIndex, icon[1])
	end
end

local fileContent = luaEncode({
	iconIndex,
	idIndex,
	iconData,
})

fs.writeFile(output, `return {fileContent}`)
