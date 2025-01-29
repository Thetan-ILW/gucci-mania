local class = require("class")

---@class IFileMeta
---@operator call: IFileMeta
---@field url string
local IFileMeta = class()

---@return boolean success
---@return string? error
function IFileMeta:validate() return false, "Not implemented" end

---@return boolean
---@return string filename?
function IFileMeta:ensureExists() return false, "" end

---@return string
function IFileMeta:getFileName() return "Not implemented" end

return IFileMeta
