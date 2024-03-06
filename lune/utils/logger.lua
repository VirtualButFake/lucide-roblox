local Logger = {}

local stdio = require("@lune/stdio")
local styles = {
    dim = stdio.style("dim"),
    bold = stdio.style("bold"),
    reset = stdio.style("reset"),
    red = stdio.color("red"),
    yellow = stdio.color("yellow"),
    green = stdio.color("green"),
    gray = stdio.style("dim") .. stdio.color("white")
}

function Logger.Info(message: string)
    stdio.write(`{styles.gray}[INFO]{styles.reset} {message}\n`)
end

function Logger.Warn(message: string)
    stdio.write(`{styles.gray}[{styles.reset .. styles.yellow}WARN{styles.gray}]{styles.reset} {message}\n`)
end

function Logger.Error(message: string)
    stdio.write(`{styles.gray}[{styles.reset .. styles.red}ERROR{styles.gray}]{styles.reset} {message}\n`)
end

function Logger.Success(message: string)
    stdio.write(`{styles.gray}[{styles.reset .. styles.green}SUCCESS{styles.gray}]{styles.reset} {message}\n`)
end

return Logger