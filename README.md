![gucci!welcome](assets/gucci-welcome@2x.png)
# gucci!mania
TODO

# Download
You can get the latest release on [this page](https://github.com/Thetan-ILW/gucci-mania/releases)  
There's no need to install the game, it's portable and the archive includes executables for Windows and Linux.

# Join our discord server!
![Discord Banner 1](https://discord.com/api/guilds/1292943911253442633/widget.png?style=banner1)

You can get help there, and there are channels for reporting bugs and suggesting new features.  

# Features
This game has a lot of features, I think we have all the features from **osu! ** and **Etterna**, I mean, EVERY FEATURE. 

:mag_right:  Most important features from osu!:
1. You can use the **osu! user interface**. No need to get used to an unfamiliar UI. Use what you're already comfortable with.
2. gucci!mania **supports osu! beatmaps**, and it's easy to add them - you don't even need to copy files.
3. gucci!mania **supports osu! skins**.
4. This game uses the scoring system from osu!. It means **you can use the osu! accuracy system**: osu!mania V1 and osu!mania V2, with OD 0-10.
5. You can use the **exact same scroll speed** as in osu!. It's a 1:1 match.
6. gucci!mania includes **osu! star ratings**.

:hamburger:   The Most important features from Etterna:
1. You can play songs from Etterna.
2. gucci!mania has **MSD calculator.** It's the difficulty calculator that Etterna uses, which also shows the patterns of the chart.
3. You can **farm PP, MSD** and track a lot of statistics offline.
4. You can use Wife3 accuracy system, from **Judge 4** to Judge Justice. That means you can have CB rushes :stuck_out_tongue_winking_eye: 
5. Constant scroll speed and the ability to change music speed (**rates**)

:trophy:  Here is the list of the most interesting features:
1. The ability to change music speed (**rates**).
2. Support for Stepmania/Etterna songs, Quaver, beatmania/LR2 songs, o2jam, KSH, and MIDI songs.
3. Instant beatmap preview. (NOT IN 0.2alpha-3, remind me to update the readme.md when I return it)
4. **Constant** scroll speed option.
5. Many new mods, such as Full Long Note, No Long Note, converting songs from one key mode to another, and three types of mirror mod.
6. Threaded input.
7. Negative SV.

# Development
This game is built on top of [soundsphere](https://github.com/semyon422/soundsphere). gucci!mania does not modify any files except the `main.lua`, and replaces soundsphere's auto updater with our own.  
We use a lot of plugins to extend the capabilities of soundsphere. You can count gucci!mania as a soundsphere distribution.  

Consider contributing to soundsphere development if you want your changes to help both games.  

This repository contains the auto updater for gucci!mania and all the scripts to build this game.

## List of used plugins:
### [osu! UI](https://github.com/Thetan-ILW/osu_ui) - the main UI
### [MinaCalc](https://github.com/Thetan-ILW/MinaCalc-soundsphere) - FFI bindings to MinaCalc, difficulty calculator from [Etterna](https://github.com/etternagame/etterna)
### [LocalPlayerProfile](https://github.com/Thetan-ILW/PlayerProfile-soundsphere) - osu! PP, MSD and Dans statisics.
### [ManipFactor](https://github.com/Thetan-ILW/ManipFactorEtterna-soundsphere) - Estimates the amount of manip

