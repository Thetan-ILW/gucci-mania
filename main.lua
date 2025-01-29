local Soundsphere = require("src.Soundsphere")
local Branch = require("src.Branch")
local GitPackages = require("src.GitPackages")

local GitPackage = require("src.GitPackage")

local FileMeta = require("src.FileMeta")
local GitPackageFileMeta = require("src.GitPackageFileMeta")

local files = require("src.files")
local env = require("env")

local function help()
	print("List of arguments:")
	print(" -ds		Download soundsphere")
	print(" -dp		Download/Redownload packages")
	print(" -up		Update packages")
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

	local osu_ui = GitPackage(
		"https://github.com/Thetan-ILW/osu_ui",
		"osuUI"
	)
	local minacalc = GitPackage(
		"https://github.com/Thetan-ILW/MinaCalc-soundsphere",
		"MinaCalc"
	)
	local player_profile = GitPackage(
		"https://github.com/Thetan-ILW/PlayerProfile-soundsphere",
		"PlayerProfile"
	)
	local manip_factor = GitPackage(
		"https://github.com/Thetan-ILW/ManipFactorEtterna-soundsphere",
		"ManipFactor"
	)

	---@type GitPackage[]
	local git_pkgs = {
		osu_ui,
		minacalc,
		player_profile,
		manip_factor
	}

	local stable_filemeta = {
		FileMeta(
			"game.love",
			"https://github.com/Thetan-ILW/gucci-mania/releases/latest/download/game.love"
		),
		GitPackageFileMeta(
			osu_ui,
			"main",
			"https://codeload.github.com/Thetan-ILW/osu_ui/zip/refs/heads/develop"

		),
		GitPackageFileMeta(
			minacalc,
			"main",
			"https://codeload.github.com/Thetan-ILW/MinaCalc-soundsphere/zip/refs/heads/main"

		),
		GitPackageFileMeta(
			player_profile,
			"main",
			"https://codeload.github.com/Thetan-ILW/PlayerProfile-soundsphere/zip/refs/heads/main"
		),
		GitPackageFileMeta(
			manip_factor,
			"main",
			"https://codeload.github.com/Thetan-ILW/ManipFactorEtterna-soundsphere/zip/refs/heads/main"
		)
	}

	local develop_filemeta = {
		FileMeta(
			"game.love",
			"https://github.com/Thetan-ILW/gucci-mania/releases/latest/download/game.love"
		),
		GitPackageFileMeta(
			osu_ui,
			"develop",
			"https://codeload.github.com/Thetan-ILW/osu_ui/zip/refs/heads/develop"

		),
		GitPackageFileMeta(
			minacalc,
			"main",
			"https://codeload.github.com/Thetan-ILW/MinaCalc-soundsphere/zip/refs/heads/main"

		),
		GitPackageFileMeta(
			player_profile,
			"main",
			"https://codeload.github.com/Thetan-ILW/PlayerProfile-soundsphere/zip/refs/heads/main"
		),
		GitPackageFileMeta(
			manip_factor,
			"main",
			"https://codeload.github.com/Thetan-ILW/ManipFactorEtterna-soundsphere/zip/refs/heads/main"
		)
	}

	local soundsphere = Soundsphere()
	local git_packages = GitPackages(git_pkgs)
	local stable_branch = Branch("stable", stable_filemeta)
	local develop_branch = Branch("develop", develop_filemeta)

	local success = true
	local err = "" ---@type string?

	local argument = arg[2]
	if argument == "-ds" then
		success, err = soundsphere:download()
	elseif argument == "-dp" then
		success, err = git_packages:downloadAll()
	elseif argument == "-up" then
		success, err = git_packages:updateAll()
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
