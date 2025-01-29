local class = require("class")
local env = require("env")

---@class FileMeta
---@operator call: FileMeta
local FileMeta = class()

---@param filepath string
---@param url string
---@param is_package boolean?
function FileMeta:new(filepath, url, is_package)
	self.filepath = filepath
	self.url = url
	self.isPackage = is_package
	assert(self.filepath and self.url)
end

---@return boolean exists
---@return string? filename
function FileMeta:ensureExists()
	local path = env.filesDirectory .. "/" .. self.filepath
	if not love.filesystem.getInfo(path) then
		return false, path
	end
	return true
end

---@return string
function FileMeta:getFileName()
	return self.filepath
end

return FileMeta
