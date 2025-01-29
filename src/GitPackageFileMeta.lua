local IFileMeta = require("src.IFileMeta")

---@class GitPackageFileMeta : IFileMeta
---@operator call: IFileMeta
local GitPackageFileMeta = IFileMeta + {}

---@param pkg GitPackage
---@param branch string
---@param url string
function GitPackageFileMeta:new(pkg, branch, url)
	assert(pkg and branch and url)
	self.pkg = pkg
	self.branch = branch
	self.url = url
end

---@return boolean success
---@return string? error
function GitPackageFileMeta:validate()
	local process, err = io.popen(("cd %s;git rev-parse --abbrev-ref HEAD"):format(self.pkg.path, "r"))
	if not process then
		return false, "ERROR: Failed to check git branch. " .. err
	end
	local output = process:read("*l")
	if self.branch ~= output then
		return false, ("ERROR: Plugin %s is not on the %s branch. Currently on: '%s'"):format(self.pkg.id, self.branch, output)
	end

	return true
end

---@return boolean
---@return string? filename
function GitPackageFileMeta:ensureExists()
	if not love.filesystem.getInfo(self.pkg.path) then
		return false, self.pkg.path
	end
	return true
end

---@return string
function GitPackageFileMeta:getFileName()
	return self.pkg.id .. ".zip"
end

return GitPackageFileMeta
