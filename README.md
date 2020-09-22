# OAAB-Data
  
## RFD's notes
To-do on the technical side that all 3 of you need to do:  
- create a free Github account and share the link in the conversation  
- download Github Desktop and make sure your account is linked to it (a bit like Discord App, I guess)  
- clone this repo  
  
Do not try to upload stuff until we set that up (it'd be a hassle).  
  
--*Asset guidelines, etc. should probably go here.*  
Compiled draft:  
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


--*No-asset-retraction policy goes here?*

--*Rule #0: the ESM may only be edited by ONE person at the time*

