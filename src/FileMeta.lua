local IFileMeta = require("src.IFileMeta")
local env = require("env")

---@class FileMeta : IFileMeta
---@operator call: IFileMeta
local FileMeta = IFileMeta + {}

---@param filepath string
---@param url string
function FileMeta:new(filepath, url)
	self.filepath = filepath
	self.url = url
	assert(self.filepath and self.url)
end

---@return boolean success
---@return string? error
function FileMeta:validate()
	print(("Skipping validation: %s"):format(self.filepath))
	return true
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
