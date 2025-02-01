local class = require("class")
local files = require("src.files")
local env = require("env")

---@class Soundsphere
---@operator call: Soundsphere
local Soundsphere = class()

---@return boolean success
---@return string? error
function Soundsphere:unzip()
	if love.filesystem.getInfo("soundsphere") then
		print("INFO: Deleting previous soundsphere files")
		os.execute("rm -rf soundsphere")
	end

	os.execute("unzip soundsphere.zip")

	if not love.filesystem.getInfo("soundsphere") then
		return false, "ERROR: Failed to unpack soundsphere.zip"
	end

	return true
end

---@return boolean success
---@return string? error
function Soundsphere:createGameLove()
	if love.filesystem.getInfo("gamelove_patched") then
		print("INFO: Deleting previously patched gamelove")
		os.execute("rm -rf gamelove_patched")
	end

	files.mkdir("gamelove_patched")

	os.execute("unzip soundsphere/game.love -d gamelove_patched/")

	files.copyDir("soundsphere/resources", "gamelove_patched")
	files.copyDir("love/*", "gamelove_patched")

	files.replaceWithGucci("gamelove_patched/sphere/app/WindowModel.lua")
	files.replaceWithGucci("gamelove_patched/sphere/persistence/CacheModel/LocationManager.lua")
	os.execute("sed -i s/594443609668059149/1294208452503273483/g gamelove_patched/sphere/app/DiscordModel.lua")

	files.createArchive("gamelove_patched", "files/game.love")

	return true
end

return Soundsphere
