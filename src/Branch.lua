local class = require("class")
local env = require("env")

local json = require("json")
local files = require("src.files")

---@alias FileMetadata { path: string, url: string, git?: { branch: string, directory: string } }

---@class gucci.Branch
---@operator call: gucci.Branch
local Branch = class()

Branch.buildDirectory = "build"

---@param name string
---@param filemetas IFileMeta[]
function Branch:new(name, filemetas)
	self.fileMetas = filemetas
	self.path = ("updates/%s"):format(name)
	self.fileListPath = ("updates/%s/file_list.json"):format(name)
end

---@param filemeta GitPackageFileMeta
---@return boolean success
---@return string? error 
function Branch:switchGitBranch(filemeta)
	local process, err = io.popen(("cd %s;git checkout %s"):format(filemeta.pkg.path, filemeta.branch), "r")
	if not process then
		return false, err
	end
	print(process:read("*l"))
	return true
end

---@return boolean success
---@return string? error 
function Branch:build()
	if not love.filesystem.getInfo(env.filesDirectory .. "/" .. "game.love") then
		return false, "ERROR: game.love is not patched"
	end

	for _, filemeta in ipairs(self.fileMetas) do
		local exists, err_filename = filemeta:ensureExists()
		if not exists then
			return false, ("ERROR: Missing plugin: %s"):format(err_filename)
		end

		if filemeta.pkg then
			---@cast filemeta GitPackageFileMeta
			self:switchGitBranch(filemeta)
		end

		local success, err = filemeta:validate()
		if not success then
			return false, err
		end
	end

	print("INFO: Files validated")

	if love.filesystem.getInfo("build") then
		os.execute("rm -rf build")
	end

	files.mkdir("build")
	files.copyDir("soundsphere/bin", "build")

	local git_dir = env.gitDirectory
	files.copyFile(git_dir .. "/MinaCalc/minacalc/bin/linux64/libminacalc.so", "build/bin/linux64/libminacalc.so")
	files.copyFile(git_dir .. "/MinaCalc/minacalc/bin/win64/libminacalc.dll", "build/bin/win64/libminacalc.dll")
	files.copyFile("soundsphere/conf.lua", "build/conf.lua")
	files.copyFile("gucci!mania.exe", "build")
	files.copyFile("soundsphere/game-appimage", "build")
	files.copyFile("soundsphere/game-linux", "build")
	files.copyFile("soundsphere/game-win64.bat", "build")
	files.copyFile("soundsphere/game-win64.bat", "build")
	files.copyFile("files/game.love", "build/game.love")

	files.mkdir("build/userdata")
	files.mkdir("build/userdata/pkg")

	for _, filemeta in ipairs(self.fileMetas) do
		if filemeta.pkg then
			---@cast filemeta GitPackageFileMeta
			files.createArchive(filemeta.pkg.path, ("build/userdata/pkg/%s.zip"):format(filemeta.pkg.id))
		end
	end

	self:createFileList()

	return true
end

---@param filepath string
local function getHash(filepath)
	local filedata = love.filesystem.newFileData(filepath)
	return love.data.encode("string", "hex", love.data.hash("md5", filedata))
end

---@return boolean success
---@return string? error
function Branch:createFileList()
	local file_list = {}

	for _, filemeta in ipairs(self.fileMetas) do
		if filemeta.pkg then
			local filepath = "userdata/pkg/" .. filemeta:getFileName()
			table.insert(file_list, {
				path = filepath,
				hash = getHash("build/" .. filepath),
				url = filemeta.url
			})
		else
			local filepath = filemeta:getFileName()
			table.insert(file_list, {
				path = filepath,
				hash = getHash("build/" .. filepath),
				url = filemeta.url
			})
		end
	end

	local file, err = io.open(("%s/file_list.json"):format(self.path), "w")
	if not file then
		return false, err
	end

	file:write(json.encode(file_list))
	file:close()

	return true
end

return Branch
