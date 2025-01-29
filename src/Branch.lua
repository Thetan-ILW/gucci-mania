local class = require("class")
local env = require("env")

local json = require("json")
local files = require("src.files")

---@class gucci.Branch
---@operator call: gucci.Branch
local Branch = class()

Branch.buildDirectory = "build"

---@param name string
---@param filemetas FileMeta[]
function Branch:new(name, filemetas)
	self.fileMetas = filemetas
	self.path = ("updates/%s"):format(name)
	self.fileListPath = ("updates/%s/file_list.json"):format(name)
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
	end

	if love.filesystem.getInfo("build") then
		os.execute("rm -rf build")
	end

	files.mkdir("build")
	files.copyDir("soundsphere/bin", "build")
	os.execute("unzip -p files/userdata/pkg/MinaCalc.zip MinaCalc-soundsphere-main/minacalc/bin/win64/libminacalc.dll >build/bin/win64/libminacalc.dll")
	os.execute("unzip -p files/userdata/pkg/MinaCalc.zip MinaCalc-soundsphere-main/minacalc/bin/linux64/libminacalc.so >build/bin/linux64/libminacalc.so")

	files.copyFile("soundsphere/conf.lua", "build/conf.lua")
	files.copyFile("gucci!mania.exe", "build")
	files.copyFile("soundsphere/game-appimage", "build")
	files.copyFile("soundsphere/game-linux", "build")
	files.copyFile("soundsphere/game-win64.bat", "build")
	files.copyFile("soundsphere/game-win64.bat", "build")
	files.copyFile("files/game.love", "build/game.love")

	files.mkdir("build/userdata")
	files.mkdir("build/userdata/pkg")
	files.copyDir(env.filesDirectory .. "/userdata/pkg", "build/userdata")

	local success, err = self:createFileList()
	if not success then
		return false, err
	end

	files.copyFile(self.fileListPath, "build")
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
		table.insert(file_list, {
			path = filemeta.filepath,
			hash = getHash("build/" .. filemeta.filepath),
			url = filemeta.url
		})
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
