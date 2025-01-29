local class = require("class")
local thread = require("thread")
local path_util = require("path_util")
local http_util = require("http_util")
local fs_util = require("fs_util")

---@class gucci.Updater
---@operator call: gucci.Updater
local Updater = class()

function Updater:new()
	self.status = ""
end

---@param url string
---@return love.FileData?
---@return string? error
function Updater:download(url)
	self.isDownloading = true
	local data, code, headers, status_line = fs_util.downloadAsync(url)
	self.isDownloading = false

	if code == 302 then
		data, code, headers, status_line = fs_util.downloadAsync(headers.location)
	end

	if not data then
		return nil, status_line
	end

	local filename = url:match("^.+/(.-)$")
	for header, value in pairs(headers) do
		header = header:lower()
		if header == "content-disposition" then
			local cd = http_util.parse_content_disposition(value)
			filename = cd.filename or filename
		end
	end

	filename = path_util.fix_illegal(filename)
	local filedata = love.filesystem.newFileData(data, filename)
end

Updater.download = thread.coro(Updater.download)

return Updater
