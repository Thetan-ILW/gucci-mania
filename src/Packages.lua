local class = require("class")
local env = require("env")
local files = require("src.files")

---@class Packages
---@operator call: Packages
local Packages = class()

function Packages:new()
	if not love.filesystem.getInfo(env.filesDirectory .. "/userdata") then
		files.mkdir(env.filesDirectory .. "/userdata")
	end
	if not love.filesystem.getInfo(env.filesDirectory .. "/userdata/pkg") then
		files.mkdir(env.filesDirectory .. "/userdata/pkg")
	end
end

---@param filemeta FileMeta
---@param path string?
---@return boolean success
---@return string? error
function Packages:downloadFile(filemeta, path)
	path = path or ("%s/%s"):format(env.filesDirectory, filemeta.filepath)
	local process, err = io.popen(("curl --output %s %s"):format(path, filemeta.url))

	if not process then
		return false, err
	end

	print(process:read("*l"))
	process:close()

	if not love.filesystem.getInfo(path) then
		return false, ("ERROR: Failed to download %s"):format(filemeta.filepath)
	end

	return true
end

---@param filemetas FileMeta[]
---@return boolean success
---@return string? error
function Packages:downloadAll(filemetas)
	for _, filemeta in ipairs(filemetas) do
		if filemeta.isPackage then
			local success, err = self:downloadFile(filemeta)
			if not success then
				return false, err
			end
		end
	end

	return true
end

return Packages
