local Soundsphere = require("src.Soundsphere")
local Packages = require("src.Packages")
local Branch = require("src.Branch")
local FileMeta = require("src.FileMeta")

local files = require("src.files")
local env = require("env")

local function help()
	print("List of arguments:")
	print(" -ds		Download soundsphere")
	print(" -dp		Download/Redownload packages")
	print(" -love		Create patched game.love")
	print(" -stable	Update stable branch file list")
	print(" -develop	Update develop branch file list")
end

local function main()
	if love.system.getOS() ~= "Linux" then
		print("ERROR: This script can only run on the Linux OS")
		return
	end

	if #arg <= 1 then
		print("No arguments were provided")
		help()
		return
	end

	files.scriptPath = love.filesystem.getSource()

	if not love.filesystem.getInfo(env.filesDirectory) then
		files.mkdir(env.filesDirectory)
	end

	local soundsphere_filemeta = FileMeta("soundsphere.zip", "https://dl.soundsphere.xyz/soundsphere.zip")

	local stable_filemeta = {
		FileMeta(
			"game.love",
			"https://github.com/Thetan-ILW/gucci-mania/releases/latest/download/game.love"
		),
		FileMeta(
			"userdata/pkg/osuUI.zip",
			"https://codeload.github.com/Thetan-ILW/osu_ui/zip/refs/heads/main",
			true
		),
		FileMeta(
			"userdata/pkg/MinaCalc.zip",
			"https://codeload.github.com/Thetan-ILW/MinaCalc-soundsphere/zip/refs/heads/main",
			true
		),
		FileMeta(
			"userdata/pkg/PlayerProfile.zip",
			"https://codeload.github.com/Thetan-ILW/PlayerProfile-soundsphere/zip/refs/heads/main",
			true
		),
		FileMeta(
			"userdata/pkg/ManipFactor.zip",
			"https://codeload.github.com/Thetan-ILW/ManipFactorEtterna-soundsphere/zip/refs/heads/main",
			true
		)
	}

	local develop_filemeta = {
		FileMeta(
			"game.love",
			"https://github.com/Thetan-ILW/gucci-mania/releases/latest/download/game.love"
		),
		FileMeta(
			"userdata/pkg/osuUI.zip",
			"https://codeload.github.com/Thetan-ILW/osu_ui/zip/refs/heads/develop",
			true
		),
		FileMeta(
			"userdata/pkg/MinaCalc.zip",
			"https://codeload.github.com/Thetan-ILW/MinaCalc-soundsphere/zip/refs/heads/main",
			true
		),
		FileMeta(
			"userdata/pkg/PlayerProfile.zip",
			"https://codeload.github.com/Thetan-ILW/PlayerProfile-soundsphere/zip/refs/heads/main",
			true
		),
		FileMeta(
			"userdata/pkg/ManipFactor.zip",
			"https://codeload.github.com/Thetan-ILW/ManipFactorEtterna-soundsphere/zip/refs/heads/main",
			true
		)
	}

	local soundsphere = Soundsphere()
	local packages = Packages()
	local stable_branch = Branch("stable", stable_filemeta)
	local develop_branch = Branch("develop", develop_filemeta)

	local success = true
	local err = "" ---@type string?

	local argument = arg[2]
	if argument == "-ds" then
		success, err = packages:downloadFile(soundsphere_filemeta, "soundsphere.zip")
		success, err = soundsphere:unzip()
	elseif argument == "-dp" then
		success, err = packages:downloadAll(stable_filemeta)
	elseif argument == "-love" then
		success, err = soundsphere:createGameLove()
	elseif argument == "-stable" then
		success, err = stable_branch:build()
	elseif argument == "-develop" then
		success, err = develop_branch:build()
	else
		success = false
		err = "Unkown argument"
	end

	if not success then
		print(err)
	end

end

function love.load()
	main()
	love.event.push("quit")
end
