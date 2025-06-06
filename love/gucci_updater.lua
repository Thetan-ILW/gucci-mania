local class = require("class")
local thread = require("thread")
local path_util = require("path_util")
local http_util = require("http_util")
local fs_util = require("fs_util")
local json = require("json")

---@class gucci.Updater
---@operator call: gucci.Updater
local Updater = class()

---@alias gucci.Updater.FileMeta { path: string, hash: string, deleted: boolean }
---@alias gucci.Updater.FileList gucci.Updater.FileMeta[]
Updater.url = "https://64.188.96.80:8080/gucci/build/"
Updater.fileListPath = "file_list.json"
Updater.fileLists = {
	stable = "file_list.json",
}

Updater.branches = {
	"stable",
}

function Updater:new()
	self.status = "Please wait..."
	self.changes = {} ---@type gucci.Updater.FileMeta[]
	self.remoteFileList = {} ---@type gucci.Updater.FileMeta[]
	self.filesToRemove = {}
	self.filesToInstall = {}
	self.checkedThisSession = false
	self.downloadingUpdate = false
	self.restartRequired = false
end

---@param f (fun(state: "downloading" | "restart"))
function Updater:notifyState(f)
	if self.downloadingUpdate then
		f("downloading")
	end
	if self.restartRequired then
		f("restart")
	end
	self.notify = f
end

---@param text string?
function Updater:setStatus(text)
	print("UPDATER: " .. text)
	self.status = text
end

---@param url string
---@return love.FileData?
---@return string? error
function Updater:download(url)
	if self.isDownloading then
		return nil, "Already downloading a file"
	end

	local file_url = self.url .. url
	self.isDownloading = true
	self:setStatus(("Downloading %s"):format(file_url))
	local data, code, headers, status_line = fs_util.downloadAsync(file_url)
	self.isDownloading = false

	for _ = 1, 5 do
		if code == 302 then
			self:setStatus("Redirected")
			print(headers.location)
			data, code, headers, status_line = fs_util.downloadAsync(headers.location)
		else
			break
		end
	end

	if not data then
		status_line = status_line or ("No internet connection / No file: "  .. url)
		print(require("inspect")(headers))
		return nil, status_line
	end

	local filename = url:match("^.+/(.-)$") or url
	for header, value in pairs(headers) do
		header = header:lower()
		if header == "content-disposition" then
			local cd = http_util.parse_content_disposition(value)
			filename = cd.filename or filename
		end
	end

	print(("Filename: %s"):format(filename))
	filename = path_util.fix_illegal(filename)

	local file_data, err = love.filesystem.newFileData(data, filename)

	if not file_data then
		err = err or "File is nil"
		return file_data, err
	end

	return file_data
end

---@param branch string
function Updater:checkForUpdates(branch)
	if os.getenv("DEV") then
		self:setStatus("Dev environment")
		return false
	end
	if self.checkedThisSession then
		self:setStatus("Already checked")
		return
	end

	if not branch or not Updater.fileLists[branch] then
		self:setStatus(("Branch '%s' does not exist"):format(branch))
		return
	end

	self.checkedThisSession = true

	self:setStatus(("Downloading file list: %s"):format(self.fileLists[branch]))
	local remote_json, err = self:download(self.fileLists[branch])

	if not remote_json then
		self:setStatus(err)
		return
	end

	---@type boolean, table | string
	local success, result = pcall(json.decode, remote_json:getString())
	if not success then
		---@cast result string
		self:setStatus(result)
		return
	end

	self.remoteFileList = result -- save raw file list
	---@cast result [string, string]
	---@type gucci.Updater.FileList
	local remote_file_list = {}
	for _, v in ipairs(result) do
		table.insert(remote_file_list, {
			path = v[1],
			hash = v[2],
		})
	end

	self:setStatus("Got remote file list")

	local local_json = love.filesystem.newFileData(self.fileListPath)

	if not local_json then
		self:setStatus("No local file list, downloading everything")
		self.changes = remote_file_list
		success, err = self:downloadChanges()
		if not success then
			self:setStatus(err)
		end
		return
	end

	---@type boolean, table | string
	success, result = pcall(json.decode, local_json:getString())
	if not success then
		---@cast result string
		self:setStatus(result)
		result = {}
	end

	---@cast result [string, string]
	---@type gucci.Updater.FileList
	local local_file_list = {}
	for _, v in ipairs(result) do
		table.insert(local_file_list, {
			path = v[1],
			hash = v[2],
		})
	end
	self:setStatus("Local file list ok")

	self:findChanges(local_file_list, remote_file_list)
	success, err = self:downloadChanges()
	if not success then
		self:setStatus(err)
	end
end

---@param local_fl gucci.Updater.FileList
---@param remote_fl gucci.Updater.FileList
function Updater:findChanges(local_fl, remote_fl)
	local diffs = {} ---@type gucci.Updater.FileList
	local files = {}

	for _, remote_file in ipairs(remote_fl) do
		files[remote_file.path] = true
		local file_found = false
		local changed = false

		for _, local_file in ipairs(local_fl) do
			if remote_file.path == local_file.path then
				file_found = true
				if remote_file.hash ~= local_file.hash then
					changed = true
					self:setStatus(("Will update: %s"):format(remote_file.path))
				end
				break
			end
		end

		if not file_found or changed then
			table.insert(diffs, remote_file)
		end
	end

	for _, local_file in ipairs(local_fl) do
		if not files[local_file.path] then
			local_file.deleted = true
			self:setStatus(("Will remove: %s"):format(local_file.path))
			table.insert(diffs, local_file)
		end
	end

	self:setStatus(("Found %i changed files"):format(#diffs))
	self.changes = diffs
end

---@param filedata love.FileData
local function getHash(filedata)
	return love.data.encode("string", "hex", love.data.hash("md5", filedata))
end

---@param filemeta gucci.Updater.FileMeta
---@return boolean success
---@return string? error
function Updater:downloadUpdatedFile(filemeta)
	local filedata, err = self:download(filemeta.path)
	if not filedata then
		return false, err
	end

	local hash = getHash(filedata)
	if hash ~= filemeta.hash then
		self:setStatus("Corrupted file. ")
		return false, ("Corrupted file: FileMetaFileName: %s; DownloadedFilename: %s; FileMetaHash: %s; DownloadedHash: %s"):format(
			filemeta.path,
			filedata:getFilename(),
			filemeta.hash,
			hash
		)
	end

	table.insert(self.filesToInstall, { path = filemeta.path, filedata = filedata })
	return true
end

---@return boolean success
---@return string? error
function Updater:downloadChanges()
	if #self.changes == 0 then
		self:setStatus(("Nothing to update. Version: %s"):format(self:getVersion()))
		return true
	end

	if self.notify then
		self.notify("downloading")
	end
	self.downloadingUpdate = true

	for _, filemeta in ipairs(self.changes) do
		local success, err
		if filemeta.deleted then
			self:setStatus(("Removing %s"):format(filemeta.path))
			table.insert(self.filesToRemove, filemeta.path)
		else
			success, err = self:downloadUpdatedFile(filemeta)
		end

		if not success then
			return false, err
		end
	end

	local data = love.filesystem.newFileData(json.encode(self.remoteFileList), self.fileListPath)
	love.filesystem.write(self.fileListPath, data)

	if self.notify then
		self.notify("restart")
	end
	self.restartRequired = true
	self:setStatus("File list updated")
	self:setStatus("Updates installed. Restart required.")

	return true
end

function Updater:applyUpdate()
	if not self.restartRequired then
		return
	end

	print("Applying a new update")
	for i, v in ipairs(self.filesToInstall) do
		print(("Replacing file: %s"):format(v.path))
		local success, err = love.filesystem.write(v.path, v.filedata)
		if not success then
			print(("Failed to replace a file: %s"):format(v.path))
			love.filesystem.remove("file_list.json")
			return
		end
	end

	for i, v in ipairs(self.filesToRemove) do
		print(("Removing file: %s"):format(v))
		love.filesystem.remove(v)
	end
end

function Updater:getVersion()
	local str = ""
	for _, v in ipairs(self.remoteFileList) do
		str = str .. v[2]
	end
	return love.data.encode("string", "hex", love.data.hash("md5", str)):sub(1, 6)
end

Updater.checkForUpdates = thread.coro(Updater.checkForUpdates)

return Updater
