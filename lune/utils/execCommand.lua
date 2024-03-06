local process = require("@lune/process")

return function(command: string, args: { string }?, config: process.SpawnOptions?, errorCallback: (string) -> ()?): process.SpawnResult
	local result = process.spawn(command, args or {}, config or {
		stdio = "inherit",
	})

	if not result.ok then
		if errorCallback then
			errorCallback(`Command failed with status code {result.code}`)
		else
			error(`Command failed with status code {result.code}`)
		end
	end

	return result
end
