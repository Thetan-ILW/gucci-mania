local gucci = {}

function gucci.setDefaultSettings(configs)
	local osu = configs.osu_ui
	osu.scoreSystem = "osuLegacy"
	osu.judgement = 8
	osu.songSelect.scoreSource = "osuv1"
end

return gucci
