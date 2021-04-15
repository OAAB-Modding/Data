# OAAB-Data
# Version 1.6.0

### Nexus Download Instructions
**Manual Installation**
--00 Core
--01 GitD Patch				install after GitD (no sunray effect)
--01 GitD Patch Sunrays		install after GitD (includes sunray effect - do not use with "01 GitD Patch")
--02 Epic Plants Patch		install if you use Epic Plants

**Wrye Mash / MO2**  
--1. Archive format is Mash installers compatible
--1. 01 GitD patches are mutially exclusive

### Mod Repo Instructions - ADVANCED USERS AND MODDERS
**Downloading the repo**
--1. Scroll up and click `Code` button.  
--2. Click `Download ZIP`.  
--3. Install like any other mod.  
  
**Manual installation**  
--1. Set up the local repo path anywhere you want; default one is okay.  
--2. Copy the files to your Morrowind Data folder.  

**Wrye Mash / MO2**  
--1. Set up the local repo path in your Mash mod folder.  

### Asset guidelines
1) Style of new assets should be vanilla-compatible.  
1.1) Design elements should draw inspiration from vanilla parts of the same or similar sets where applicable. When not applicable, the design elements should maintain a visual consistency with the rest of the game as much as possible. As an example, new silver weapon models would do good to use the spiraly crossguard designs of vanilla silver swords. Dunmer furniture uses organic curves compared to Imperial straight lines, etc.  
1.2) proportions of items, buildings, characters, and other objects should all align with the vanilla experience. Including but not limited to scale with respect to the player and other objects. Examples: thickness of tables or girth of weapons relative to actors.  
1.3) the color palette of most new textures, vertex coloring, or other form of visual rendering should be consistent with the muted vanilla palette - no vibrant psychedelic colors unless justified by specific purpose.  
2) Use vanilla textures whenever reasonable.  
3) No excessive smoothing or polycount on models (can be better than vanilla, but not exponentially); quoting TR: *Have enough faces to look good, but not excessive faces*  
4) Most textures shouldn't exceed 1024x1024 in size (atlases excluded). A texture should use the DDS format. If the texture does not need alpha, it should be saved with dx1 compression, if it does use the alpha channel. It should use dx3 compression for on-off alpha, and dx5 compression for varying alpha. Any texture should have mipmaps (excluding UI textures, which shouldn't have them).  
5) NIFs should be optimized as much as possible (defined collision, minimal shapes, LOD, alpha testing when possible, blank shape and node names (unless needed by vanilla game or MWSE), etc)  
6) UV maps should have as little stretching and seams as possible.  
7) Item stats should be submitted to the group document for peer review (proposed stats can be used when merging)  

  
### OAAB_Data team
Melchior Dahrk
OperatorJack
R-Zero
RedFurryDemon 
Remiros
Wolli
XeroFoxx

  
### Credits
`@_gwynne__` - Tel Mora painting  
Aitrus - glass helm  
Alisiagae - ebony halberd, scroll ideas
AnOldFriend - wax texture  
Archipel de Pertevue - Dungeon grate, archery target  
Autoclock - Telvanni spear  
Axeljk - Cloth helm  
B00ze - daylight script  
Barabas - guar skull  
cdcooley - invisible creature model
Chainy - scorch mark decals  
DanielCoffey and doccdr - Book textures
Danke - Cephalopod pauldrons  
David Gurrea - Infernace architectural textures  
Dongle - water meshes  
Draconik - glass light
EJ-12 - Various textures and effects and lots of technical assistance  
Foresti - some textures for the bug armor  
Greatness7 - Particle motes, scripting help  
Kiteflyer61 - Archery target original models  
Korana - fern model  
Kurpolio - egg explosion effect, lava spout effect, other miscellaneous contributions to special effects  
Lady Eternity - drip model and texture source  
lidicus - spider creature  
LondonRook - blood pool texture, staff table, velothi tower, ashcliff models, and bandages  
Lougian - dust motes particles, rock meshes, and vine meshes  
ManaUser - Tomb leveled lists from Grave Goods  
mikhog - for acid burn sound effect  
Momo - sack models, pitchfork, and grain texture  
Morovir - rock cluster meshes 01 and 04  
Morrowind Modding Community Discord for assistance, feedback, and critique  
Mr_Siika - bat creature  
Project Tamriel - cliff meshes  
Qarl - blood splatter texture  
ramccoid - web textures  
Rotat - native corprus stalkers  
RubberMan - grindstone sound, weapon racks
Ruffin Vangarr - Dreugh armor, Concept art daedric helms
Rytelier - some kwama cave rock meshes  
Sachiel - cave bridge mesh, rocks  
Schwaa - the bug shields  
Siberian Crab - Crystals textures, Holamayan resources  
Silicon Bros - Light bonemold armor  
Spok - Imperial fort windows  
Stripes - Wood tankard  
Strotis - millstone model  
Stuporstar - smith and crafting resource  
Stuporstar and Books of Vvardenfell team (see Docs folder for full credits) - I have edited several books for consistenc with my project  
Taddeus - rock meshes and AO map  
Tamriel_Data- blood decal texture, rich dunmer desk, some models for knives, original scythe model, coiled rope, water textures, sailor dialogue  
Textures.com - for various texture sources  
The Wanderer - original Book models, wooden hourglass  
UIX Redemption - Water reflection map  
Westly - mindcleaver model and texture  
Wollibeebee - mountain meshes, cliff meshes  
Yar-Yulme - NIF resources  
