local input = "icons/processed"
local output = "src/icons.lua"

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

	table.insert(iconData[sizing], {
		name = iconName,
		data.id,
		data.slice[1],
		data.slice[2],
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
