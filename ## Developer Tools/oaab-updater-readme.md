#Explanation
The OAAB Updater can be used to replace deprecated OAAB_Data IDs with the replacement ID within a single or group of plugins.
Deprecated IDs will only be deleted by major OAAB_Data change revisions (e.g. 1.x.x to 2.x.x).
The OAAB_Data team has created this updater to make the patching process as simple as possible for mod authors and users.
Mod authors can target their particular mod, or users can patch their entire Data Files directory if you are getting missing ID errors in game.
Simply install and run the updater as described below. 

#Installation
Place both `oaab-updater.exe` and `oaab.toml` into your Data Files directory.

#Instructions
Command Line: Use if you want to see the log:
	cmd: `oaab-updater.exe "test.esp"`

Manual: for quick use
	Drag n' drop your plugin (or entire folder) onto the executable