local class = require("class")
local env = require("env")
local files = require("src.files")

---@class GitPackages
---@operator call: GitPackages
---@field pkgs GitPackage[]
local GitPackages = class()

---@param pkgs GitPackage[]
function GitPackages:new(pkgs)
	self.pkgs = pkgs
end

---@return boolean success
---@return string? error
function GitPackages:downloadAll()
	for _, pkg in ipairs(self.pkgs) do
		local success, err  = self:download(pkg)
		if not success then
			return false, err
		end
	end

	return true
end

---@return boolean success
---@return string? error
function GitPackages:updateAll()
	for _, pkg in ipairs(self.pkgs) do
		local success, err  = self:update(pkg)
		if not success then
			return false, err
		end
	end

	return true
end

---@param pkg GitPackage
---@return boolean success
---@return string? error
function GitPackages:update(pkg)
	local path = pkg.path

	if not love.filesystem.getInfo(path) then
		return false, ("ERROR: No package in '%s', can't update"):format(pkg.id)
	end

	print(("INFO: Updating package: %s"):format(pkg.id))
	local process, err = io.popen(("cd %s;git fetch;git pull"):format(path), "r")
	if not process then
		return false, err
	end
	print(process:read("*l"))
	process:close()

	return true
end

---@param pkg GitPackage
---@return boolean success
---@return string? error
function GitPackages:download(pkg)
	local path = pkg.path

	if love.filesystem.getInfo(path) then
		if path == "" or path == "/" or path == "\\" then
			return false, "EPIC SAVE!"
		end
		os.execute(("rm -rf %s"):format(path))
	end
	print(("INFO: Downloading package: %s"):format(pkg.id))
	local process, err = io.popen(("git clone %s %s"):format(pkg.url, path), "r")
	if not process then
		return false, err
	end
	print(process:read("*l"))
	process:close()

	if not love.filesystem.getInfo(path) then
		return false, ("Failed to download package %s"):format(path)
	end

	return true
end

return GitPackages
