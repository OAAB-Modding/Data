#OAAB_Data Prerelease Instructions
--1. Scan OAAB_Data.esm with Mod Packager
--2. Address any missing/incorrect assets
--3. Clean OAAB_Data.esm with tes3cmd
--4. Export with Mod Packager
--5. Copy export into repo folder (skipping duplicates) to check for any missing assets
--6. Ashfall Interop: add new objects to the interop
--7. CSO Interop: add new objects and textures to the interop
--8. Update readme, metadata, and fomod versions
--9. Check metadata file with VS Code for typos
--10. Document change log
--11. Push x.x.x version tag to GitHub
--12. Download OAAB_Data.7z file from https://github.com/OAAB-Modding/Data/releases/
--13. Publish dev blog update
--14. Update pinned GitHub Discussion
--15. Upload OAAB_Data.7z file to Nexus
--16. Update HD textures and developer tools

#OAAB Integrations Postrelease Instructions (when applicable)
--1. OAAB Creature Loot: add new ingredients to vanilla creatures
--2. OAAB Drip: add new armor, clothing, and/or weapons to loot tables; update materials list
--3. OAAB Leveled Creatures: add new creatures to vanilla leveled lists
--4. OAAB Leveled Items: add new items to `_internal` leveled lists; create new lists when applicable