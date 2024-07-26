local execCommand = require("utils/execCommand")
local logger = require("utils/logger")
execCommand("tarmac", {"sync", "--target", "debug"})
logger.Info("Successfully re-synced Tarmac")