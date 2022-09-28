#Developer Tools
for OAAB_Data


#Developer ESM
The Developer version of the OAAB_Data master file (Dev ESM) has had all deprecated objects removed from it.

WARNING
WARNING: before loading an existing plugin with the Dev ESM active in the Construction Set, it is highly recommended that you run the `oaab-updater.exe` tool on the plugin first. See instructions below.
WARNING

The Dev ESM provides a clean slate for modders without the extra ID bloat contained in the Release ESM (which does not have IDs removed to maintain compatibility for existing saves).


#OAAB Updater

- Explanation
The OAAB Updater can be used to replace deprecated OAAB_Data IDs with the replacement ID within a single or group of plugins.
The OAAB_Data team has created this updater to make the patching process as simple as possible for mod authors and users (although removing deprecated IDs is optional for both groups).
Mod authors can target their particular mod or users can patch their entire Data Files directory.
Simply install and run the updater as described below. 

- Installation
Place both `oaab-updater.exe` and `oaab.toml` into your Data Files directory.

- Instructions
Command Line: Use if you want to see the log:
	cmd: `oaab-updater.exe "test.esp"`

Manual: for quick use
	Drag n' drop your plugin (or entire folder) onto the executable


#OAAB_Cells
OAAB_Cells.esp is for mod developers only and is not needed for any OAAB-dependent mods to function.
The plugin contains cells starting with `OAAB_` which serve 2 functions:

1. Palette cells (e.g. copy things into your working cell)
2. Showcases with example scripts for certain assets (see InfoBox markers which contain extra info about certain assets)

OAAB_Cells is a work in progress. Constantly being added to and improved. Make sure to check for updates periodically.
You should load this up alongside your project in the Construction Set so you can easily copy from and reference it.
You do not need to load this in your game unless you want to test some of the script functionality.